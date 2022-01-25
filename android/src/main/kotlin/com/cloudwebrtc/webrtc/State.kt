package com.cloudwebrtc.webrtc

import android.annotation.TargetApi
import android.content.Context
import android.media.AudioManager
import android.os.Build
import com.cloudwebrtc.webrtc.utils.EglUtils
import com.twilio.audioswitch.AudioDevice
import com.twilio.audioswitch.AudioSwitch
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.audio.JavaAudioDeviceModule

class State(val context: Context) {
    private var audioDeviceModule: JavaAudioDeviceModule =
        JavaAudioDeviceModule.builder(context)
            .setUseHardwareAcousticEchoCanceler(true)
            .setUseHardwareNoiseSuppressor(true)
            .createAudioDeviceModule()

    private var factory: PeerConnectionFactory? = null
    private val audioSwitch: AudioSwitch = AudioSwitch(context)

    init {
        PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(true)
                .createInitializationOptions()
        )
    }

    @TargetApi(Build.VERSION_CODES.M)
    private fun initPeerConnectionFactory() {
        val eglContext: EglBase.Context = EglUtils.rootEglBaseContext!!
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.isSpeakerphoneOn = true
        factory = PeerConnectionFactory.builder()
            .setOptions(PeerConnectionFactory.Options())
            .setVideoEncoderFactory(
                SimulcastVideoEncoderFactoryWrapper(
                    eglContext,
                    enableIntelVp8Encoder = true,
                    enableH264HighProfile = false
                )
            )
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(eglContext))
            .setAudioDeviceModule(audioDeviceModule)
            .createPeerConnectionFactory()
        audioDeviceModule.setSpeakerMute(false)
    }

    fun getPeerConnectionFactory(): PeerConnectionFactory {
        if (factory == null) {
            initPeerConnectionFactory()
        }
        return factory!!
    }

    fun getAppContext(): Context {
        return context;
    }
}