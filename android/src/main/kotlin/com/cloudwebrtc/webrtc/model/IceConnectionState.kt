package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceConnectionState as WIceConnectionState

enum class IceConnectionState(val value: Int) {
    NEW(0),
    CHECKING(1),
    CONNECTED(2),
    COMPLETED(3),
    FAILED(4),
    DISCONNECTED(5),
    CLOSED(6);

    companion object {
        fun fromWebRtc(from: WIceConnectionState): IceConnectionState {
            return when (from) {
                WIceConnectionState.NEW -> NEW
                WIceConnectionState.CHECKING -> CHECKING
                WIceConnectionState.CONNECTED -> CONNECTED
                WIceConnectionState.COMPLETED -> COMPLETED
                WIceConnectionState.FAILED -> FAILED
                WIceConnectionState.DISCONNECTED -> DISCONNECTED
                WIceConnectionState.CLOSED -> CLOSED
            }
        }
    }
}