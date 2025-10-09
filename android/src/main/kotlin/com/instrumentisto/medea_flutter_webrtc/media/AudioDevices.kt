package com.instrumentisto.medea_flutter_webrtc.media

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
import androidx.annotation.RequiresApi
import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.exception.GetUserMediaException
import com.instrumentisto.medea_flutter_webrtc.media.MediaDevices.Companion.OnDeviceChangeObs
import com.instrumentisto.medea_flutter_webrtc.model.AudioDeviceKind
import com.instrumentisto.medea_flutter_webrtc.model.MediaDeviceInfo
import com.instrumentisto.medea_flutter_webrtc.model.MediaDeviceKind
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeout
import org.webrtc.ThreadUtils

private val TAG = AudioDevices::class.java.simpleName

/**
 * Maximum time in milliseconds to wait for the system to confirm a device routing operation (e.g.,
 * [AudioManager.OnCommunicationDeviceChangedListener.onCommunicationDeviceChanged] or Bluetooth SCO
 * connect).
 */
private const val DEVICE_CHANGE_TIMEOUT_MS = 10000L // ms

/**
 * Manager of audio input/output devices usage.
 *
 * @property state Global plugin state providing access to [Context] and services.
 * @property obs Observer notified when the exposed device list or state changes.
 */
sealed class AudioDevices(val state: State, val obs: OnDeviceChangeObs) : AudioDeviceCallback() {

  /** System audio manager used for enumeration and routing. */
  protected val audioManager: AudioManager = state.getAudioManager()

  init {
    audioManager.registerAudioDeviceCallback(this, Handler(state.context.mainLooper))
  }

  companion object {
    /**
     * Creates the API-appropriate implementation.
     *
     * @param state Shared plugin state.
     * @param obs Observer for device list changes.
     * @return API 31+ or legacy implementation depending on the device SDK.
     */
    fun create(state: State, obs: OnDeviceChangeObs): AudioDevices {
      return if (Build.VERSION.SDK_INT >= 31) {
        AudioDevicesSdk31(state, obs)
      } else {
        AudioDevicesLegacy(state, obs)
      }
    }
  }

  /**
   * Enumerates currently available audio devices.
   *
   * @return List of [MediaDeviceInfo] entries.
   */
  abstract fun enumerateDevices(): List<MediaDeviceInfo>

  /**
   * Requests routing audio output to a specific device.
   *
   * Implementations may suspend until the system confirms routing or times out.
   *
   * @param deviceId Device identifier ([AudioDeviceInfo.id] on SDK >= 31 or [LegacyAudioDevice.id]
   * otherwise).
   */
  abstract suspend fun setOutputAudioId(deviceId: String)

  /** Releases listeners and resources associated with this instance. */
  open fun dispose() {
    audioManager.unregisterAudioDeviceCallback(this)
  }
}

/**
 * API 31+ audio manager implementation using new APIs: [AudioManager.availableCommunicationDevices]
 * , [AudioManager.setCommunicationDevice], [AudioManager.clearCommunicationDevice].
 *
 * @param state Shared plugin state.
 * @param obs Observer notified when device list changes.
 */
@RequiresApi(31)
private class AudioDevicesSdk31(state: State, obs: OnDeviceChangeObs) :
    AudioDevices(state, obs), AudioManager.OnCommunicationDeviceChangedListener {
  /** Cached snapshot of the last reported device list. */
  var currentDevicesList = listOf<MediaDeviceInfo>()

  /** Deferred completed when the system confirms a pending route change. */
  private var communicationDeviceChangedDeferred: CompletableDeferred<Unit>? = null

  /** ID of the device currently awaited for activation (if any). */
  private var pendingCommunicationDeviceId: Int? = null

  /** ID of the device selected by the user and confirmed by the system. */
  private var selectedDeviceId: Int? = null

  /** Set of device IDs marked as failed due to unexpected reroutes. */
  private val failedDeviceIds: MutableSet<Int> = mutableSetOf()

  /** Serializes concurrent routing changes to avoid races. */
  private var setOutputAudioMutex: Mutex = Mutex()

  init {
    // Listen for communication device routing changes on the main executor, and prime device list.
    audioManager.addOnCommunicationDeviceChangedListener(state.context.mainExecutor, this)
    currentDevicesList = this.enumerateDevices()
  }

  /**
   * Enumerates available communication devices with failure flags applied.
   *
   * @return List of [MediaDeviceInfo]s describing available output devices.
   */
  override fun enumerateDevices(): List<MediaDeviceInfo> {

    val result = mutableListOf<MediaDeviceInfo>()

    for (d in audioManager.availableCommunicationDevices) {
      result.add(
          MediaDeviceInfo(
              d.id.toString(),
              d.productName.toString(),
              MediaDeviceKind.AUDIO_OUTPUT,
              AudioDeviceKind.fromSystem(d),
              failedDeviceIds.contains(d.id)))
    }

    return result
  }

  /**
   * Requests routing to the given communication device and waits for the confirmation.
   *
   * @param deviceId Device identifier (stringified [AudioDeviceInfo.id]).
   * @throws []GetUserMediaException] if routing fails to start.
   */
  override suspend fun setOutputAudioId(deviceId: String) {
    // String is used, because other platform use it, but it's supposed to be `AudioDeviceInfo.id`
    // on SDK >= 31.
    val desiredDeviceId = deviceId.toInt()

    val current = audioManager.communicationDevice
    if (current != null && current.id == desiredDeviceId) {
      return
    }

    setOutputAudioMutex.withLock {
      val current = audioManager.communicationDevice
      if (current != null && current.id == desiredDeviceId) {
        return
      }

      val newDevice =
          audioManager.availableCommunicationDevices.find { it.id == desiredDeviceId }
              ?: throw IllegalArgumentException("Unknown output device: $deviceId")

      // Prepare await of confirmation from `onCommunicationDeviceChanged`.
      val deferred = CompletableDeferred<Unit>()
      communicationDeviceChangedDeferred = deferred
      pendingCommunicationDeviceId = desiredDeviceId

      // Clear previous failure flag if we try again.
      failedDeviceIds.remove(desiredDeviceId)

      if (!audioManager.setCommunicationDevice(newDevice)) {
        pendingCommunicationDeviceId = null
        communicationDeviceChangedDeferred = null
        throw GetUserMediaException(
            "Failed to change audio device to " +
                "id = ${newDevice.id}, " +
                "type = ${newDevice.type}, " +
                "productName = ${newDevice.productName}",
            GetUserMediaException.Kind.Audio)
      }

      try {
        // Waiting for `onCommunicationDeviceChanged` with the desired device.
        try {
          withTimeout(DEVICE_CHANGE_TIMEOUT_MS) { deferred.await() }
        } catch (e: Exception) {
          throw GetUserMediaException(
              "Timeout changing communication device", GetUserMediaException.Kind.Audio)
        }
        // Mark as selected after confirmation.
        selectedDeviceId = desiredDeviceId
      } finally {
        // Clear pending state regardless of success/timeout.
        pendingCommunicationDeviceId = null
        communicationDeviceChangedDeferred = null
      }
    }
  }

  /**
   * Invoked by the system when output devices are added.
   *
   * @param addedDevices Array of added devices provided by the system.
   */
  override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo?>?) {
    maybeOnDeviceChanged()
  }

  /**
   * Invoked by the system when output devices are removed.
   *
   * Cleans up failure flags for removed devices and notifies observers if needed.
   *
   * @param removedDevices Array of removed devices provided by the system.
   */
  override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo?>?) {
    removedDevices?.forEach { d -> d?.let { failedDeviceIds.remove(it.id) } }
    maybeOnDeviceChanged()
  }

  /**
   * Invoked when the active communication device changes.
   *
   * Completes pending awaits and marks the previously selected devices as failed, if the system
   * reroutes unexpectedly while the device remains available.
   *
   * @param device The newly active communication device, or null if none.
   */
  override fun onCommunicationDeviceChanged(device: AudioDeviceInfo?) {
    val expectedId = pendingCommunicationDeviceId
    if (expectedId != null && device?.id == expectedId) {
      communicationDeviceChangedDeferred?.let { d -> if (!d.isCompleted) d.complete(Unit) }
      // The expected device became active - ensure it's not marked as failed.
      device?.id?.let { failedDeviceIds.remove(it) }
      return
    }

    // Unexpected reroute: previously selected device lost without a new selection request.
    val previouslySelected = selectedDeviceId
    if (previouslySelected != null && device?.id != previouslySelected) {
      selectedDeviceId = null
      if (!audioManager.availableCommunicationDevices.any { it.id == previouslySelected }) {
        // Device is gone, not failed.
        return
      }
      // Device still present, but system rerouted: mark as failed and notify.
      failedDeviceIds.add(previouslySelected)
      maybeOnDeviceChanged()
    }
  }

  /** Releases communication-device listener and invokes base cleanup. */
  override fun dispose() {
    audioManager.removeOnCommunicationDeviceChangedListener(this)
    super.dispose()
  }

  /**
   * Calls [OnDeviceChangeObs.onDeviceChange] if the enumerated list differs from the last reported
   * one.
   */
  private fun maybeOnDeviceChanged() {
    var newDevicesList = enumerateDevices()
    if (currentDevicesList != newDevicesList) {
      currentDevicesList = newDevicesList
      Handler(Looper.getMainLooper()).post { obs.onDeviceChange() }
    }
  }
}

/**
 * Pre-API 31 audio manager implementation based on legacy audio routing APIs:
 * [AudioManager.isSpeakerphoneOn], [AudioManager.startBluetoothSco],
 * [AudioManager.stopBluetoothSco].
 */
private class AudioDevicesLegacy(state: State, obs: OnDeviceChangeObs) : AudioDevices(state, obs) {
  /**
   * Logical legacy audio outputs exposed to Flutter on pre-31 devices.
   *
   * @property id String identifier used by the Flutter API.
   */
  enum class LegacyAudioDevice(val id: String) {
    /** Built-in ear speaker. */
    EAR_SPEAKER("ear-speaker"),

    /** Built-in loudspeaker. */
    SPEAKERPHONE("speakerphone"),

    /** Wired headset (with microphone). */
    WIRED_HEADSET("wired-headset"),

    /** Bluetooth SCO headset. */
    BLUETOOTH_HEADSET("bluetooth-headset"),
  }

  /** Cached bluetooth-headset connectivity used for enumeration. */
  private var isBluetoothHeadsetConnected: Boolean = false

  /** Cached wired-headset connectivity used for enumeration. */
  private var isWiredHeadsetConnected: Boolean = false

  /** Currently selected logical output. */
  private var selectedAudioOutputId: LegacyAudioDevice = LegacyAudioDevice.SPEAKERPHONE

  /** Deferred completed when Bluetooth SCO connects. */
  private var bluetoothScoDeferred: CompletableDeferred<Unit>? = null

  /** Deferred completed when Bluetooth SCO disconnects. */
  private var stopBluetoothScoDeferred: CompletableDeferred<Unit>? = null

  /** True when SCO audio state is connected. */
  private var scoAudioStateConnected: Boolean = false

  /** True if last SCO attempt failed. */
  private var isBluetoothScoFailed: Boolean = false

  /** Serializes concurrent routing changes to avoid races. */
  private var setOutputAudioMutex: Mutex = Mutex()

  /** Receiver for Bluetooth SCO audio state updates (connect/disconnect). */
  private val scoReceiver: BroadcastReceiver =
      object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
          ThreadUtils.checkIsOnMainThread()

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
                  Handler(Looper.getMainLooper()).post { obs.onDeviceChange() }
                }
              }
            }
          }
        }
      }

  init {
    // Register for SCO audio state changes and prime initial state.
    state.context.registerReceiver(
        scoReceiver, IntentFilter(AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED))
    synchronizeHeadsetState()
  }

  /**
   * Enumerates available legacy audio devices.
   *
   * @return List of [MediaDeviceInfo]s describing available audio devices.
   */
  override fun enumerateDevices(): List<MediaDeviceInfo> {
    val result =
        mutableListOf(
            MediaDeviceInfo(
                LegacyAudioDevice.SPEAKERPHONE.id,
                "Speakerphone",
                MediaDeviceKind.AUDIO_OUTPUT,
                AudioDeviceKind.SPEAKERPHONE,
                false))

    var bluetoothDevice: AudioDeviceInfo? = null
    for (device in audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
      if (bluetoothDevice == null && device.isBluetoothDevice()) {
        // Grab the first available devices.
        bluetoothDevice = device
      } else if (device.isWiredHeadset()) {
        isWiredHeadsetConnected = true
      }
    }

    if (bluetoothDevice != null) {
      result.add(
          MediaDeviceInfo(
              LegacyAudioDevice.BLUETOOTH_HEADSET.id,
              bluetoothDevice.productName.toString(),
              MediaDeviceKind.AUDIO_OUTPUT,
              AudioDeviceKind.BLUETOOTH_HEADSET,
              isBluetoothScoFailed))
    }

    result +=
        if (isWiredHeadsetConnected) {
          MediaDeviceInfo(
              LegacyAudioDevice.WIRED_HEADSET.id,
              "Wired headset",
              MediaDeviceKind.AUDIO_OUTPUT,
              AudioDeviceKind.WIRED_HEADSET,
              false)
        } else {
          MediaDeviceInfo(
              LegacyAudioDevice.EAR_SPEAKER.id,
              "Ear-speaker",
              MediaDeviceKind.AUDIO_OUTPUT,
              AudioDeviceKind.EAR_SPEAKER,
              false)
        }

    result.add(MediaDeviceInfo("default", "default", MediaDeviceKind.AUDIO_INPUT, null, false))
    return result
  }

  /**
   * Routes output to the specified legacy device, handling SCO as needed.
   *
   * @param deviceId One of [LegacyAudioDevice.id] values.
   * @throws [GetUserMediaException] if routing fails to start.
   */
  override suspend fun setOutputAudioId(deviceId: String) {
    var device = LegacyAudioDevice.entries.firstOrNull { it.id == deviceId }

    setOutputAudioMutex.withLock {
      when (device) {
        LegacyAudioDevice.WIRED_HEADSET, LegacyAudioDevice.EAR_SPEAKER -> {
          if (scoAudioStateConnected) {
            stopBluetoothSco()
          }
          audioManager.isSpeakerphoneOn = false
        }
        LegacyAudioDevice.SPEAKERPHONE -> {
          if (scoAudioStateConnected) {
            stopBluetoothSco()
          }
          audioManager.isSpeakerphoneOn = true
        }
        LegacyAudioDevice.BLUETOOTH_HEADSET -> {
          if (scoAudioStateConnected) {
            return
          }
          val deviceIdBefore = selectedAudioOutputId
          selectedAudioOutputId = device
          if (isBluetoothHeadsetConnected) {
            if (bluetoothScoDeferred == null) {
              isBluetoothScoFailed = false
              Log.d(TAG, "Bluetooth headset was selected. Trying to start Bluetooth SCO...")
              bluetoothScoDeferred = CompletableDeferred()
              audioManager.startBluetoothSco()
            }
            try {
              withTimeout(DEVICE_CHANGE_TIMEOUT_MS) { bluetoothScoDeferred?.await() }
            } catch (e: Exception) {
              selectedAudioOutputId = deviceIdBefore
              audioManager.stopBluetoothSco()
              isBluetoothScoFailed = true
              throw GetUserMediaException(
                  "Timeout connecting bluetooth headset", GetUserMediaException.Kind.Audio)
            }
          } else {
            throw GetUserMediaException(
                "Bluetooth headset is not connected", GetUserMediaException.Kind.Audio)
          }
        }
        else -> {
          throw GetUserMediaException(
              "Unknown output device: $deviceId", GetUserMediaException.Kind.Audio)
        }
      }
    }
  }

  /** Stops Bluetooth SCO and awaits disconnect. */
  private suspend fun stopBluetoothSco() {
    stopBluetoothScoDeferred = CompletableDeferred()
    audioManager.stopBluetoothSco()
    stopBluetoothScoDeferred?.await()
    audioManager.isBluetoothScoOn = false
    bluetoothScoDeferred?.completeExceptionally(
        GetUserMediaException(
            "Bluetooth headset connection request was cancelled", GetUserMediaException.Kind.Audio))
    bluetoothScoDeferred = null
  }

  /** Refreshes cached wired/bluetooth connectivity state. */
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

  /**
   * Updates wired headset connectivity and notifies on change.
   *
   * @param isConnected Indication whether a wired headset is connected.
   */
  private fun updateHasWiredHeadset(isConnected: Boolean) {
    if (isWiredHeadsetConnected != isConnected) {
      isWiredHeadsetConnected = isConnected
      Handler(Looper.getMainLooper()).post { obs.onDeviceChange() }
    }
  }

  /**
   * Updates Bluetooth headset connectivity and notifies on change.
   *
   * @param isConnected Indication whether a Bluetooth headset is connected.
   */
  private fun updateHasBluetoothHeadset(isConnected: Boolean) {
    if (isBluetoothHeadsetConnected != isConnected) {
      isBluetoothHeadsetConnected = isConnected
      Handler(Looper.getMainLooper()).post { obs.onDeviceChange() }
    }
  }

  /** Unregisters the SCO receiver and base listeners. */
  override fun dispose() {
    state.context.unregisterReceiver(scoReceiver)
    super.dispose()
  }

  /**
   * Recomputes headset state on device additions.
   *
   * @param addedDevices Array of added devices provided by the system.
   */
  override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo?>?) {
    synchronizeHeadsetState()
  }

  /**
   * Recomputes headset state on device removals.
   *
   * @param removedDevices Array of removed devices provided by the system.
   */
  override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo?>?) {
    synchronizeHeadsetState()
  }
}

/**
 * Indicates if this [AudioDeviceInfo] corresponds to a Bluetooth audio endpoint.
 *
 * @return True for Bluetooth SCO/A2DP and, on S+, BLE headset types.
 */
fun AudioDeviceInfo.isBluetoothDevice(): Boolean {
  return this.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
      this.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
      (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
          this.type == AudioDeviceInfo.TYPE_BLE_HEADSET)
}

/**
 * Indicates if this [AudioDeviceInfo] corresponds to a wired/USB audio device.
 *
 * @return True for wired headset/headphones and USB audio (including O+ USB headsets).
 */
fun AudioDeviceInfo.isWiredHeadset(): Boolean {
  return this.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
      this.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
      this.type == AudioDeviceInfo.TYPE_USB_DEVICE ||
      (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
          this.type == AudioDeviceInfo.TYPE_USB_HEADSET)
}
