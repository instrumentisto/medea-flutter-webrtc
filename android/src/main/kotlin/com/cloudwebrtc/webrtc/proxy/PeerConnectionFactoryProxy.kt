package com.cloudwebrtc.webrtc.proxy

import android.util.Log
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.PeerConnectionConfiguration

class PeerConnectionFactoryProxy(val state: State) {
    private var lastPeerConnectionId: Int = 0;

    private var peerObservers: HashMap<Int, PeerObserver> = HashMap();

    fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
        val id = nextId();
        val peerObserver = PeerObserver();
        val peer =
            state.getPeerConnectionFactory().createPeerConnection(config.intoWebRtc(), peerObserver)
                ?: throw UnknownError("Creating new PeerConnection was failed because of unknown issue")
        val peerProxy = PeerConnectionProxy(id, peer)
        peerObserver.setPeerConnection(peerProxy)
        peerProxy.onDispose(::removePeerObserver)

        peerObservers[id] = peerObserver

        return peerProxy;
    }

    private fun removePeerObserver(id: Int) {
        peerObservers.remove(id)
        if (peerObservers.isEmpty()) {
            state.releasePeerConnectionFactory()
        }
    }

    private fun nextId(): Int {
        return lastPeerConnectionId++;
    }
}