package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.PeerConnectionState as WPeerConnectionState

enum class PeerConnectionState(val value: Int) {
    NEW(0),
    CONNECTING(1),
    CONNECTED(2),
    DISCONNECTED(3),
    FAILED(4),
    CLOSED(5);

    companion object {
        fun fromWebRtc(from: WPeerConnectionState): PeerConnectionState {
            return when (from) {
                WPeerConnectionState.NEW -> NEW
                WPeerConnectionState.CONNECTING -> CONNECTING
                WPeerConnectionState.CONNECTED -> CONNECTED
                WPeerConnectionState.DISCONNECTED -> DISCONNECTED
                WPeerConnectionState.FAILED -> FAILED
                WPeerConnectionState.CLOSED -> CLOSED
            }
        }
    }
}