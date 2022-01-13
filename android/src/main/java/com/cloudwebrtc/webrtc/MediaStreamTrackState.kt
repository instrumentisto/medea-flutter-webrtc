package com.cloudwebrtc.webrtc

import org.webrtc.MediaStreamTrack

enum class MediaStreamTrackState {
    ENDED,
    LIVE;

    companion object {
        fun fromWebRtcState(state : MediaStreamTrack.State) : MediaStreamTrackState {
            return when (state) {
                MediaStreamTrack.State.ENDED -> ENDED
                MediaStreamTrack.State.LIVE -> LIVE
            }
        }
    }
}