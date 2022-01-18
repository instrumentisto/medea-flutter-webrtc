package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceGatheringState as WIceGatheringState

enum class IceGatheringState(val value: Int) {
    NEW(0),
    GATHERING(1),
    COMPLETE(2);

    companion object {
        fun fromWebRtc(from: WIceGatheringState): IceGatheringState {
            return when (from) {
                WIceGatheringState.NEW -> NEW
                WIceGatheringState.GATHERING -> GATHERING
                WIceGatheringState.COMPLETE -> COMPLETE
            }
        }
    }
}