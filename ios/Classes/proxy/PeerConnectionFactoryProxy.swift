import WebRTC

public class PeerConnectionFactoryProxy {
    private var lastPeerConnectionId: Int = 0
    private var peerObservers: [Int : PeerObserver] = [:]
    private var factory: RTCPeerConnectionFactory

    init(state: State) {
        self.factory = state.getPeerFactory()
    }

    func create() -> PeerConnectionProxy {
        let id = nextId()

        let peerObserver = PeerObserver()
        let peer = self.factory.peerConnection(
            with: RTCConfiguration(),
            constraints: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]),
            delegate: self.peerObservers[id]
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