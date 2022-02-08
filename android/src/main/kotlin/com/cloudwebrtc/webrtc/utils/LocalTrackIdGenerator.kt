package com.cloudwebrtc.webrtc.utils

/**
 * Generates unique IDs for the local media tracks.
 */
object LocalTrackIdGenerator {
    /**
     * Last created unique ID.
     */
    private var lastId: Int = 0;

    /**
     * @return new unique ID for the local track.
     */
    fun nextId(): String {
        return "local-" + lastId++.toString()
    }
}