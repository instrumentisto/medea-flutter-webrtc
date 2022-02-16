package com.cloudwebrtc.webrtc.model

/**
 * Media device kind.
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class MediaDeviceKind(val value: Int) {
    /**
     * Represents an audio input device; for example a microphone.
     */
    AUDIO_INPUT(0),

    /**
     * Represents an audio output device; for example a pair of headphones.
     */
    AUDIO_OUTPUT(1),

    /**
     * Represents a video input device; for example a webcam.
     */
    VIDEO_INPUT(2),
}

/**
 * The [MediaDeviceInfo] provides information about some media device.
 *
 * @property deviceId identifier of the represented device.
 * @property label human readable device description (for example "External USB Webcam").
 * @property kind media kind of device (for example audioinput for microphone).
 */
data class MediaDeviceInfo(
    val deviceId: String,
    val label: String,
    val kind: MediaDeviceKind
) {
    /**
     * Converts this [MediaDeviceInfo] into [Map] which can be returned to the Flutter side.
     */
    fun asFlutterResult(): Map<String, Any> = mapOf(
        "deviceId" to deviceId,
        "label" to label,
        "kind" to kind.value
    )
}