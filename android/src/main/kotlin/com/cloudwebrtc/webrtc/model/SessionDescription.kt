package com.cloudwebrtc.webrtc.model

import org.webrtc.SessionDescription as WSessionDescription;

enum class SessionDescriptionType(val value: Int) {
    OFFER(0),
    PRANSWER(1),
    ANSWER(2),
    ROLLBACK(3);

    companion object {
        fun fromWebRtc(type: WSessionDescription.Type): SessionDescriptionType {
            return when (type) {
                WSessionDescription.Type.OFFER -> OFFER
                WSessionDescription.Type.PRANSWER -> PRANSWER
                WSessionDescription.Type.ANSWER -> ANSWER
                WSessionDescription.Type.ROLLBACK -> ROLLBACK
            }
        }

        fun fromInt(value: Int) = values().first { it.value == value }
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

        fun fromMap(map: Map<String, Any>): SessionDescription {
            val type = SessionDescriptionType.fromInt(map["type"] as Int)
            val description = map["description"] as String
            return SessionDescription(type, description)
        }
    }

    fun intoWebRtc(): WSessionDescription {
        return WSessionDescription(type.intoWebRtc(), description)
    }

    fun intoMap(): Map<String, Any> {
        return mapOf(
            "type" to type.value,
            "description" to description
        )
    }
}