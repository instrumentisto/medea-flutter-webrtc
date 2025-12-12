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
  /**
   * Callback for reporting renderer events.
   *
   * Assigned during [init] and then read from [onFrame]. Access is guarded by [lock] even though it
   * is effectively read-only after initialization.
   */
  private var rendererEvents: RendererEvents? = null
  private val lock = Any()

  @Volatile private var isRenderingPaused = false
  private var isFirstFrameRendered = false
  private var rotatedFrameWidth = 0
  private var rotatedFrameHeight = 0
  private var frameRotation = 0

  /**
   * Last [Surface] obtained from [producer.surface] that we created an EGL surface for.
   *
   * This cache is used to detect when [SurfaceProducer] swaps to a new [Surface] so we can:
   * - tear down the old EGL surface via [surfaceDestroyed], and
   * - create a new EGL surface via [createEglSurface].
   *
   * If [producer.surface] becomes `null`, we also tear down the current EGL surface and clear this
   * cache.
   */
  private var surfaceCache: Surface? = null

  init {
    ThreadUtils.checkIsOnMainThread()
    val id = producer.id()
    producer.setCallback(
        object : SurfaceProducer.Callback {
          override fun onSurfaceAvailable() {
            Log.d(TAG, "onSurfaceAvailable for textureId $id")
            // The actual EGL surface is created lazily in [onFrame] when we first observe a
            // non-null [producer.surface].
          }

          override fun onSurfaceCleanup() {
            Log.d(TAG, "onSurfaceCleanup for textureId $id")
            surfaceDestroyed()
          }
        }
    )
  }

  /**
   * Initialize this class, sharing resources with |sharedContext|. The custom |drawer| will be used
   * for drawing frames on the `EGLSurface`. This class is responsible for calling `release()` on
   * the |drawer|. It's allowed to call `init()` to reinitialize the renderer after the previous
   * `init()`/`release()` cycle.
   *
   * @param sharedContext EGL context to share resources with.
   * @param rendererEvents Optional callback for first-frame and resolution-change events.
   * @param configAttributes EGL config attributes; defaults to [EglBase.CONFIG_PLAIN].
   * @param drawer Optional drawer used by [EglRenderer] to draw frames.
   */
  @JvmOverloads
  fun init(
      sharedContext: EglBase.Context?,
      rendererEvents: RendererEvents?,
      configAttributes: IntArray? = EglBase.CONFIG_PLAIN,
      drawer: GlDrawer? = GlRectDrawer(),
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
   * Limits render framerate.
   *
   * @param fps Limit render framerate to this value, or use [Float.POSITIVE_INFINITY] to disable
   *   FPS reduction.
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

  /**
   * Receives a frame from WebRTC and forwards it to [EglRenderer] after ensuring we have a valid
   * EGL surface bound to the current [producer.surface].
   *
   * Reports resolution/rotation changes via [rendererEvents].
   *
   * If there is no surface available (i.e. [producer.surface] is `null`), the frame is dropped.
   */
  override fun onFrame(frame: VideoFrame) {
    synchronized(lock) {
      if (isRenderingPaused) {
        return
      }
      if (
          rotatedFrameWidth != frame.rotatedWidth ||
              rotatedFrameHeight != frame.rotatedHeight ||
              frameRotation != frame.rotation
      ) {
        if (rendererEvents != null) {
          rendererEvents!!.onFrameResolutionChanged(
              frame.rotatedWidth,
              frame.rotatedHeight,
              frame.rotation,
          )
        }
        rotatedFrameWidth = frame.rotatedWidth
        rotatedFrameHeight = frame.rotatedHeight
        producer.setSize(rotatedFrameWidth, rotatedFrameHeight)
        frameRotation = frame.rotation
      }
      if (getOrCreateSurface() == null) {
        // No surface to render to. Drop this frame.
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

  /**
   * Releases the EGL surface bound to [surfaceCache] (if any) and clears [surfaceCache].
   *
   * This is invoked:
   * - when Flutter signals cleanup via [SurfaceProducer.Callback.onSurfaceCleanup], and
   * - when we detect that the produced surface has changed (see [getOrCreateSurface]).
   *
   * Internally, [releaseEglSurface] executes on [EglRenderer]'s render thread; we block until the
   * release completes to ensure subsequent surface creation is safe.
   */
  fun surfaceDestroyed() {
    synchronized(lock) {
      val completionLatch = CountDownLatch(1)
      releaseEglSurface { completionLatch.countDown() }
      ThreadUtils.awaitUninterruptibly(completionLatch)
      surfaceCache = null
    }
  }

  /**
   * Returns the current [Surface] to render into, creating or re-creating the EGL surface if
   * needed.
   *
   * Must be called with the [lock] held.
   */
  private fun getOrCreateSurface(): Surface? {
    val producedSurface = producer.surface
    if (producedSurface == null) {
      if (surfaceCache != null) {
        // Destroy current EGL surface and return null.
        surfaceDestroyed()
      }
    } else {
      if (surfaceCache != producedSurface) {
        // Produced surface changed: destroy cached EGL surface and initialize a new one.
        surfaceDestroyed()
        surfaceCache = producedSurface
        createEglSurface(surfaceCache)
      }
    }

    return surfaceCache
  }
}
