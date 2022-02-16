package com.cloudwebrtc.webrtc.controller

import org.webrtc.ThreadUtils

/**
 * Interface for the all controllers with unique IDs.
 */
internal interface IdentifiableController {
    companion object {
        /**
         * Last unique ID created for the [IdentifiableController].
         */
        private var counter: Long = 0
    }

    /**
     * @return new unique ID for the [IdentifiableController]'s channel.
     */
    fun nextChannelId(): Long {
        ThreadUtils.checkIsOnMainThread()
        return counter++
    }
}