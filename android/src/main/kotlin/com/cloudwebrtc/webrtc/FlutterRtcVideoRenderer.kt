package com.cloudwebrtc.webrtc

import android.graphics.SurfaceTexture
import android.os.Handler
import android.os.Looper
import com.cloudwebrtc.webrtc.proxy.VideoTrackProxy
import com.cloudwebrtc.webrtc.utils.EglUtils
import io.flutter.view.TextureRegistry
import org.webrtc.RendererCommon

/**
 * Renders video from a track to the [SurfaceTexture] which can be shown by flutter side.
 *
 * @param textureRegistry registry with which new [TextureRegistry.SurfaceTextureEntry]
 * will be created.
 */
class FlutterRtcVideoRenderer(textureRegistry: TextureRegistry) {
    /**
     * Texture entry on which video will be rendered.
     */
    private val surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry =
        textureRegistry.createSurfaceTexture()

    /**
     * Texture on which video will be rendered.
     */
    private val surfaceTexture: SurfaceTexture = surfaceTextureEntry.surfaceTexture()

    /**
     * Unique ID of the underlying texture.
     */
    private val id: Long = surfaceTextureEntry.id()

    /**
     * Listener for the [surfaceTextureRenderer] events.
     */
    private var rendererEventsListener: RendererCommon.RendererEvents = rendererEventsListener()

    /**
     * This [FlutterRtcVideoRenderer] events listener.
     */
    private var eventListener: EventListener? = null

    /**
     * Helper for rendering video on the surface.
     */
    private val surfaceTextureRenderer: SurfaceTextureRenderer =
        SurfaceTextureRenderer("flutter-video-renderer-$id")

    /**
     * [VideoTrackProxy] from which [FlutterRtcVideoRenderer] obtains video and renders it.
     */
    private var videoTrack: VideoTrackProxy? = null

    companion object {
        /**
         * Listener for the all events of [FlutterRtcVideoRenderer].
         */
        interface EventListener {
            /**
             * Notifies about first frame rendering.
             *
             * @param id unique ID of the texture which produced this event.
             */
            fun onFirstFrameRendered(id: Long)

            /**
             * Notifies about video size change.
             *
             * @param id unique ID of the texture which produced this event.
             * @param height new height of the video.
             * @param width new width of the video.
             */
            fun onTextureChangeVideoSize(id: Long, height: Int, width: Int)

            /**
             * Notifies about video rotation change.
             *
             * @param id unique ID of the texture which produced this event.
             * @param rotation new rotation of the video.
             */
            fun onTextureChangeRotation(id: Long, rotation: Int)
        }
    }

    init {
        surfaceTextureRenderer.init(EglUtils.rootEglBaseContext, rendererEventsListener)
        surfaceTextureRenderer.surfaceCreated(surfaceTexture)
    }

    /**
     * @return unique ID of the underlying texture.
     */
    fun textureId(): Long {
        return surfaceTextureEntry.id()
    }

    /**
     * Subscribes provided [EventListener] to the all events of this [FlutterRtcVideoRenderer].
     *
     * @param listener listener which will receive all events.
     */
    fun setEventListener(listener: EventListener) {
        eventListener = listener
    }

    /**
     * Sets [VideoTrackProxy] from which video will be rendered on the texture surface.
     *
     * @param newVideoTrack [VideoTrackProxy] for rendering.
     */
    fun setVideoTrack(newVideoTrack: VideoTrackProxy?) {
        if (videoTrack != newVideoTrack && newVideoTrack != null) {
            removeRendererFromVideoTrack()

            if (videoTrack == null) {
                val sharedContext = EglUtils.rootEglBaseContext!!
                surfaceTextureRenderer.release()
                rendererEventsListener = rendererEventsListener()
                surfaceTextureRenderer.init(sharedContext, rendererEventsListener)
                surfaceTextureRenderer.surfaceCreated(surfaceTexture)
            }

            newVideoTrack.addSink(surfaceTextureRenderer)
        }

        videoTrack = newVideoTrack
    }

    /**
     * Disposes this [FlutterRtcVideoRenderer].
     *
     * Closes [EventListener], releases all related to the surface texture renderer entities.
     */
    fun dispose() {
        eventListener = null
        removeRendererFromVideoTrack()
        surfaceTextureRenderer.release()
        surfaceTextureEntry.release()
        surfaceTexture.release()
    }

    /**
     * @return listener for all renderer events, which will pass
     * this events to the current [EventListener].
     */
    private fun rendererEventsListener(): RendererCommon.RendererEvents {
        return object : RendererCommon.RendererEvents {
            private var rotation: Int = -1
            private var width: Int = 0
            private var height: Int = 0

            override fun onFirstFrameRendered() {
                Handler(Looper.getMainLooper()).post {
                    eventListener?.onFirstFrameRendered(id)
                }
            }

            override fun onFrameResolutionChanged(newWidth: Int, newHeight: Int, newRotation: Int) {
                if (newWidth != width || newHeight != height) {
                    width = newWidth
                    height = newHeight
                    Handler(Looper.getMainLooper()).post {
                        eventListener?.onTextureChangeVideoSize(id, height, width)
                    }
                }

                if (newRotation != rotation) {
                    rotation = newRotation
                    Handler(Looper.getMainLooper()).post {
                        eventListener?.onTextureChangeRotation(id, rotation)
                    }
                }
            }
        }
    }

    /**
     * Removes [SurfaceTextureRenderer] of this [FlutterRtcVideoRenderer] from the
     * rendering [VideoTrackProxy].
     */
    private fun removeRendererFromVideoTrack() {
        videoTrack?.removeSink(surfaceTextureRenderer)
    }
}