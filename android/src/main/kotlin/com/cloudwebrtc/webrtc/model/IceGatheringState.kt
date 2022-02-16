package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceGatheringState as WIceGatheringState

/**
 * Representation of the [org.webrtc.PeerConnection.IceGatheringState].
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class IceGatheringState(val value: Int) {
    /**
     * The peer connection was just created and hasn't done any networking yet.
     */
    NEW(0),

    /**
     * The ICE agent is in the process of gathering candidates for the connection.
     */
    GATHERING(1),

    /**
     * The ICE agent has finished gathering candidates. If something happens that requires
     * collecting new candidates, such as a new interface being added or the addition of a
     * new ICE server, the state will revert to gathering to gather those candidates.
     */
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