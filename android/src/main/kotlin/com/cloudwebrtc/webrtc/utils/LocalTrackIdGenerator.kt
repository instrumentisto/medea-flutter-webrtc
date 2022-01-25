package com.cloudwebrtc.webrtc.utils

object LocalTrackIdGenerator {
    private var lastId: Int = 0;

    fun nextId(): String {
        return "local-" + lastId++.toString()
    }
}