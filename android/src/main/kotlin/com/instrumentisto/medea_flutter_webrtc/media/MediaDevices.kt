package com.instrumentisto.medea_flutter_webrtc.media

import android.Manifest
import android.content.Context
import android.media.AudioManager
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

/** Cloned tracks for `getUserVideoTrack()` if the video source has not been released. */
private val videoTracks: HashMap<VideoConstraints, MediaStreamTrackProxy> = HashMap()

/**
 * Processor for `getUserMedia` requests.
 *
 * @property state Global state used for enumerating devices and creation new
 * [MediaStreamTrackProxy]s.
 */
class MediaDevices(val state: State, val permissions: Permissions) {
  /**
   * Enumerator for the camera devices, based on which new video [MediaStreamTrackProxy]s will be
   * created.
   */
  private val cameraEnumerator: CameraEnumerator = getCameraEnumerator(state.context)

  /** List of [OnDeviceChangeObs]s of these [MediaDevices]. */
  private var onDeviceChangeObs: HashSet<OnDeviceChangeObs> = HashSet()

  /** Audio focus manager compatible across API levels. */
  private val audioFocus: AudioFocusCompat = AudioFocusCompat.create(state)

  /** Audio devices manager. */
  private val audioDevices: AudioDevices = AudioDevices.create(state, eventBroadcaster())

  companion object {
    /** Observer of [MediaDevices] events. */
    interface OnDeviceChangeObs {
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
  suspend fun startVoIP() {
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
  fun stopVoIP() {
    audioFocus.abandonAudioFocus()
    state.getAudioManager().mode = AudioManager.MODE_NORMAL
    ForegroundCallService.Companion.stop(state.context, permissions)
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
    return audioDevices.enumerateDevices() + enumerateVideoDevices()
  }

  /**
   * Adds the provided [OnDeviceChangeObs] to the list of [OnDeviceChangeObs]s of these
   * [MediaDevices].
   *
   * @param onDeviceChangeObs [OnDeviceChangeObs] to be subscribed.
   */
  fun addObserver(onDeviceChangeObs: OnDeviceChangeObs) {
    this.onDeviceChangeObs.add(onDeviceChangeObs)
  }

  /**
   * Switches the current output audio device to the device with the provided identifier.
   *
   * @param deviceId Identifier for the output audio device to be selected.
   */
  suspend fun setOutputAudioId(id: String) {
    audioDevices.setOutputAudioId(id)
  }

  /** Releases all the allocated resources. */
  fun dispose() {
    audioDevices.dispose()
  }

  /**
   * @return Broadcast [OnDeviceChangeObs] sending events to all the [OnDeviceChangeObs]s of these
   * [MediaDevices].
   */
  private fun eventBroadcaster(): OnDeviceChangeObs {
    return object : OnDeviceChangeObs {
      override fun onDeviceChange() {
        ThreadUtils.checkIsOnMainThread()
        onDeviceChangeObs.forEach { it.onDeviceChange() }
      }
    }
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
        .map { deviceId ->
          MediaDeviceInfo(deviceId, deviceId, MediaDeviceKind.VIDEO_INPUT, null, false)
        }
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
        findDeviceMatchingConstraints(constraints) ?: throw RuntimeException("Overconstrained")
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
}
