package com.instrumentisto.medea_flutter_webrtc

import android.util.Log
import android.view.Surface
import io.flutter.view.TextureRegistry.SurfaceProducer
import java.util.concurrent.CountDownLatch
import org.webrtc.EglBase
import org.webrtc.EglRenderer
import org.webrtc.GlRectDrawer
import org.webrtc.RendererCommon.GlDrawer
import org.webrtc.RendererCommon.RendererEvents
import org.webrtc.ThreadUtils
import org.webrtc.VideoFrame

private val TAG = SurfaceTextureRenderer::class.java.simpleName

/** Displays the video stream on a `Surface`. */
class SurfaceTextureRenderer(name: String, private val producer: SurfaceProducer) :
    EglRenderer(name) {
  // Callback for reporting renderer events. Read-only after initialization,
  // so no lock is required.
  private var rendererEvents: RendererEvents? = null
  private val lock = Any()

  @Volatile private var isRenderingPaused = false
  private var isFirstFrameRendered = false
  private var rotatedFrameWidth = 0
  private var rotatedFrameHeight = 0
  private var frameRotation = 0
  private var surfaceCache: Surface? = null

  init {
    ThreadUtils.checkIsOnMainThread()
    val id = producer.id()
    producer.setCallback(
        object : SurfaceProducer.Callback {
          override fun onSurfaceAvailable() {
            Log.d(TAG, "onSurfaceAvailable for textureId $id")
            // New surface will be used when the next frame arrives.
          }

          override fun onSurfaceCleanup() {
            Log.d(TAG, "onSurfaceCleanup for textureId $id")
            surfaceDestroyed()
          }
        })
  }

  /**
   * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
   * for drawing frames on the `EGLSurface`. This class is responsible for calling `release()` on
   * the |drawer|. It's allowed to call `init()` to reinitialize the renderer after the previous
   * `init()`/`release()` cycle.
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
    synchronized(lock) {
      isFirstFrameRendered = false
      rotatedFrameWidth = 0
      rotatedFrameHeight = 0
      frameRotation = -1
    }
    super.init(sharedContext, configAttributes, drawer)
  }

  override fun init(sharedContext: EglBase.Context?, configAttributes: IntArray, drawer: GlDrawer) {
    init(sharedContext, null, configAttributes, drawer)
  }

  /**
   * Limit render framerate.
   *
   * @param fps Limit render framerate to this value, or use [Float.POSITIVE_INFINITY] to disable
   * FPS reduction.
   */
  override fun setFpsReduction(fps: Float) {
    isRenderingPaused = fps == 0f
    super.setFpsReduction(fps)
  }

  override fun disableFpsReduction() {
    isRenderingPaused = false
    super.disableFpsReduction()
  }

  override fun pauseVideo() {
    isRenderingPaused = true
    super.pauseVideo()
  }

  override fun onFrame(frame: VideoFrame) {
    synchronized(lock) {
      if (isRenderingPaused) {
        return
      }
      if (rotatedFrameWidth != frame.rotatedWidth ||
          rotatedFrameHeight != frame.rotatedHeight ||
          frameRotation != frame.rotation) {
        if (rendererEvents != null) {
          rendererEvents!!.onFrameResolutionChanged(
              frame.rotatedWidth, frame.rotatedHeight, frame.rotation)
        }
        rotatedFrameWidth = frame.rotatedWidth
        rotatedFrameHeight = frame.rotatedHeight
        producer.setSize(rotatedFrameWidth, rotatedFrameHeight)
        frameRotation = frame.rotation
      }
      if (getOrCreateSurface() == null) {
        return
      }
      if (!isFirstFrameRendered) {
        isFirstFrameRendered = true
        if (rendererEvents != null) {
          rendererEvents!!.onFirstFrameRendered()
        }
      }
    }
    super.onFrame(frame)
  }

  private fun getOrCreateSurface(): Surface? {
    val producedSurface = producer.surface
    if (producedSurface == null) {
      if (surfaceCache != null) {
        // destroy current surface and return null
        surfaceDestroyed()
      }
    } else {
      if (surfaceCache != producedSurface) {
        // destroy cached surface and initialize provided one
        surfaceDestroyed()
        surfaceCache = producedSurface
        createEglSurface(surfaceCache)
      }
    }

    return surfaceCache
  }

  fun surfaceDestroyed() {
    synchronized(lock) {
      val completionLatch = CountDownLatch(1)
      releaseEglSurface { completionLatch.countDown() }
      ThreadUtils.awaitUninterruptibly(completionLatch)
      surfaceCache = null
    }
  }
}
