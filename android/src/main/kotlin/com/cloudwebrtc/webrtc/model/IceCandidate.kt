package com.cloudwebrtc.webrtc.model

import org.webrtc.IceCandidate as WIceCandidate

/**
 * Representation of the [org.webrtc.IceCandidate].
 *
 * @property sdpMid mid of this [IceCandidate].
 * @property sdpMLineIndex sdpMLineIndex of this [IceCandidate].
 * @property sdp  SDP of this [IceCandidate].
 */
data class IceCandidate(val sdpMid: String, val sdpMLineIndex: Int, val sdp: String) {
    companion object {
        /**
         * Creates new [IceCandidate] object based on the method call received from the Flutter.
         *
         * @return [IceCandidate] created from the provided [Map].
         */
        fun fromMap(map: Map<String, Any>): IceCandidate {
            return IceCandidate(
                    map["sdpMid"] as String,
                    map["sdpMLineIndex"] as Int,
                    map["sdp"] as String
            )
        }

        /**
         * Converts provided [org.webrtc.IceCandidate] into [IceCandidate].
         *
         * @return [IceCandidate] created based on the provided [org.webrtc.IceCandidate].
         */
        fun fromWebRtc(from: WIceCandidate): IceCandidate =
                IceCandidate(from.sdpMid, from.sdpMLineIndex, from.sdp)

    }

    /**
     * Converts this [IceCandidate] to the [org.webrtc.IceCandidate].
     *
     * @return [org.webrtc.IceCandidate] created based on this [IceCandidate].
     */
    fun intoWebRtc(): WIceCandidate {
        return WIceCandidate(sdpMid, sdpMLineIndex, sdp)
    }

    /**
     * Converts this [IceCandidate] into [Map] which can be returned to the Flutter side.
     */
    fun intoMap(): Map<String, Any> = mapOf(
            "sdpMid" to sdpMid,
            "sdpMLineIndex" to sdpMLineIndex,
            "sdp" to sdp
    )
}