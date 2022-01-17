package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.SurfaceTextureRenderer
import java.lang.Exception
import org.webrtc.VideoTrack as WVideoTrack

class VideoTrackProxy(private val track: MediaStreamTrackProxy) {
    init {
        if (track.obj !is WVideoTrack) {
            throw Exception("Provided not video MediaStreamTrack")
        }
    }

    fun removeSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().removeSink(sink)
    }

    fun addSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().addSink(sink)
    }

    private fun getVideoTrack(): WVideoTrack {
        return track.obj as WVideoTrack
    }
}