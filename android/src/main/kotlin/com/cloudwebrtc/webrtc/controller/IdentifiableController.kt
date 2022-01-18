package com.cloudwebrtc.webrtc.controller

internal interface IdentifiableController {
    companion object {
        private var lastChannelId: Int = 0
    }

    fun nextChannelId(): Int {
        return lastChannelId++
    }
}