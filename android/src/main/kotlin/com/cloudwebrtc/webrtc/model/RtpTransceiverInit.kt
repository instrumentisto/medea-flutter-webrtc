package com.cloudwebrtc.webrtc.model

import org.webrtc.RtpTransceiver.RtpTransceiverInit as WRtpTransceiverInit;

data class RtpTransceiverInit(val direction: RtpTransceiverDirection) {
    companion object {
        fun fromMap(map: Map<String, Any>): RtpTransceiverInit {
            return RtpTransceiverInit(RtpTransceiverDirection.fromInt(map["direction"] as Int))
        }
    }

    fun intoWebRtc(): WRtpTransceiverInit {
        return WRtpTransceiverInit(direction.intoWebRtc())
    }
}