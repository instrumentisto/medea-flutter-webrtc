package com.cloudwebrtc.webrtc.controller

import java.util.concurrent.atomic.AtomicLong

/**
 * Interface for the all controllers with unique IDs.
 */
internal interface IdentifiableController {
    companion object {
        /**
         * Last unique ID created for the [IdentifiableController].
         */
        private var counter: Long = 0;
    }

    /**
     * @return new unique ID for the [IdentifiableController]'s channel.
     */
    fun nextChannelId(): Long {
        return counter++;
    }
}