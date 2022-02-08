package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.SurfaceTextureRenderer
import org.webrtc.VideoTrack as WVideoTrack

/**
 * Wrapper around [MediaStreamTrackProxy] with video kind.
 *
 * @property track underlying [MediaStreamTrackProxy] with a video kind.
 * @throws Exception if provided [MediaStreamTrackProxy] isn't video.
 */
class VideoTrackProxy(private val track: MediaStreamTrackProxy) {
    init {
        if (track.obj !is WVideoTrack) {
            throw Exception("Provided not video MediaStreamTrack")
        }
    }

    /**
     * Removes [SurfaceTextureRenderer] from the underlying [WVideoTrack] sinks.
     */
    fun removeSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().removeSink(sink)
    }

    /**
     * Adds [SurfaceTextureRenderer] to the underlying [WVideoTrack] sinks.
     */
    fun addSink(sink: SurfaceTextureRenderer) {
        getVideoTrack().addSink(sink)
    }

    /**
     * @return underlying [WVideoTrack].
     */
    private fun getVideoTrack(): WVideoTrack {
        return track.obj as WVideoTrack
    }
}