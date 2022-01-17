package com.cloudwebrtc.webrtc.model

import org.webrtc.IceCandidate as WIceCandidate;

data class IceCandidate(val sdpMid: String, val sdpMLineIndex: Int, val sdp: String) {
    companion object {
        fun fromMap(map: Map<String, Any>): IceCandidate {
            return IceCandidate(
                map["sdpMid"] as String,
                map["sdpMLineIndex"] as Int,
                map["sdp"] as String
            )
        }
    }

    fun intoWebRtc(): WIceCandidate {
        return WIceCandidate(sdpMid, sdpMLineIndex, sdp)
    }
}