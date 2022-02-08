package com.cloudwebrtc.webrtc

import android.graphics.SurfaceTexture
import org.webrtc.*
import org.webrtc.RendererCommon.GlDrawer
import org.webrtc.RendererCommon.RendererEvents
import java.util.concurrent.CountDownLatch

/**
 * Display the video stream on a Surface. renderFrame() is asynchronous to avoid blocking the
 * calling thread. This class is thread safe and handles access from potentially three different
 * threads: Interaction from the main app in init, release and setMirror. Interaction from C++
 * rtc::VideoSinkInterface in renderFrame. Interaction from SurfaceHolder lifecycle in
 * surfaceCreated, surfaceChanged, and surfaceDestroyed.
 */
class SurfaceTextureRenderer
/** In order to render something, you must first call init().  */
(name: String?) : EglRenderer(name) {
    // Callback for reporting renderer events. Read-only after initilization so no lock required.
    private var rendererEvents: RendererEvents? = null
    private val layoutLock = Any()
    private var isRenderingPaused = false
    private var isFirstFrameRendered = false
    private var rotatedFrameWidth = 0
    private var rotatedFrameHeight = 0
    private var frameRotation = 0

    /**
     * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
     * for drawing frames on the EGLSurface. This class is responsible for calling release() on
     * |drawer|. It is allowed to call init() to reinitialize the renderer after a previous
     * init()/release() cycle.
     */
    @JvmOverloads
    fun init(
            sharedContext: EglBase.Context?,
            rendererEvents: RendererEvents?,
            configAttributes: IntArray? = EglBase.CONFIG_PLAIN,
            drawer: GlDrawer? = GlRectDrawer()
    ) {
        ThreadUtils.checkIsOnMainThread()
        this.rendererEvents = rendererEvents
        synchronized(layoutLock) {
            isFirstFrameRendered = false
            rotatedFrameWidth = 0
            rotatedFrameHeight = 0
            frameRotation = -1
        }
        super.init(sharedContext, configAttributes, drawer)
    }

    override fun init(
            sharedContext: EglBase.Context?,
            configAttributes: IntArray,
            drawer: GlDrawer
    ) {
        init(sharedContext, null /* rendererEvents */, configAttributes, drawer)
    }

    /**
     * Limit render framerate.
     *
     * @param fps Limit render framerate to this value, or use Float.POSITIVE_INFINITY to disable fps
     * reduction.
     */
    override fun setFpsReduction(fps: Float) {
        synchronized(layoutLock) { isRenderingPaused = fps == 0f }
        super.setFpsReduction(fps)
    }

    override fun disableFpsReduction() {
        synchronized(layoutLock) { isRenderingPaused = false }
        super.disableFpsReduction()
    }

    override fun pauseVideo() {
        synchronized(layoutLock) { isRenderingPaused = true }
        super.pauseVideo()
    }

    // VideoSink interface.
    override fun onFrame(frame: VideoFrame) {
        updateFrameDimensionsAndReportEvents(frame)
        super.onFrame(frame)
    }

    private var texture: SurfaceTexture? = null
    fun surfaceCreated(texture: SurfaceTexture?) {
        ThreadUtils.checkIsOnMainThread()
        this.texture = texture
        createEglSurface(texture)
    }

    fun surfaceDestroyed() {
        ThreadUtils.checkIsOnMainThread()
        val completionLatch = CountDownLatch(1)
        releaseEglSurface { completionLatch.countDown() }
        ThreadUtils.awaitUninterruptibly(completionLatch)
    }

    // Update frame dimensions and report any changes to |rendererEvents|.
    private fun updateFrameDimensionsAndReportEvents(frame: VideoFrame) {
        synchronized(layoutLock) {
            if (isRenderingPaused) {
                return
            }
            if (!isFirstFrameRendered) {
                isFirstFrameRendered = true
                if (rendererEvents != null) {
                    rendererEvents!!.onFirstFrameRendered()
                }
            }
            if (rotatedFrameWidth != frame.rotatedWidth || rotatedFrameHeight != frame.rotatedHeight || frameRotation != frame.rotation) {
                if (rendererEvents != null) {
                    rendererEvents!!.onFrameResolutionChanged(
                            frame.buffer.width, frame.buffer.height, frame.rotation
                    )
                }
                rotatedFrameWidth = frame.rotatedWidth
                rotatedFrameHeight = frame.rotatedHeight
                texture!!.setDefaultBufferSize(rotatedFrameWidth, rotatedFrameHeight)
                frameRotation = frame.rotation
            }
        }
    }
}