import WebRTC

public class PeerConnectionFactoryProxy {
    private var lastPeerConnectionId: Int = 0
    private var peerObservers: [Int : PeerObserver] = [:]
    private var factory: RTCPeerConnectionFactory

    init(state: State) {
        self.factory = state.getPeerFactory()
    }

    func create(conf: PeerConnectionConfiguration) -> PeerConnectionProxy {
        let id = nextId()

        let config = conf.intoWebRtc()
        let peerObserver = PeerObserver()
        let peer = self.factory.peerConnection(
            with: config,
            constraints: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]),
            delegate: peerObserver
        )
        let peerProxy = PeerConnectionProxy(id: id, peer: peer!)
        peerObserver.setPeer(peer: peerProxy)

        self.peerObservers[id] = peerObserver

        return peerProxy
    }

    // TODO: call this function when PeerConnectionProxy dispose is called
    private func remotePeerObserver(id: Int) {
        self.peerObservers.removeValue(forKey: id)
    }

    private func nextId() -> Int {
        lastPeerConnectionId += 1
        return lastPeerConnectionId
    }
}