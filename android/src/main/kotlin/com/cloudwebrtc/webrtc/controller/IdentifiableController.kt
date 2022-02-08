package com.cloudwebrtc.webrtc.controller

/**
 * Interface for the all controllers with unique IDs.
 */
internal interface IdentifiableController {
    companion object {
        /**
         * Last unique ID created for the [IdentifiableController].
         */
        private var lastChannelId: Int = 0
    }

    /**
     * @return new unique ID for the [IdentifiableController]'s channel.
     */
    fun nextChannelId(): Int {
        return lastChannelId++
    }
}