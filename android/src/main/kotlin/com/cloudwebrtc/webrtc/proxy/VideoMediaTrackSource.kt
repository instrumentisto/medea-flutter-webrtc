package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.SurfaceTextureRenderer
import com.cloudwebrtc.webrtc.utils.LocalTrackIdGenerator
import org.webrtc.*

/**
 * Object which represents source of the input video of the user.
 *
 * This source can create new [MediaStreamTrackProxy]s with the same video source.
 *
 * Also, this object will track all child [MediaStreamTrackProxy]s and when they all disposed,
 * will dispose underlying [VideoSource].
 *
 * @property videoCapturer [VideoCapturer] used in the provided [VideoSource].
 * @property videoSource actual underlying [VideoSource].
 * @property surfaceTextureRenderer [SurfaceTextureRenderer] used in the provided [VideoSource].
 * @property peerConnectionFactoryProxy [PeerConnectionFactoryProxy] with which
 * new [MediaStreamTrackProxy]s will be created.
 * @property deviceId unique device ID of the provided [VideoSource].
 */
class VideoMediaTrackSource(
    private val videoCapturer: VideoCapturer,
    private val videoSource: VideoSource,
    private val surfaceTextureRenderer: SurfaceTextureHelper,
    private val peerConnectionFactoryProxy: PeerConnectionFactory,
    private val deviceId: String
) : MediaTrackSource {
    /**
     * Count of currently alive [MediaStreamTrackProxy] created from this [VideoMediaTrackSource].
     */
    private var aliveTracksCount: Int = 0;

    /**
     * Creates new [MediaStreamTrackProxy] with the underlying [VideoSource].
     *
     * @return new [MediaStreamTrackProxy]
     */
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

    /**
     * Function which will be called when this [VideoMediaTrackSource] is stopped.
     *
     * Decrements [aliveTracksCount] and if no [MediaStreamTrackProxy]s left, then disposes
     * this [VideoMediaTrackSource].
     */
    private fun trackStopped() {
        aliveTracksCount--;
        if (aliveTracksCount == 0) {
            dispose()
        }
    }

    /**
     * Disposes this [AudioMediaTrackSource].
     *
     * Disposes [VideoSource], [VideoCapturer] and [SurfaceTextureHelper].
     */
    private fun dispose() {
        videoCapturer.stopCapture()
        videoSource.dispose()
        videoCapturer.dispose()
        surfaceTextureRenderer.dispose()
    }
}