package com.cloudwebrtc.webrtc

import android.content.Context
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.audio.JavaAudioDeviceModule

class State(val context: Context) {
    private var eglContext: EglBase.Context = EglUtils.getRootEglBaseContext();

    private var audioDeviceModule: JavaAudioDeviceModule =
        JavaAudioDeviceModule.builder(context)
            .setUseHardwareAcousticEchoCanceler(true)
            .setUseHardwareNoiseSuppressor(true)
            .createAudioDeviceModule()

    private var factory: PeerConnectionFactory = PeerConnectionFactory.builder()
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

    init {
        PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(true)
                .createInitializationOptions()
        )
    }

    fun getPeerConnectionFactory(): PeerConnectionFactory {
        return factory;
    }

    fun getAppContext(): Context {
        return context;
    }
}