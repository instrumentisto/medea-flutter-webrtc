public class PeerConnectionProxy {
    private var senders: [String : RtpSenderProxy] = [:]
    private var receivers: [String : RtpReceiverProxy] = [:]
    private var transceivers: [String : RtpTransceiverProxy] = [:]
    private var peer: RtpPeerConnection

    init (peer: RtpPeerConnection) {
        self.peer = peer
    }

    func getTransceivers() -> [RtpTransceiverProxy] {
        return Array(self.transceivers.values.map{ $0 })
    }

    func getSenders() -> [RtpSenderProxy] {
        return Array(self.senders.values.map{ $0 })
    }

    func getReceivers() -> [RtpReceiverProxy] {
        return Array(self.receivers.values.map{ $0 })
    }

    func setLocalDescription(description: SessionDescription) async throws {
        return await withCheckedThrowingContinuation { continuation in
            self.peer.setLocalDescription(description.intoWebRtc(), completionHandler: { error in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error)
                }
            })
        }
    }

    func setRemoteDescription(description: SessionDescription) async throws {
        return await withCheckedThrowingContinuation { continuation in
            self.peer.setRemoteDescription(description.intoWebRtc(), completionHandler: { error in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error)
                }
            })
        }
    }

    func createOffer() async throws -> SessionDescription {
        return await withCheckedThrowingContinuation { continuation in
            self.peer.createOffer()
        }
    }

    func addIceCandidate(candidate: IceCandidate) async throws {
        return await withCheckedThrowingContinuation { continuation in
            self.peer.addIceCandidate(candidate.intoWebRtc(), { error in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error)
                }
            })
        }
    }

    func restartIce() {
        self.peer.restartIce()
    }
}