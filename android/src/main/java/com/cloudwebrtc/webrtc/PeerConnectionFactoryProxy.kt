package com.cloudwebrtc.webrtc

import android.content.Context
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.PeerConnectionFactory.InitializationOptions
import org.webrtc.audio.JavaAudioDeviceModule

class PeerConnectionFactoryProxy(context: Context) {
    private var lastPeerConnectionId: Int = 0;

    private var eglContext: EglBase.Context = EglUtils.getRootEglBaseContext();

    private var audioDeviceModule: JavaAudioDeviceModule =
            JavaAudioDeviceModule.builder(context)
                    .setUseHardwareAcousticEchoCanceler(true)
                    .setUseHardwareNoiseSuppressor(true)
                    .createAudioDeviceModule()

    private var factory: PeerConnectionFactory = PeerConnectionFactory.builder()
            .setOptions(PeerConnectionFactory.Options())
            .setVideoEncoderFactory(
                    SimulcastVideoEncoderFactoryWrapper(eglContext, enableIntelVp8Encoder = true, enableH264HighProfile = false))
            .setVideoDecoderFactory(DefaultVideoDecoderFactory(eglContext))
            .setAudioDeviceModule(audioDeviceModule)
            .createPeerConnectionFactory()

    private var peerObservers: HashMap<Int, PeerObserver> = HashMap();

    init {
        // TODO(evdokimovs): IDK what it is, but it was in legacy code, so it needs research and testing
        PeerConnectionFactory.initialize(
                InitializationOptions.builder(context)
                        .setEnableInternalTracer(true)
                        .createInitializationOptions())
    }

    fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
        val id = nextId();
        val peerObserver = PeerObserver();
        val peer = factory.createPeerConnection(config.intoWebRtc(), peerObserver)
                ?: throw UnknownError("Creating new PeerConnection was failed because of unknown issue")
        val peerProxy = PeerConnectionProxy(id, peer)
        peerObserver.setPeerConnection(peerProxy)
        peerProxy.onDispose(::removePeerObserver)

        peerObservers[id] = peerObserver

        return peerProxy;
    }

    private fun removePeerObserver(id: Int) {
        peerObservers.remove(id)
    }

    private fun nextId(): Int {
        return lastPeerConnectionId++;
    }
}