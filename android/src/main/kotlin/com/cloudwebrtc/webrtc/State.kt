package com.cloudwebrtc.webrtc

import android.annotation.TargetApi
import android.content.Context
import android.media.AudioManager
import android.os.Build
import com.cloudwebrtc.webrtc.utils.EglUtils
import com.twilio.audioswitch.AudioDevice
import com.twilio.audioswitch.AudioSwitch
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.DefaultVideoEncoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.audio.JavaAudioDeviceModule

class State(val context: Context) {
    private var audioDeviceModule: JavaAudioDeviceModule? = null
    private var factory: PeerConnectionFactory? = null

    init {
        PeerConnectionFactory.initialize(
            PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(true)
                .createInitializationOptions()
        )
    }

    private fun initPeerConnectionFactory() {
        val audioModule = JavaAudioDeviceModule.builder(context)
            .setUseHardwareAcousticEchoCanceler(true)
            .setUseHardwareNoiseSuppressor(true)
            .createAudioDeviceModule()
        val eglContext: EglBase.Context = EglUtils.rootEglBaseContext!!
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.mode = AudioManager.MODE_IN_CALL
        audioManager.isSpeakerphoneOn = true
        factory = PeerConnectionFactory.builder()
            .setOptions(PeerConnectionFactory.Options())
            .setVideoEncoderFactory(
                DefaultVideoEncoderFactory(eglContext, true, true)
            )
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(eglContext))
            .setAudioDeviceModule(audioModule)
            .createPeerConnectionFactory()
        audioModule.setSpeakerMute(false)
        audioDeviceModule = audioModule
    }

    fun releasePeerConnectionFactory() {
//        factory?.dispose()
//        audioDeviceModule?.release()
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