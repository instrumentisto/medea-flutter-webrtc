package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.SurfaceTextureRenderer
import com.cloudwebrtc.webrtc.utils.LocalTrackIdGenerator
import org.webrtc.*

class VideoMediaTrackSource(
    private val videoCapturer: VideoCapturer,
    private val videoSource: VideoSource,
    private val surfaceTextureRenderer: SurfaceTextureHelper,
    private val peerConnectionFactoryProxy: PeerConnectionFactory,
    private val deviceId: String
) : MediaTrackSource {
    private var aliveTracksCount: Int = 0;

    override fun newTrack(): MediaStreamTrackProxy {
        val videoTrack = MediaStreamTrackProxy(
            peerConnectionFactoryProxy.createVideoTrack(LocalTrackIdGenerator.nextId(), videoSource),
            deviceId,
            this
        );
        aliveTracksCount += 1;
        videoTrack.onStop {
            trackStopped()
        }

        return videoTrack
    }

    private fun trackStopped() {
        aliveTracksCount--;
        if (aliveTracksCount == 0) {
            dispose()
        }
    }

    private fun dispose() {
        videoCapturer.stopCapture()
        videoSource.dispose()
        videoCapturer.dispose()
        surfaceTextureRenderer.dispose()
    }
}