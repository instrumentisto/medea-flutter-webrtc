package com.cloudwebrtc.webrtc

import android.content.Context
import com.cloudwebrtc.webrtc.utils.EglUtils
import org.webrtc.DefaultVideoDecoderFactory
import org.webrtc.EglBase
import org.webrtc.PeerConnectionFactory
import org.webrtc.PeerConnectionFactory.InitializationOptions
import org.webrtc.VideoSource
import org.webrtc.audio.JavaAudioDeviceModule

class PeerConnectionFactoryProxy(val state: State) {
    private var lastPeerConnectionId: Int = 0;

    private var peerObservers: HashMap<Int, PeerObserver> = HashMap();

    fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
        val id = nextId();
        val peerObserver = PeerObserver();
        val peer = state.getPeerConnectionFactory().createPeerConnection(config.intoWebRtc(), peerObserver)
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