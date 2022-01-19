package com.cloudwebrtc.webrtc.model

enum class MediaDeviceKind(val value: Int) {
    AUDIO_INPUT(0),
    AUDIO_OUTPUT(1),
    VIDEO_INPUT(2),
    VIDEO_OUTPUT(3);
}

data class MediaDeviceInfo(val deviceId: String, val label: String, val kind: MediaDeviceKind) {
    fun intoMap(): Map<String, Any> = mapOf(
        "deviceId" to deviceId,
        "label" to label,
        "kind" to kind.value
    )
}