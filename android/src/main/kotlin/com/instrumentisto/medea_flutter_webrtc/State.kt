package com.instrumentisto.medea_flutter_webrtc

import android.content.Context
import android.media.AudioManager
import com.instrumentisto.medea_flutter_webrtc.utils.EglUtils
import org.webrtc.PeerConnectionFactory
import org.webrtc.VideoDecoderFactory
import org.webrtc.VideoEncoderFactory
import org.webrtc.audio.JavaAudioDeviceModule

/**
 * Global context of the `flutter_webrtc` library.
 *
 * Used for creating tracks, peers, and performing `getUserMedia` requests.
 *
 * @property context Android [Context] used, for example, for `getUserMedia` requests.
 */
class State(private val context: Context) {
  /** Module for the controlling audio devices in context of `libwebrtc`. */
  private var audioDeviceModule: JavaAudioDeviceModule? = null

  /** [VideoEncoderFactory] used by [PeerConnectionFactory]. */
  var encoder: WebrtcVideoEncoderFactory

  /** [VideoDecoderFactory] used by [PeerConnectionFactory]. */
  var decoder: WebrtcVideoDecoderFactory

  /**
   * Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
   *
   * Will be lazily initialized on the first call of [getPeerConnectionFactory].
   */
  private var factory: PeerConnectionFactory? = null

  init {
    PeerConnectionFactory.initialize(
        PeerConnectionFactory.InitializationOptions.builder(context)
            .setEnableInternalTracer(BuildConfig.DEBUG)
            .createInitializationOptions())

    encoder =
        WebrtcVideoEncoderFactory(
            EglUtils.rootEglBaseContext, enableIntelVp8Encoder = true, enableH264HighProfile = true)
    decoder = WebrtcVideoDecoderFactory(EglUtils.rootEglBaseContext)
  }

  /**
   * Initializes the [PeerConnectionFactory] if it wasn't initialized before.
   *
   * @return Current [PeerConnectionFactory] of this [State].
   */
  fun getPeerConnectionFactory(): PeerConnectionFactory {
    if (factory == null) {
      audioDeviceModule =
          JavaAudioDeviceModule.builder(context)
              .setUseHardwareAcousticEchoCanceler(true)
              .setUseHardwareNoiseSuppressor(true)
              .createAudioDeviceModule()

      factory =
          PeerConnectionFactory.builder()
              .setOptions(PeerConnectionFactory.Options())
              .setVideoEncoderFactory(encoder)
              .setVideoDecoderFactory(decoder)
              .setAudioDeviceModule(audioDeviceModule)
              .createPeerConnectionFactory()

      audioDeviceModule!!.setSpeakerMute(false)
    }

    return factory!!
  }

  /** @return Android SDK [Context]. */
  fun getAppContext(): Context {
    return context
  }

  /** @return [AudioManager] system service. */
  fun getAudioManager(): AudioManager {
    return context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
  }
}
