package com.cloudwebrtc.webrtc.model

import org.webrtc.RtpTransceiver.RtpTransceiverInit as WRtpTransceiverInit;

/**
 * Representation of the [org.webrtc.RtpTransceiver.RtpTransceiverInit].
 *
 * @property direction direction of Transceiver which will be created from this config.
 */
data class RtpTransceiverInit(val direction: RtpTransceiverDirection) {
    companion object {
        /**
         * Creates new [RtpTransceiverInit] object based on the method call received from the Flutter.
         *
         * @return [RtpTransceiverInit] created from the provided [Map].
         */
        fun fromMap(map: Map<String, Any>): RtpTransceiverInit {
            return RtpTransceiverInit(RtpTransceiverDirection.fromInt(map["direction"] as Int))
        }
    }

    /**
     * Converts this [RtpTransceiverInit] to the [org.webrtc.RtpTransceiver.RtpTransceiverInit].
     *
     * @return [org.webrtc.RtpTransceiver.RtpTransceiverInit] created based on
     * this [RtpTransceiverInit].
     */
    fun intoWebRtc(): WRtpTransceiverInit {
        return WRtpTransceiverInit(direction.intoWebRtc())
    }
}