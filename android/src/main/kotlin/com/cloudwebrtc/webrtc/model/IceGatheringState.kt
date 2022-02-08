package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceGatheringState as WIceGatheringState

/**
 * Representation of the [org.webrtc.PeerConnection.IceGatheringState].
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class IceGatheringState(val value: Int) {
    NEW(0),
    GATHERING(1),
    COMPLETE(2);

    companion object {
        /**
         * Converts provided [org.webrtc.PeerConnection.IceGatheringState] into [IceGatheringState].
         *
         * @return [IceGatheringState] created based on the provided [org.webrtc.PeerConnection.IceGatheringState].
         */
        fun fromWebRtc(from: WIceGatheringState): IceGatheringState {
            return when (from) {
                WIceGatheringState.NEW -> NEW
                WIceGatheringState.GATHERING -> GATHERING
                WIceGatheringState.COMPLETE -> COMPLETE
            }
        }
    }
}