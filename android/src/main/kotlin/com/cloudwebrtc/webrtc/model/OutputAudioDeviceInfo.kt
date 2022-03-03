package com.cloudwebrtc.webrtc.model

/**
 * Kind of the [OutputAudioDeviceInfo].
 */
enum class OutputAudioDeviceKind(val value: Int) {
    /**
     * Audio will be played on the ear speaker.
     */
    EAR_SPEAKER(0),

    /**
     * Audio will be played on the speakerphone.
     */
    SPEAKERPHONE(1),

    /**
     * Audio will be played on the bluetooth headset if it possible.
     */
    BLUETOOTH_HEADSET(2);
}

/**
 * Information about some output audio device.
 *
 * @property deviceId  Identifier of the represented device.
 * @property label  Human-readable device description (for example, "Ear speaker").
 * @property kind  Kind of the device.
 */
data class OutputAudioDeviceInfo(
    val deviceId: String,
    val label: String,
    val kind: OutputAudioDeviceKind
) {
    /**
     * Converts this [MediaDeviceInfo] into a [Map] which can be returned to the
     * Flutter side.
     */
    fun asFlutterResult(): Map<String, Any> = mapOf(
        "deviceId" to deviceId,
        "label" to label,
        "kind" to kind.value
    )
}
