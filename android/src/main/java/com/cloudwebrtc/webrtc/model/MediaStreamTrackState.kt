package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaStreamTrack

enum class MediaStreamTrackState(val value: Int) {
    ENDED(0),
    LIVE(1);

    companion object {
        fun fromWebRtcState(state : MediaStreamTrack.State) : MediaStreamTrackState {
            return when (state) {
                MediaStreamTrack.State.ENDED -> ENDED
                MediaStreamTrack.State.LIVE -> LIVE
            }
        }
    }

    fun intoFlutterResult(): Int {
        return value
    }
}