package com.cloudwebrtc.webrtc.model

// TODO(evdokimovs): More deviceInfo pls
data class MediaDeviceInfo(val deviceId: String) {
    fun intoMap(): Map<String, Any> = mapOf(
        "deviceId" to deviceId
    )
}