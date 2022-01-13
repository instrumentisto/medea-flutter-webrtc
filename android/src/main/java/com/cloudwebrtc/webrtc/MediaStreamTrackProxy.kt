package com.cloudwebrtc.webrtc

import org.webrtc.MediaStreamTrack

class MediaStreamTrackProxy(track: MediaStreamTrack) : IWebRTCProxy<MediaStreamTrack> {
    override var obj: MediaStreamTrack = track;

    override fun syncWithObject() {}

    override fun dispose() {
        TODO("Not yet implemented")
    }

    fun state() : MediaStreamTrackState {
        return MediaStreamTrackState.fromWebRtcState(obj.state());
    }

    fun setEnabled(enabled: Boolean) {
        obj.setEnabled(enabled);
    }
}