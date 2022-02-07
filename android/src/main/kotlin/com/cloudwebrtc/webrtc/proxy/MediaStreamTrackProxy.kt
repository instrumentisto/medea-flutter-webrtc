package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.model.MediaKind
import com.cloudwebrtc.webrtc.model.MediaStreamTrackState
import org.webrtc.MediaStreamTrack

class MediaStreamTrackProxy(
    track: MediaStreamTrack,
    private val deviceId: String = "remote",
    private val source: MediaTrackSource? = null
) :
    IWebRTCProxy<MediaStreamTrack> {
    override var obj: MediaStreamTrack = track;

    private val id = track.id()

    private var onStopSubscribers: MutableList<() -> Unit> = mutableListOf()

    private var isStopped: Boolean = false;

    override fun syncWithObject() {}

    init {
        TrackRepository.addTrack(id, this)
    }

    fun id(): String {
        return id
    }

    fun kind(): MediaKind {
        return when (obj.kind()) {
            MediaStreamTrack.VIDEO_TRACK_KIND -> MediaKind.Video
            MediaStreamTrack.AUDIO_TRACK_KIND -> MediaKind.Audio
            else -> throw Exception("LibWebRTC provided unknown MediaKind value")
        }
    }

    fun deviceId(): String {
        return deviceId;
    }

    fun clone(): MediaStreamTrackProxy {
        if (this.source == null) {
            throw Exception("Remote MediaStreamTracks can't be cloned")
        } else {
            return source.newTrack()
        }
    }

    fun stop() {
        if (!isStopped) {
            isStopped = true
            onStopSubscribers.forEach { sub -> sub() }
        } else {
            Log.w("FlutterWebRTC", "Double stop detected [deviceId: $deviceId]!")
        }
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