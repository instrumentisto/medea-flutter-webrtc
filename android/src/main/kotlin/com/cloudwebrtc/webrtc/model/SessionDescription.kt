package com.cloudwebrtc.webrtc.model

import org.webrtc.SessionDescription as WSessionDescription

/**
 * Representation of the [org.webrtc.SessionDescription.Type].
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class SessionDescriptionType(val value: Int) {
    /**
     * Indicates that description is the initial proposal in an offer/answer exchange.
     */
    OFFER(0),

    /**
     * Indicates that the description is a provisional answer and may be changed when
     * the definitive choice will be given.
     */
    PRANSWER(1),

    /**
     * Indicates that description is the definitive choice in an offer/answer exchange.
     */
    ANSWER(2),

    /**
     * Indicates that description rolls back to offer/answer state to the last stable state.
     */
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

        /**
         * Tries to create [SessionDescriptionType] based on the provided [Int].
         *
         * @param value [Int] value from which [SessionDescriptionType] will be created.
         * @return [SessionDescriptionType] based on the provided [Int].
         */
        fun fromInt(value: Int) = values().first { it.value == value }
    }

    /**
     * Converts this [SessionDescriptionType] into [org.webrtc.SessionDescription.Type].
     *
     * @return [org.webrtc.SessionDescription.Type] based on this [SessionDescriptionType].
     */
    fun intoWebRtc(): WSessionDescription.Type {
        return when (this) {
            OFFER -> WSessionDescription.Type.OFFER
            PRANSWER -> WSessionDescription.Type.PRANSWER
            ANSWER -> WSessionDescription.Type.ANSWER
            ROLLBACK -> WSessionDescription.Type.ROLLBACK
        }
    }
}

/**
 * Representation of the [org.webrtc.SessionDescription].
 *
 * @property type type of this [SessionDescription].
 * @property description SDP of this [SessionDescription].
 */
data class SessionDescription(val type: SessionDescriptionType, val description: String) {
    companion object {
        /**
         * Converts provided [org.webrtc.SessionDescription] into [SessionDescription].
         *
         * @return [SessionDescription] created based on
         * the provided [org.webrtc.SessionDescription].
         */
        fun fromWebRtc(sdp: WSessionDescription): SessionDescription {
            return SessionDescription(
                    SessionDescriptionType.fromWebRtc(sdp.type),
                    sdp.description
            )
        }

        /**
         * Creates new [SessionDescription] object based on the method call
         * received from the Flutter.
         *
         * @return [SessionDescription] created from the provided [Map].
         */
        fun fromMap(map: Map<String, Any>): SessionDescription {
            val type = SessionDescriptionType.fromInt(map["type"] as Int)
            val description = map["description"] as String
            return SessionDescription(type, description)
        }
    }

    /**
     * Converts this [SessionDescription] to the [org.webrtc.SessionDescription].
     *
     * @return [org.webrtc.SessionDescription] created based on this [SessionDescription].
     */
    fun intoWebRtc(): WSessionDescription {
        return WSessionDescription(type.intoWebRtc(), description)
    }

    /**
     * Converts this [SessionDescription] into [Map] which can be returned to the Flutter side.
     */
    fun intoMap(): Map<String, Any> {
        return mapOf(
                "type" to type.value,
                "description" to description
        )
    }
}