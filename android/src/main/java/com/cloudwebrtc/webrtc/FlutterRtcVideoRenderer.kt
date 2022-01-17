package com.cloudwebrtc.webrtc

import android.graphics.SurfaceTexture
import com.cloudwebrtc.webrtc.utils.EglUtils
import io.flutter.view.TextureRegistry
import org.webrtc.RendererCommon

class FlutterRtcVideoRenderer(textureRegistry: TextureRegistry) {
    private val surfaceTextureEntry: TextureRegistry.SurfaceTextureEntry = textureRegistry.createSurfaceTexture()
    private val surfaceTexture: SurfaceTexture = surfaceTextureEntry.surfaceTexture()
    private val id: Long = surfaceTextureEntry.id()
    private var rendererEventsListener: RendererCommon.RendererEvents = rendererEventsListener()
    private var eventListener: EventListener? = null
    private val surfaceTextureRenderer: SurfaceTextureRenderer = SurfaceTextureRenderer("flutter-video-renderer-$id")
    private var videoTrack: VideoTrack? = null

    companion object {
        interface EventListener {
            fun onFirstFrameRendered(id: Long)

            fun onTextureChangeVideoSize(id: Long, height: Int, width: Int)

            fun onTextureChangeRotation(id: Long, rotation: Int)
        }
    }

    init {
        surfaceTextureRenderer.init(EglUtils.getRootEglBaseContext(), rendererEventsListener)
        surfaceTextureRenderer.surfaceCreated(surfaceTexture)
    }

    fun setEventListener(listener: EventListener) {
        eventListener = listener
    }

    fun setVideoTrack(newVideoTrack: VideoTrack?) {
        if (videoTrack != newVideoTrack && newVideoTrack != null) {
            removeRendererFromVideoTrack()

            // TODO(evdokimovs): if sharedContext will be null, then app will crash on `init()`, but I don't give a fuck
            val sharedContext = EglUtils.getRootEglBaseContext()
            surfaceTextureRenderer.release()
            rendererEventsListener = rendererEventsListener()
            surfaceTextureRenderer.init(sharedContext, rendererEventsListener)
            surfaceTextureRenderer.surfaceCreated(surfaceTexture)

            newVideoTrack.addSink(surfaceTextureRenderer)
        }

        videoTrack = newVideoTrack
    }

    fun dispose() {
        removeRendererFromVideoTrack()
        surfaceTexture.release()
        surfaceTextureEntry.release()
    }

    private fun rendererEventsListener(): RendererCommon.RendererEvents {
        return object : RendererCommon.RendererEvents {
            private var rotation: Int = -1
            private var width: Int = 0
            private var height: Int = 0

            override fun onFirstFrameRendered() {
                eventListener?.onFirstFrameRendered(id)
            }

            override fun onFrameResolutionChanged(newWidth: Int, newHeight: Int, newRotation: Int) {
                if (newWidth != width || newHeight != height) {
                    width = newWidth
                    height = newHeight
                    eventListener?.onTextureChangeVideoSize(id, width, height)
                }

                if (newRotation != rotation) {
                    rotation = newRotation
                    eventListener?.onTextureChangeRotation(id, rotation)
                }
            }
        }
    }

    private fun removeRendererFromVideoTrack() {
        videoTrack?.removeSink(surfaceTextureRenderer)
    }
}