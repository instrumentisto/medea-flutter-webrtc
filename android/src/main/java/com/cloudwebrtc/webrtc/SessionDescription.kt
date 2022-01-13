package com.cloudwebrtc.webrtc

import org.webrtc.SessionDescription as WSessionDescription;

enum class SessionDescriptionType {
    OFFER,
    PRANSWER,
    ANSWER,
    ROLLBACK;

    companion object {
        fun fromWebRtc(type: WSessionDescription.Type): SessionDescriptionType {
            return when (type) {
                WSessionDescription.Type.OFFER -> OFFER
                WSessionDescription.Type.PRANSWER -> PRANSWER
                WSessionDescription.Type.ANSWER -> ANSWER
                WSessionDescription.Type.ROLLBACK -> ROLLBACK
            }
        }
    }

    fun intoWebRtc(): WSessionDescription.Type {
        return when (this) {
            OFFER -> WSessionDescription.Type.OFFER
            PRANSWER -> WSessionDescription.Type.PRANSWER
            ANSWER -> WSessionDescription.Type.ANSWER
            ROLLBACK -> WSessionDescription.Type.ROLLBACK
        }
    }
}

data class SessionDescription(val type: SessionDescriptionType, val description: String) {
    companion object {
        fun fromWebRtc(sdp: WSessionDescription): SessionDescription {
            return SessionDescription(
                    SessionDescriptionType.fromWebRtc(sdp.type),
                    sdp.description
            );
        }
    }

    fun intoWebRtc(): WSessionDescription {
        return WSessionDescription(type.intoWebRtc(), description)
    }
}