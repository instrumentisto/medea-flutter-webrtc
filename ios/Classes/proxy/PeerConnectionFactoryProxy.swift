public class PeerConnectionFactoryProxy {
    private var lastPeerConnectionId: Int = 0
    private var peerObservers: [Int : PeerObserver] = [:]

    func create() -> PeerConnectionProxy {
        let id = nextId()
        abort()
    }

    private func nextId() -> Int {
        lastPeerConnectionId += 1
        return lastPeerConnectionId
    }
}