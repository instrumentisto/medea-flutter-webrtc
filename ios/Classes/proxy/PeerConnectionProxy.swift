import WebRTC
import OSLog
import os

public class PeerConnectionProxy {
    private var senders: [String : RtpSenderProxy] = [:]
    private var receivers: [String : RtpReceiverProxy] = [:]
    private var transceivers: [Int : RtpTransceiverProxy] = [:]
    private var peer: RTCPeerConnection
    private var observers: [PeerEventObserver] = []
    private var id: Int
    private var lastTransceiverId: Int = 0

    init (id: Int, peer: RTCPeerConnection) {
        self.peer = peer
        self.id = id
    }

    func getId() -> Int {
        return self.id
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

    func addTransceiver(mediaType: MediaType) -> RtpTransceiverProxy {
        let transceiver = self.peer.addTransceiver(of: mediaType.intoWebRtc(), init: RTCRtpTransceiverInit())
        let proxy = RtpTransceiverProxy(transceiver: transceiver!)
        self.transceivers[self.lastTransceiverId] = proxy
        self.lastTransceiverId += 1
        return proxy
    }

    func setLocalDescription(description: SessionDescription?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let completionHandler = { (error: Error?) in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error!)
                }
            }
            if (description == nil) {
                self.peer.setLocalDescriptionWithCompletionHandler(completionHandler)
            } else {
                let sdp = description!.intoWebRtc()
                self.peer.setLocalDescription(sdp, completionHandler: completionHandler)
            }
        }
    }

    func setRemoteDescription(description: SessionDescription) async throws {
        os_log(OSLogType.error, "setRemoteDescription was called")
        return try await withCheckedThrowingContinuation { continuation in
            self.peer.setRemoteDescription(description.intoWebRtc(), completionHandler: { error in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error!)
                }
            })
        }
    }

    func createOffer() async throws -> SessionDescription {
        return try await withCheckedThrowingContinuation { continuation in
            self.peer.offer(for: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]), completionHandler: { description, error in
                if (error == nil) {
                    continuation.resume(returning: SessionDescription(sdp: description!))
                } else {
                    continuation.resume(throwing: error!)
                }
            })
        }
    }

    func createAnswer() async throws -> SessionDescription {
        return try await withCheckedThrowingContinuation { continuation in
            self.peer.answer(for: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]), completionHandler: { description, error in
                if (error == nil) {
                    continuation.resume(returning: SessionDescription(sdp: description!))
                } else {
                    continuation.resume(throwing: error!)
                }
            })
        }
    }

    func addIceCandidate(candidate: IceCandidate) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.peer.add(candidate.intoWebRtc(), completionHandler: { error in
                if (error == nil) {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: error!)
                }
            })
        }
    }

    func restartIce() {
        self.peer.restartIce()
    }

    func addEventObserver(eventObserver: PeerEventObserver) {
        self.observers.append(eventObserver)
    }

    func broadcastEventObserver() -> PeerEventObserver {
        class BroadcastEventObserver : PeerEventObserver {
            private var observers: [PeerEventObserver]

            init(observers: [PeerEventObserver]) {
                self.observers = observers
            }

            func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
                for observer in self.observers {
                    os_log(OSLogType.error, "onTrack fired")
                    observer.onTrack(track: track, transceiver: transceiver)
                }
            }

            func onIceConnectionStateChange(state: IceConnectionState) {
                for observer in self.observers {
                    observer.onIceConnectionStateChange(state: state)
                }
            }

            func onSignalingStateChange(state: SignalingState) {
                for observer in self.observers {
                    observer.onSignalingStateChange(state: state)
                }
            }

            func onConnectionStateChange(state: PeerConnectionState) {
                for observer in self.observers {
                    observer.onConnectionStateChange(state: state)
                }
            }

            func onIceGatheringStateChange(state: IceGatheringState) {
                for observer in self.observers {
                    observer.onIceGatheringStateChange(state: state)
                }
            }

            func onIceCandidate(candidate: IceCandidate) {
                for observer in self.observers {
                    observer.onIceCandidate(candidate: candidate)
                }
            }

            func onNegotiationNeeded() {
                for observer in self.observers {
                    observer.onNegotiationNeeded()
                }
            }
        }

        return BroadcastEventObserver(observers: self.observers)
    }
}