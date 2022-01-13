package com.cloudwebrtc.webrtc

import org.webrtc.RtpTransceiver.RtpTransceiverInit as WRtpTransceiverInit;

data class RtpTransceiverInit(val direction: RtpTransceiverDirection) {
    fun intoWebRtc(): WRtpTransceiverInit {
        return WRtpTransceiverInit(direction.intoWebRtc())
    }
}