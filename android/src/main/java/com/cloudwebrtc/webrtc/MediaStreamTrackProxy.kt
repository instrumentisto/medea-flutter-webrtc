package com.cloudwebrtc.webrtc

import org.webrtc.MediaStreamTrack

class MediaStreamTrackProxy(track: MediaStreamTrack) : IWebRTCProxy<MediaStreamTrack> {
    override var obj: MediaStreamTrack = track;

    private var onStopSubscribers: MutableList<() -> Unit> = mutableListOf()

    override fun syncWithObject() {}

    override fun dispose() {
        obj.dispose()
    }

    fun stop() {
        onStopSubscribers.forEach { sub -> sub() }
    }

    fun state() : MediaStreamTrackState {
        return MediaStreamTrackState.fromWebRtcState(obj.state());
    }

    fun setEnabled(enabled: Boolean) {
        obj.setEnabled(enabled);
    }

    fun onStop(f: () -> Unit) {
        onStopSubscribers.add(f)
    }
}