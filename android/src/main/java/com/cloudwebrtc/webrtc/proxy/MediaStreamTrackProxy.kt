package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.model.MediaStreamTrackState
import org.webrtc.MediaStreamTrack

class MediaStreamTrackProxy(track: MediaStreamTrack) : IWebRTCProxy<MediaStreamTrack> {
    override var obj: MediaStreamTrack = track;

    private val id = track.id()

    private var onStopSubscribers: MutableList<() -> Unit> = mutableListOf()

    override fun syncWithObject() {}

    init {
        TrackRepository.addTrack(id, this)
    }

    fun stop() {
        onStopSubscribers.forEach { sub -> sub() }
    }

    fun state(): MediaStreamTrackState {
        return MediaStreamTrackState.fromWebRtcState(obj.state());
    }

    fun setEnabled(enabled: Boolean) {
        obj.setEnabled(enabled);
    }

    fun onStop(f: () -> Unit) {
        onStopSubscribers.add(f)
    }
}