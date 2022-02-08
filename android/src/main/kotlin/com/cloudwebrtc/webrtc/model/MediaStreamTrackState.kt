package com.cloudwebrtc.webrtc.model

import org.webrtc.MediaStreamTrack

/**
 * Representation of the [MediaStreamTrack] readiness.
 *
 * @property value [Int] representation of this enum which will be expected on Flutter side.
 */
enum class MediaStreamTrackState(val value: Int) {
    /**
     * Indicates that the input is not giving any more data and will never provide new data.
     */
    ENDED(0),

    /**
     * Indicates that an input is connected and does its best-effort in providing real-time data.
     */
    LIVE(1);

    companion object {
        /**
         * Converts provided [MediaStreamTrack.State] into [MediaStreamTrackState].
         */
        fun fromWebRtcState(state: MediaStreamTrack.State): MediaStreamTrackState {
            return when (state) {
                MediaStreamTrack.State.ENDED -> ENDED
                MediaStreamTrack.State.LIVE -> LIVE
            }
        }
    }
}