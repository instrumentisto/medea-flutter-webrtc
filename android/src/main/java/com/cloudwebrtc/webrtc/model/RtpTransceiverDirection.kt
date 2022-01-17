package com.cloudwebrtc.webrtc.model

import org.webrtc.RtpTransceiver

enum class RtpTransceiverDirection(val value: Int) {
    SEND_RECV(0),
    SEND_ONLY(1),
    RECV_ONLY(2),
    INACTIVE(3);

    companion object {
        fun fromWebRtc(direction: RtpTransceiver.RtpTransceiverDirection): RtpTransceiverDirection {
            return when (direction) {
                RtpTransceiver.RtpTransceiverDirection.SEND_RECV -> SEND_RECV
                RtpTransceiver.RtpTransceiverDirection.SEND_ONLY -> SEND_ONLY
                RtpTransceiver.RtpTransceiverDirection.RECV_ONLY -> RECV_ONLY
                RtpTransceiver.RtpTransceiverDirection.INACTIVE -> INACTIVE
            }
        }

        fun fromInt(value: Int) = values().first { it.value == value }
    }

    fun intoWebRtc(): RtpTransceiver.RtpTransceiverDirection {
        return when (this) {
            SEND_RECV -> RtpTransceiver.RtpTransceiverDirection.SEND_RECV
            SEND_ONLY -> RtpTransceiver.RtpTransceiverDirection.SEND_ONLY
            RECV_ONLY -> RtpTransceiver.RtpTransceiverDirection.RECV_ONLY
            INACTIVE -> RtpTransceiver.RtpTransceiverDirection.INACTIVE
        }
    }
}