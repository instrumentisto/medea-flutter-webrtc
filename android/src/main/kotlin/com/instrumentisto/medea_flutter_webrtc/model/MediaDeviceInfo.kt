package com.instrumentisto.medea_flutter_webrtc.model

import android.media.AudioDeviceInfo
import android.util.Log

private val TAG = MediaDeviceKind::class.java.simpleName

/**
 * Media device kind.
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class MediaDeviceKind(val value: Int) {
  /** Represents an audio input device (for example, a microphone). */
  AUDIO_INPUT(0),

  /** Represents an audio output device (for example, a pair of headphones). */
  AUDIO_OUTPUT(1),

  /** Represents a video input device (for example, a webcam). */
  VIDEO_INPUT(2),
}

/**
 * Audio-specific classification of device types.
 *
 * This enum refines `MediaDeviceKind.AUDIO_*` with more granular categories (e.g., distinguishing
 * Bluetooth headset vs. headphones), allowing the Flutter side to present appropriate UI and
 * behavior.
 *
 * @property value Integer value serialized to Flutter.
 */
enum class AudioDeviceKind(val value: Int) {
  /** Built-in earpiece speaker. */
  EAR_SPEAKER(0),

  /** Built-in loudspeaker. */
  SPEAKERPHONE(1),

  /** Wired headphones without microphone. */
  WIRED_HEADPHONES(2),

  /** Wired headset with a microphone. */
  WIRED_HEADSET(3),

  /** USB headphones without microphone. */
  USB_HEADPHONES(4),

  /** USB headset with a microphone. */
  USB_HEADSET(5),

  /** Bluetooth headphones profile (A2DP/BLE speaker). */
  BLUETOOTH_HEADPHONES(6),

  /** Bluetooth headset profile suitable for calls (SCO/BLE headset). */
  BLUETOOTH_HEADSET(7);

  companion object {
    /**
     * Maps a platform `AudioDeviceInfo` to an `AudioDeviceKind` where applicable.
     *
     * @param device System device descriptor to map.
     * @return Matching `AudioDeviceKind`, or null if the type is not recognized/supported.
     */
    fun fromSystem(device: AudioDeviceInfo): AudioDeviceKind? {
      return when (device.type) {
        AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> {
          EAR_SPEAKER
        }
        AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> {
          SPEAKERPHONE
        }
        AudioDeviceInfo.TYPE_WIRED_HEADPHONES -> {
          WIRED_HEADPHONES
        }
        AudioDeviceInfo.TYPE_WIRED_HEADSET -> {
          WIRED_HEADSET
        }
        AudioDeviceInfo.TYPE_USB_HEADSET -> {
          USB_HEADSET
        }
        AudioDeviceInfo.TYPE_BLE_SPEAKER -> {
          BLUETOOTH_HEADPHONES
        }
        AudioDeviceInfo.TYPE_BLE_HEADSET, AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> {
          BLUETOOTH_HEADSET
        }
        else -> {
          Log.i(
              TAG,
              "Could not parse communication device: " +
                  "type = ${device.type}, " +
                  "name = ${device.productName}," +
                  "source = ${device.isSource}," +
                  "sink = ${device.isSink}")
          null
        }
      }
    }
  }
}

/**
 * Represents an information about some media device.
 *
 * @property deviceId Identifier of the represented media device.
 * @property label Human-readable device description (for example, "External USB Webcam").
 * @property kind Media kind of the media device.
 * @property audioKind Additional information on the nature of an audio device.
 * @property isFailed Flag indicating whether the last attempt to use this device failed.
 */
data class MediaDeviceInfo(
    val deviceId: String,
    val label: String,
    val kind: MediaDeviceKind,
    val audioKind: AudioDeviceKind?,
    val isFailed: Boolean
) {
  /** Converts this [MediaDeviceInfo] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> = buildMap {
    put("deviceId", deviceId)
    put("label", label)
    put("kind", kind.value)
    audioKind?.let { put("audioKind", it.value) }
    put("isFailed", isFailed)
  }

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as MediaDeviceInfo

    if (isFailed != other.isFailed) return false
    if (deviceId != other.deviceId) return false
    if (label != other.label) return false
    if (kind != other.kind) return false
    if (audioKind != other.audioKind) return false

    return true
  }

  override fun hashCode(): Int {
    var result = isFailed.hashCode()
    result = 31 * result + deviceId.hashCode()
    result = 31 * result + label.hashCode()
    result = 31 * result + kind.hashCode()
    result = 31 * result + (audioKind?.hashCode() ?: 0)
    return result
  }
}
