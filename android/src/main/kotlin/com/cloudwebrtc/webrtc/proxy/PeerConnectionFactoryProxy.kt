package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.PeerConnectionConfiguration

/**
 * Creator of the new [PeerConnectionProxy]s.
 *
 * @property state global state used for creation.
 */
class PeerConnectionFactoryProxy(val state: State) {
    /**
     * Counter for generating new [PeerConnectionProxy] IDs.
     */
    private var lastPeerConnectionId: Int = 0

    /**
     * All [PeerObserver]s created by this [PeerConnectionFactoryProxy].
     *
     * [PeerObserver]s will be removed on [PeerConnectionProxy] dispose.
     */
    private var peerObservers: HashMap<Int, PeerObserver> = HashMap()

    /**
     * Creates new [PeerConnectionProxy] based on the provided [PeerConnectionConfiguration].
     *
     * @param config config with which new [PeerConnectionProxy] will be created.
     * @return newly created [PeerConnectionProxy].
     */
    fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
        val id = nextId()
        val peerObserver = PeerObserver()
        val peer =
                state.getPeerConnectionFactory().createPeerConnection(config.intoWebRtc(), peerObserver)
                        ?: throw UnknownError("Creating new PeerConnection was failed because of unknown issue")
        val peerProxy = PeerConnectionProxy(id, peer)
        peerObserver.setPeerConnection(peerProxy)
        peerProxy.onDispose(::removePeerObserver)

        peerObservers[id] = peerObserver

        return peerProxy
    }

    /**
     * Removes [PeerObserver] from the [peerObservers].
     */
    private fun removePeerObserver(id: Int) {
        peerObservers.remove(id)
    }

    /**
     * Generates new [PeerConnectionProxy] ID.
     *
     * @return newly generated [PeerConnectionProxy] ID.
     */
    private fun nextId(): Int {
        return lastPeerConnectionId++
    }
}