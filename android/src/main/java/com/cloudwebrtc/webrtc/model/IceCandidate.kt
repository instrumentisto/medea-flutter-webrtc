package com.cloudwebrtc.webrtc.model

import org.webrtc.IceCandidate as WIceCandidate;

data class IceCandidate(val sdpMid: String, val sdpMLineIndex: Int, val sdp: String) {
    fun intoWebRtc(): WIceCandidate {
        return WIceCandidate(sdpMid, sdpMLineIndex, sdp)
    }
}