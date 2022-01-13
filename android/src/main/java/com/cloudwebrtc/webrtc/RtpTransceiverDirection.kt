package com.cloudwebrtc.webrtc

import org.webrtc.RtpTransceiver

enum class RtpTransceiverDirection {
    SEND_RECV,
    SEND_ONLY,
    RECV_ONLY,
    INACTIVE;

    companion object {
        fun fromWebRtc(direction : RtpTransceiver.RtpTransceiverDirection) : RtpTransceiverDirection {
            return when (direction) {
                RtpTransceiver.RtpTransceiverDirection.SEND_RECV -> SEND_RECV
                RtpTransceiver.RtpTransceiverDirection.SEND_ONLY -> SEND_ONLY
                RtpTransceiver.RtpTransceiverDirection.RECV_ONLY -> RECV_ONLY
                RtpTransceiver.RtpTransceiverDirection.INACTIVE -> INACTIVE
            }
        }
    }

    fun intoWebRtc() : RtpTransceiver.RtpTransceiverDirection {
        return when (this) {
            SEND_RECV -> RtpTransceiver.RtpTransceiverDirection.SEND_RECV
            SEND_ONLY -> RtpTransceiver.RtpTransceiverDirection.SEND_ONLY
            RECV_ONLY -> RtpTransceiver.RtpTransceiverDirection.RECV_ONLY
            INACTIVE -> RtpTransceiver.RtpTransceiverDirection.INACTIVE
        }
    }
}