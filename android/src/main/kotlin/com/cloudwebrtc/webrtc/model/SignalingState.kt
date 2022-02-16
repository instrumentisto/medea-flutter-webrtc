package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.SignalingState as WSignalingState

/**
 * Representation of the [org.webrtc.PeerConnection.SignalingState].
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class SignalingState(val value: Int) {
    /**
     * Indicates that there is no ongoing exchange of offer and answer underway.
     */
    STABLE(0),

    /**
     * Indicates that local peer has called `RTCPeerConnection.setLocalDescription()`.
     */
    HAVE_LOCAL_OFFER(1),

    /**
     * Indicates that offer sent by the remote peer has been applied and an answer has been created.
     */
    HAVE_LOCAL_PRANSWER(2),

    /**
     * Indicates that remote peer has created an offer and used the signaling server to deliver it
     * to the local peer, which has set the offer as the remote description by calling
     * `PeerConnection.setRemoteDescription()`.
     */
    HAVE_REMOTE_OFFER(3),

    /**
     * Indicates that provisional answer has been received and successfully applied in response to
     * an offer previously sent and established
     */
    HAVE_REMOTE_PRANSWER(4),

    /**
     * Indicates that peer was closed.
     */
    CLOSED(5);

    companion object {
        /**
         * Converts provided [org.webrtc.PeerConnection.SignalingState] into [SignalingState].
         *
         * @return [SignalingState] created based on the
         * provided [org.webrtc.PeerConnection.SignalingState].
         */
        fun fromWebRtc(from: WSignalingState): SignalingState {
            return when (from) {
                WSignalingState.STABLE -> STABLE
                WSignalingState.HAVE_LOCAL_OFFER -> HAVE_LOCAL_OFFER
                WSignalingState.HAVE_LOCAL_PRANSWER -> HAVE_LOCAL_PRANSWER
                WSignalingState.HAVE_REMOTE_OFFER -> HAVE_REMOTE_OFFER
                WSignalingState.HAVE_REMOTE_PRANSWER -> HAVE_REMOTE_PRANSWER
                WSignalingState.CLOSED -> CLOSED
            }
        }
    }
}