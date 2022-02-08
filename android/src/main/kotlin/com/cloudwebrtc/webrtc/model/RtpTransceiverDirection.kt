package com.cloudwebrtc.webrtc.model

import org.webrtc.RtpTransceiver

/**
 * Representation of the [RtpTransceiver.RtpTransceiverDirection].
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class RtpTransceiverDirection(val value: Int) {
    /**
     * Indicates that Transceiver is both sending to and receiving from the remote peer connection.
     */
    SEND_RECV(0),

    /**
     * Indicates that Transceiver is sending to the remote peer, but is not receiving
     * any media from the remote peer.
     */
    SEND_ONLY(1),

    /**
     * Indicates that Transceiver is receiving from the remote peer, but is
     * not sending any media to the remote peer.
     */
    RECV_ONLY(2),

    /**
     * Indicates that Transceiver is inactive, neither sending nor receiving any media data.
     */
    INACTIVE(3);

    companion object {
        /**
         * Converts provided [RtpTransceiver.RtpTransceiverDirection] into [RtpTransceiverDirection].
         *
         * @return [RtpTransceiverDirection] created based on the
         * provided [RtpTransceiver.RtpTransceiverDirection].
         */
        fun fromWebRtc(direction: RtpTransceiver.RtpTransceiverDirection): RtpTransceiverDirection {
            return when (direction) {
                RtpTransceiver.RtpTransceiverDirection.SEND_RECV -> SEND_RECV
                RtpTransceiver.RtpTransceiverDirection.SEND_ONLY -> SEND_ONLY
                RtpTransceiver.RtpTransceiverDirection.RECV_ONLY -> RECV_ONLY
                RtpTransceiver.RtpTransceiverDirection.INACTIVE -> INACTIVE
            }
        }

        /**
         * Tries to create [RtpTransceiverDirection] based on the provided [Int].
         *
         * @param value [Int] value from which [RtpTransceiverDirection] will be created.
         * @return [RtpTransceiverDirection] based on the provided [Int].
         */
        fun fromInt(value: Int) = values().first { it.value == value }
    }

    /**
     * Converts this [RtpTransceiverDirection] into [RtpTransceiver.RtpTransceiverDirection].
     *
     * @return [RtpTransceiver.RtpTransceiverDirection] based on this [RtpTransceiverDirection].
     */
    fun intoWebRtc(): RtpTransceiver.RtpTransceiverDirection {
        return when (this) {
            SEND_RECV -> RtpTransceiver.RtpTransceiverDirection.SEND_RECV
            SEND_ONLY -> RtpTransceiver.RtpTransceiverDirection.SEND_ONLY
            RECV_ONLY -> RtpTransceiver.RtpTransceiverDirection.RECV_ONLY
            INACTIVE -> RtpTransceiver.RtpTransceiverDirection.INACTIVE
        }
    }
}