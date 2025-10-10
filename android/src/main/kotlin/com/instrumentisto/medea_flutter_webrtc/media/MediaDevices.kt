package com.instrumentisto.medea_flutter_webrtc.media

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.instrumentisto.medea_flutter_webrtc.ForegroundCallService
import com.instrumentisto.medea_flutter_webrtc.Permissions
import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.exception.GetUserMediaException
import com.instrumentisto.medea_flutter_webrtc.exception.PermissionException
import com.instrumentisto.medea_flutter_webrtc.model.*
import com.instrumentisto.medea_flutter_webrtc.proxy.AudioMediaTrackSource
import com.instrumentisto.medea_flutter_webrtc.proxy.MediaStreamTrackProxy
import com.instrumentisto.medea_flutter_webrtc.proxy.VideoMediaTrackSource
import com.instrumentisto.medea_flutter_webrtc.utils.EglUtils
import java.util.*
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeout
import org.webrtc.*

private val TAG = MediaDevices::class.java.simpleName

/**
 * Default device video width.
 *
 * This width will be used, if no width provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_WIDTH = 720

/**
 * Default device video height.
 *
 * This width will be used, if no height provided in the constraints.
 *
 * SD resolution used by default.
 */
private const val DEFAULT_HEIGHT = 576

/**
 * Default device video FPS.
 *
 * This width will be used, if no FPS provided in the constraints.
 */
private const val DEFAULT_FPS = 30

/** Identifier for the ear speaker audio output device. */
private const val EAR_SPEAKER_DEVICE_ID: String = "ear-speaker"

/** Identifier for the ear speaker audio output device. */
private const val WIRED_HEADSET_DEVICE_ID: String = "wired-headset"

/** Identifier for the speakerphone audio output device. */
private const val SPEAKERPHONE_DEVICE_ID: String = "speakerphone"

/** Identifier for the bluetooth headset audio output device. */
private const val BLUETOOTH_HEADSET_DEVICE_ID: String = "bluetooth-headset"

/** Cloned tracks for `getUserVideoTrack()` if the video source has not been released. */
private val videoTracks: HashMap<VideoConstraints, MediaStreamTrackProxy> = HashMap()

/**
 * Processor for `getUserMedia` requests.
 *
 * @property state Global state used for enumerating devices and creation new
 * [MediaStreamTrackProxy]s.
 */
class MediaDevices(val state: State, val permissions: Permissions) : BroadcastReceiver() {
  /** Indicator of bluetooth headset connection state. */
  private var isBluetoothHeadsetConnected: Boolean = false

  /** Indicator of wired headset connection state. */
  private var isWiredHeadsetConnected: Boolean = false

  /**
   * Enumerator for the camera devices, based on which new video [MediaStreamTrackProxy]s will be
   * created.
   */
  private val cameraEnumerator: CameraEnumerator = getCameraEnumerator(state.context)

  /** List of [EventObserver]s of these [MediaDevices]. */
  private var eventObservers: HashSet<EventObserver> = HashSet()

  /** [AudioManager] system service. */
  private val audioManager: AudioManager = state.getAudioManager()

  /** Audio focus manager compatible across API levels. */
  private val audioFocus: AudioFocusCompat = AudioFocusCompat.create(state)

  /** Currently selected audio output ID by [setOutputAudioId] call. */
  private var selectedAudioOutputId: String = SPEAKERPHONE_DEVICE_ID

  /** Indicator whether the last Bluetooth SCO connection attempt failed. */
  private var isBluetoothScoFailed: Boolean = false

  /** [CompletableDeferred] being resolved once Bluetooth SCO request is completed. */
  private var bluetoothScoDeferred: CompletableDeferred<Unit>? = null

  /** [Mutex] ensuring only one call to [setOutputAudioId] can be executed at the time. */
  private var setOutputAudioMutex: Mutex = Mutex()

  /** [CompletableDeferred] being resolved once Bluetooth SCO is completely stopped. */
  private var stopBluetoothScoDeferred: CompletableDeferred<Unit>? = null

  /** Indicator whether bluetooth SCO is connected. */
  private var scoAudioStateConnected: Boolean = false

  /**
   * [AudioDeviceCallback] provided to [AudioManager.registerAudioDeviceCallback] which fires once
   * new audio device is connected.
   *
   * [isBluetoothHeadsetConnected] will be updated based on this subscription.
   */
  private var audioDeviceCallback: AudioDeviceCallback? = null

  companion object {
    /** Observer of [MediaDevices] events. */
    interface EventObserver {
      /** Notifies the subscriber about [enumerateDevices] list update. */
      fun onDeviceChange()
    }

    /**
     * Creates a new [CameraEnumerator] instance based on the supported Camera API version.
     *
     * @param context Android context which needed for the [CameraEnumerator] creation.
     *
     * @return [CameraEnumerator] based on the available Camera API version.
     */
    private fun getCameraEnumerator(context: Context): CameraEnumerator {
      return if (Camera2Enumerator.isSupported(context)) {
        Camera2Enumerator(context)
      } else {
        Camera1Enumerator(false)
      }
    }
  }

  /**
   * Prepares for an ongoing VoIP session.
   *
   * - Sets [AudioManager.mode] to [AudioManager.MODE_IN_COMMUNICATION].
   * - Requests audio focus.
   * - Starts a foreground service to keep audio/video capturing alive.
   */
  public suspend fun startVoIP() {
    state.getAudioManager().mode = AudioManager.MODE_IN_COMMUNICATION
    val granted = audioFocus.requestAudioFocus()
    if (!granted) {
      // That's unfortunate but not worth throwing an error.
      Log.w(TAG, "Audio focus not granted")
    }
    ForegroundCallService.Companion.start(state.context, permissions)
  }

  /**
   * Tears down VoIP-related audio state after a call ends.
   *
   * - Abandons audio focus previously acquired by [startVoIP].
   * - Resets [AudioManager.mode] back to [AudioManager.MODE_NORMAL].
   * - Stops the foreground service started by [startVoIP].
   */
  public fun stopVoIP() {
    audioFocus.abandonAudioFocus()
    state.getAudioManager().mode = AudioManager.MODE_NORMAL
    ForegroundCallService.Companion.stop(state.context, permissions)
  }

  init {
    audioDeviceCallback =
        object : AudioDeviceCallback() {
          override fun onAudioDevicesAdded(addedDevices: Array<AudioDeviceInfo>) {
            synchronizeHeadsetState()
          }

          override fun onAudioDevicesRemoved(removedDevices: Array<AudioDeviceInfo>) {
            synchronizeHeadsetState()
          }
        }

    state.context.registerReceiver(this, IntentFilter(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED))
    synchronizeHeadsetState()
    audioManager.registerAudioDeviceCallback(audioDeviceCallback, null)
  }

  /** Actualizes Bluetooth headset state based on the [AudioManager.getDevices]. */
  private fun synchronizeHeadsetState() {
    val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)

    var hasBluetooth = false
    var hasWired = false
    for (device in devices) {
      if (device.isBluetoothDevice()) {
        hasBluetooth = true
      } else if (device.isWiredHeadset()) {
        hasWired = true
      }
    }

    updateHasBluetoothHeadset(hasBluetooth)
    updateHasWiredHeadset(hasWired)
  }

  private fun updateHasWiredHeadset(isConnected: Boolean) {
    if (isWiredHeadsetConnected != isConnected) {
      isWiredHeadsetConnected = isConnected
      Handler(Looper.getMainLooper()).post { eventBroadcaster().onDeviceChange() }
    }
  }

  /**
   * Sets [isBluetoothHeadsetConnected] to the provided value.
   *
   * Fires [EventObserver.onDeviceChange] notification if it changed.
   */
  private fun updateHasBluetoothHeadset(isConnected: Boolean) {
    if (isBluetoothHeadsetConnected != isConnected) {
      isBluetoothHeadsetConnected = isConnected
      Handler(Looper.getMainLooper()).post { eventBroadcaster().onDeviceChange() }
    }
  }

  /**
   * Creates local audio and video [MediaStreamTrackProxy]s based on the provided [Constraints].
   *
   * @param constraints Parameters based on which [MediaDevices] will select most suitable device.
   *
   * @return List of [MediaStreamTrackProxy]s most suitable based on the provided [Constraints].
   */
  suspend fun getUserMedia(constraints: Constraints): List<MediaStreamTrackProxy> {
    val tracks = mutableListOf<MediaStreamTrackProxy>()
    if (constraints.audio != null) {
      try {
        tracks.add(getUserAudioTrack(constraints.audio))
      } catch (e: Exception) {
        throw GetUserMediaException(e.message, GetUserMediaException.Kind.Audio)
      }
    }
    if (constraints.video != null) {
      try {
        tracks.add(getUserVideoTrack(constraints.video))
      } catch (e: Exception) {
        throw GetUserMediaException(e.message, GetUserMediaException.Kind.Video)
      }
    }
    return tracks
  }

  /** @return List of [MediaDeviceInfo]s for the currently available devices. */
  suspend fun enumerateDevices(): List<MediaDeviceInfo> {
    return enumerateAudioDevices() + enumerateVideoDevices()
  }

  /**
   * Stops Bluetooth SCO.
   *
   * Throws [GetUserMediaException] from [setOutputAudioId] for enabling Bluetooth SCO (if
   * [MediaDevices] has ongoing request).
   */
  private suspend fun stopBluetoothSco() {
    if (Build.VERSION.SDK_INT >= 31) {
      // Prefer modern routing API on Android 12+.
      audioManager.clearCommunicationDevice()
      stopBluetoothScoDeferred?.complete(Unit)
      stopBluetoothScoDeferred = null
      bluetoothScoDeferred?.completeExceptionally(
          GetUserMediaException(
              "Bluetooth headset connection request was cancelled",
              GetUserMediaException.Kind.Audio))
      bluetoothScoDeferred = null
      return
    }

    stopBluetoothScoDeferred = CompletableDeferred()
    audioManager.stopBluetoothSco()
    stopBluetoothScoDeferred?.await()
    audioManager.isBluetoothScoOn = false
    bluetoothScoDeferred?.completeExceptionally(
        GetUserMediaException(
            "Bluetooth headset connection request was cancelled", GetUserMediaException.Kind.Audio))
    bluetoothScoDeferred = null
  }

  /**
   * Switches the current output audio device to the device with the provided identifier.
   *
   * @param deviceId Identifier for the output audio device to be selected.
   */
  suspend fun setOutputAudioId(deviceId: String) {
    setOutputAudioMutex.withLock {
      when (deviceId) {
        WIRED_HEADSET_DEVICE_ID, EAR_SPEAKER_DEVICE_ID -> {
          if (scoAudioStateConnected) {
            stopBluetoothSco()
          }
          if (Build.VERSION.SDK_INT >= 31) {
            // Clear explicit routing.
            // System will select the appropriate earpiece/wired device.
            audioManager.clearCommunicationDevice()
          } else {
            audioManager.isSpeakerphoneOn = false
          }
        }
        SPEAKERPHONE_DEVICE_ID -> {
          if (scoAudioStateConnected) {
            stopBluetoothSco()
          }
          if (Build.VERSION.SDK_INT >= 31) {
            val speaker =
                audioManager.availableCommunicationDevices.firstOrNull {
                  it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
                }
            if (speaker != null) {
              audioManager.setCommunicationDevice(speaker)
            } else {
              audioManager.clearCommunicationDevice()
            }
          } else {
            audioManager.isSpeakerphoneOn = true
          }
        }
        BLUETOOTH_HEADSET_DEVICE_ID -> {
          if (scoAudioStateConnected) {
            return
          }
          val deviceIdBefore = selectedAudioOutputId
          selectedAudioOutputId = deviceId
          if (isBluetoothHeadsetConnected) {
            if (Build.VERSION.SDK_INT >= 31) {
              val bt =
                  audioManager.availableCommunicationDevices.firstOrNull { it.isBluetoothDevice() }
              if (bt != null) {
                val ok = audioManager.setCommunicationDevice(bt)
                if (!ok) {
                  selectedAudioOutputId = deviceIdBefore
                  isBluetoothScoFailed = true
                  throw GetUserMediaException(
                      "Failed to route to Bluetooth device", GetUserMediaException.Kind.Audio)
                }
                isBluetoothScoFailed = false
              } else {
                selectedAudioOutputId = deviceIdBefore
                isBluetoothScoFailed = true
                throw GetUserMediaException(
                    "Bluetooth device not available", GetUserMediaException.Kind.Audio)
              }
            } else {
              if (bluetoothScoDeferred == null) {
                isBluetoothScoFailed = false
                Log.d(TAG, "Bluetooth headset was selected. Trying to start Bluetooth SCO...")
                bluetoothScoDeferred = CompletableDeferred()
                audioManager.startBluetoothSco()
              }
              try {
                withTimeout(10000L) { bluetoothScoDeferred?.await() }
              } catch (e: Exception) {
                selectedAudioOutputId = deviceIdBefore
                audioManager.stopBluetoothSco()
                isBluetoothScoFailed = true
                throw e
              }
            }
          } else {
            throw IllegalArgumentException("Unknown output device: $deviceId")
          }
        }
        else -> {
          throw IllegalArgumentException("Unknown output device: $deviceId")
        }
      }
    }
  }

  /**
   * Adds the provided [EventObserver] to the list of [EventObserver]s of these [MediaDevices].
   *
   * @param eventObserver [EventObserver] to be subscribed.
   */
  fun addObserver(eventObserver: EventObserver) {
    eventObservers.add(eventObserver)
  }

  /**
   * @return Broadcast [EventObserver] sending events to all the [EventObserver]s of these
   * [MediaDevices].
   */
  private fun eventBroadcaster(): EventObserver {
    return object : EventObserver {
      override fun onDeviceChange() {
        eventObservers.forEach { it.onDeviceChange() }
      }
    }
  }

  /** @return List of [MediaDeviceInfo]s for the currently available audio devices. */
  public fun enumerateAudioDevices(): List<MediaDeviceInfo> {
    val result =
        mutableListOf(
            MediaDeviceInfo(
                SPEAKERPHONE_DEVICE_ID, "Speakerphone", MediaDeviceKind.AUDIO_OUTPUT, false))

    var bluetoothDevice: AudioDeviceInfo? = null
    val availableDevices =
        if (Build.VERSION.SDK_INT >= 31) {
          audioManager.availableCommunicationDevices
        } else {
          audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).toList()
        }

    for (device in availableDevices) {
      if (bluetoothDevice == null && device.isBluetoothDevice()) {
        bluetoothDevice = device
      } else if (device.isWiredHeadset()) {
        isWiredHeadsetConnected = true
      }
    }

    if (bluetoothDevice != null) {
      result.add(
          MediaDeviceInfo(
              BLUETOOTH_HEADSET_DEVICE_ID,
              bluetoothDevice.productName.toString(),
              MediaDeviceKind.AUDIO_OUTPUT,
              isBluetoothScoFailed))
    }

    result +=
        if (isWiredHeadsetConnected) {
          MediaDeviceInfo(
              WIRED_HEADSET_DEVICE_ID, "Wired headset", MediaDeviceKind.AUDIO_OUTPUT, false)
        } else {
          // Ear-speaker cannot be used if there is a wired headset connected.
          MediaDeviceInfo(EAR_SPEAKER_DEVICE_ID, "Ear-speaker", MediaDeviceKind.AUDIO_OUTPUT, false)
        }

    result.add(MediaDeviceInfo("default", "default", MediaDeviceKind.AUDIO_INPUT, false))

    return result
  }

  /** @return List of [MediaDeviceInfo]s for the currently available video devices. */
  private suspend fun enumerateVideoDevices(): List<MediaDeviceInfo> {
    try {
      permissions.requestPermission(Manifest.permission.CAMERA)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Camera permission was not granted", GetUserMediaException.Kind.Video)
    }
    return cameraEnumerator
        .deviceNames
        .map { deviceId -> MediaDeviceInfo(deviceId, deviceId, MediaDeviceKind.VIDEO_INPUT, false) }
        .toList()
  }

  /**
   * Lookups ID of the video device most suitable basing on the provided [VideoConstraints].
   *
   * @param constraints [VideoConstraints] based on which lookup will be performed.
   *
   * @return `null` if all devices are not suitable for the provided [VideoConstraints], or most
   * suitable device ID for the provided [VideoConstraints].
   */
  private fun findDeviceMatchingConstraints(constraints: VideoConstraints): String? {
    val scoreTable = TreeMap<Int, String>()
    for (deviceId in cameraEnumerator.deviceNames) {
      val deviceScore = constraints.calculateScoreForDeviceId(cameraEnumerator, deviceId)
      if (deviceScore != null) {
        scoreTable[deviceScore] = deviceId
      }
    }

    return scoreTable.lastEntry()?.value
  }

  /**
   * Creates a video [MediaStreamTrackProxy] for the provided [VideoConstraints].
   *
   * @param constraints [VideoConstraints] to perform the lookup with.
   *
   * @return Most suitable [MediaStreamTrackProxy] for the provided [VideoConstraints].
   */
  private suspend fun getUserVideoTrack(constraints: VideoConstraints): MediaStreamTrackProxy {
    try {
      permissions.requestPermission(Manifest.permission.CAMERA)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Camera permission was not granted", GetUserMediaException.Kind.Video)
    }
    val cachedTrack = videoTracks[constraints]
    if (cachedTrack != null) {
      val track = cachedTrack.fork()
      videoTracks[constraints] = track
      track.onStop { videoTracks.remove(constraints, track) }
      return track
    }

    val deviceId =
        findDeviceMatchingConstraints(constraints)
            ?: throw GetUserMediaException("Overconstrained", GetUserMediaException.Kind.Video)
    val width = constraints.width ?: DEFAULT_WIDTH
    val height = constraints.height ?: DEFAULT_HEIGHT
    val fps = constraints.fps ?: DEFAULT_FPS

    val videoSource = state.getPeerConnectionFactory().createVideoSource(false)
    videoSource.adaptOutputFormat(width, height, fps)

    val surfaceTextureRenderer =
        SurfaceTextureHelper.create(Thread.currentThread().name, EglUtils.rootEglBaseContext)
    val videoCapturer = cameraEnumerator.createCapturer(deviceId, null)
    videoCapturer.initialize(surfaceTextureRenderer, state.context, videoSource.capturerObserver)
    videoCapturer.startCapture(width, height, fps)

    val facingMode =
        if (cameraEnumerator.isBackFacing(deviceId)) FacingMode.ENVIRONMENT else FacingMode.USER

    val videoTrackSource =
        VideoMediaTrackSource(
            videoCapturer,
            videoSource,
            surfaceTextureRenderer,
            state.getPeerConnectionFactory(),
            facingMode,
            deviceId)

    val track = videoTrackSource.newTrack()
    track.onStop { videoTracks.remove(constraints, track) }
    videoTracks[constraints] = track

    return track
  }

  /**
   * Creates an audio [MediaStreamTrackProxy] basing on the provided [AudioConstraints].
   *
   * @param constraints [AudioConstraints] to perform the lookup with.
   *
   * @return Most suitable [MediaStreamTrackProxy] for the provided [AudioConstraints].
   */
  private suspend fun getUserAudioTrack(constraints: AudioConstraints): MediaStreamTrackProxy {
    try {
      permissions.requestPermission(Manifest.permission.RECORD_AUDIO)
    } catch (e: PermissionException) {
      throw GetUserMediaException(
          "Microphone permissions was not granted", GetUserMediaException.Kind.Audio)
    }
    val source = state.getPeerConnectionFactory().createAudioSource(constraints.intoWebRtc())
    val audioTrackSource = AudioMediaTrackSource(source, state.getPeerConnectionFactory())
    return audioTrackSource.newTrack()
  }

  override fun onReceive(ctx: Context?, intent: Intent?) {
    if (intent?.action != null) {
      if (AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED == intent.action) {
        val state =
            intent.getIntExtra(
                AudioManager.EXTRA_SCO_AUDIO_STATE, AudioManager.SCO_AUDIO_STATE_DISCONNECTED)
        when (state) {
          AudioManager.SCO_AUDIO_STATE_CONNECTED -> {
            Log.d(TAG, "SCO connected")
            scoAudioStateConnected = true
            isBluetoothScoFailed = false
            bluetoothScoDeferred?.complete(Unit)
            bluetoothScoDeferred = null
            audioManager.isBluetoothScoOn = true
            audioManager.isSpeakerphoneOn = false
          }
          AudioManager.SCO_AUDIO_STATE_DISCONNECTED -> {
            Log.d(TAG, "SCO disconnected")
            scoAudioStateConnected = false
            isBluetoothScoFailed = true
            stopBluetoothScoDeferred?.complete(Unit)
            stopBluetoothScoDeferred = null
            bluetoothScoDeferred?.completeExceptionally(
                GetUserMediaException(
                    "Bluetooth headset is unavailable at this moment",
                    GetUserMediaException.Kind.Audio))
            bluetoothScoDeferred = null
            Handler(Looper.getMainLooper()).post { eventBroadcaster().onDeviceChange() }
          }
        }
      }
    }
  }

  /** Releases all the allocated resources. */
  fun dispose() {
    state.context.unregisterReceiver(this)
    audioManager.unregisterAudioDeviceCallback(audioDeviceCallback)
    audioDeviceCallback = null
  }
}

/** Indicates if the provided [AudioDeviceInfo] is related to a Bluetooth headset. */
fun AudioDeviceInfo.isBluetoothDevice(): Boolean {
  return this.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
      this.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
      (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
          this.type == AudioDeviceInfo.TYPE_BLE_HEADSET)
}

/** Indicates if the provided [AudioDeviceInfo] is related to a wired headset. */
fun AudioDeviceInfo.isWiredHeadset(): Boolean {
  return this.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
      this.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
      this.type == AudioDeviceInfo.TYPE_USB_DEVICE ||
      (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
          this.type == AudioDeviceInfo.TYPE_USB_HEADSET)
}
