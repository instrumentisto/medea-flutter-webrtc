package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.SignalingState as WSignalingState

enum class SignalingState(val value: Int) {
    STABLE(0),
    HAVE_LOCAL_OFFER(1),
    HAVE_LOCAL_PRANSWER(2),
    HAVE_REMOTE_OFFER(3),
    HAVE_REMOTE_PRANSWER(4),
    CLOSED(4);

    companion object {
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