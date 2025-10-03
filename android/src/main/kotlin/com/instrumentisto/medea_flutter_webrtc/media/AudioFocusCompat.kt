package com.instrumentisto.medea_flutter_webrtc.media

import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.instrumentisto.medea_flutter_webrtc.State
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withTimeoutOrNull

private val TAG = AudioFocusCompat::class.java.simpleName

/** Timeout in milliseconds for awaiting delayed audio focus gain. */
private const val FOCUS_REQUEST_TIMEOUT_MS: Long = 10_000 // ms

/**
 * Compatibility facade for Android audio focus handling.
 *
 * @param state [State] to work with.
 */
abstract class AudioFocusCompat private constructor(state: State) {
  /** [AudioManager] system service used to make focus requests. */
  protected val audioManager: AudioManager = state.getAudioManager()

  @Volatile
  /** Indicator whether audio focus is currently granted. */
  protected var granted: Boolean = false

  /** Shared deferred for the current in-flight focus grant, if any. */
  @Volatile protected var pendingGrant: CompletableDeferred<Boolean>? = null

  /** Mutex for request creation/dispatch. */
  private val requestMutex = Mutex()

  /**
   * Listener updating the [granted] indicator whenever the system reports focus changes.
   *
   * Shared by both implementations to centralize state updates.
   */
  protected val onAudioFocusChangeListener: AudioManager.OnAudioFocusChangeListener =
      AudioManager.OnAudioFocusChangeListener { focusChange: Int ->
        if (focusChange == AudioManager.AUDIOFOCUS_GAIN) {
          granted = true
          pendingGrant?.let { d -> if (!d.isCompleted) d.complete(true) }
          pendingGrant = null
        } else {
          granted = false
          pendingGrant?.let { d -> if (!d.isCompleted) d.complete(false) }
          pendingGrant = null
        }
      }

  companion object {
    /**
     * Creates a platform-appropriate [AudioFocusCompat] instance for the current device SDK level.
     */
    @JvmStatic
    fun create(state: State): AudioFocusCompat {
      return if (Build.VERSION.SDK_INT >= 26) {
        AudioFocusSdk26(state)
      } else {
        AudioFocusSdk8(state)
      }
    }
  }

  /**
   * Requests audio focus for voice communication.
   *
   * Suspends until focus is actually granted (either synchronously or via a delayed gain callback).
   * Returns false only if the system immediately rejects the request.
   */
  suspend fun requestAudioFocus(): Boolean {
    if (granted) {
      return true
    }

    pendingGrant?.let { existing ->
      return awaitPendingGrant(existing)
    }

    return requestMutex.withLock {
      if (granted) {
        return true
      }

      val result =
          try {
            requestAudioFocusInner()
          } catch (e: SecurityException) {
            Log.w(TAG, "Audio focus not granted. Result code: $e")
            return false
          }

      when (result) {
        AudioManager.AUDIOFOCUS_REQUEST_GRANTED -> {
          granted = true
          true
        }
        AudioManager.AUDIOFOCUS_REQUEST_DELAYED -> {
          val pending = CompletableDeferred<Boolean>()
          pendingGrant = pending
          return awaitPendingGrant(pending)
        }
        else -> {
          Log.w(TAG, "Audio focus not granted. Result code: $result")
          false
        }
      }
    }
  }

  /**
   * Performs the platform-specific focus request and returns the raw result code from
   * [AudioManager.requestAudioFocus].
   */
  protected abstract fun requestAudioFocusInner(): Int

  /** Abandons audio focus previously acquired via [requestAudioFocus]. */
  abstract fun abandonAudioFocus()

  /** Awaits the provided [CompletableDeferred] with a timeout, cleaning up state on timeout. */
  private suspend fun awaitPendingGrant(pending: CompletableDeferred<Boolean>): Boolean {
    val result = withTimeoutOrNull(FOCUS_REQUEST_TIMEOUT_MS) { pending.await() }
    if (result == null) {
      Log.w(TAG, "Audio focus request timed out after ${FOCUS_REQUEST_TIMEOUT_MS} ms")
      if (!pending.isCompleted) {
        pending.complete(false)
      }
      pendingGrant = null
      return false
    }
    return result
  }

  /**
   * API 26+ implementation backed by [AudioFocusRequest].
   *
   * @param state [State] to work with.
   */
  @RequiresApi(26)
  private class AudioFocusSdk26(state: State) : AudioFocusCompat(state) {
    /** Lazily constructed focus requests (immediate vs delayed). */
    private var immediateRequest: AudioFocusRequest? = null
    private var delayedRequest: AudioFocusRequest? = null
    private var activeAudioFocusRequest: AudioFocusRequest? = null

    companion object {
      /** Audio attributes appropriate for voice communication use cases. */
      private val AUDIO_ATTRIBUTES: AudioAttributes =
          AudioAttributes.Builder()
              .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
              .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
              .build()
    }

    override fun requestAudioFocusInner(): Int {
      // Try to request focus without delay first.
      // If it fails then retry with `setAcceptsDelayedFocusGain(true)`.
      if (immediateRequest == null) {
        immediateRequest =
            AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(AUDIO_ATTRIBUTES)
                .setOnAudioFocusChangeListener(onAudioFocusChangeListener)
                .setAcceptsDelayedFocusGain(false)
                .build()
      }

      var result = audioManager.requestAudioFocus(immediateRequest!!)
      if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
        activeAudioFocusRequest = immediateRequest
        return result
      }

      if (delayedRequest == null) {
        delayedRequest =
            AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(AUDIO_ATTRIBUTES)
                .setOnAudioFocusChangeListener(onAudioFocusChangeListener)
                .setAcceptsDelayedFocusGain(true)
                .build()
      }

      result = audioManager.requestAudioFocus(delayedRequest!!)
      if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED ||
          result == AudioManager.AUDIOFOCUS_REQUEST_DELAYED) {
        activeAudioFocusRequest = delayedRequest
      }

      return result
    }

    /** Abandons the previously requested audio focus, if any. */
    override fun abandonAudioFocus() {
      if (activeAudioFocusRequest == null) {
        return
      }

      val result = audioManager.abandonAudioFocusRequest(activeAudioFocusRequest!!)

      if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
        Log.w(TAG, "Audio focus abandon failed. Result code: $result")
      }

      granted = false
      pendingGrant?.let { d -> if (!d.isCompleted) d.complete(false) }
      pendingGrant = null
      activeAudioFocusRequest = null
    }
  }

  /**
   * Pre-API 26 implementation backed by legacy [AudioManager] APIs.
   *
   * @param state [State] to work with.
   */
  private class AudioFocusSdk8(state: State) : AudioFocusCompat(state) {
    override fun requestAudioFocusInner(): Int {
      return audioManager.requestAudioFocus(
          onAudioFocusChangeListener,
          AudioManager.STREAM_VOICE_CALL,
          AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
    }

    override fun abandonAudioFocus() {
      val result = audioManager.abandonAudioFocus(onAudioFocusChangeListener)

      if (result != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
        Log.w(TAG, "Audio focus abandon failed. Result code: $result")
      }

      granted = false
      pendingGrant?.let { d -> if (!d.isCompleted) d.complete(false) }
      pendingGrant = null
    }
  }
}
