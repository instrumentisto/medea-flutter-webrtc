import WebRTC

/// Wrapper around a `PeerConnection`.
class PeerConnectionProxy {
  /// List of all `RtpSenderProxy`s owned by this `PeerConnectionProxy`.
  private var senders: [String: RtpSenderProxy] = [:]

  /// List of all `RtpReceiverProxy`s owned by this `PeerConnectionProxy`.
  private var receivers: [String: RtpReceiverProxy] = [:]

  /// List of all `RtpTransceiverProxy`s owned by this `PeerConnectionProxy`.
  private var transceivers: [Int: RtpTransceiverProxy] = [:]

  /// Actual underlying `PeerConnection`.
  private var peer: RTCPeerConnection

  /// List of `EventObserver` for this `PeerConnectionProxy`.
  private var observers: [PeerEventObserver] = []

  /// Unique ID of this `PeerConnectionProxy`.
  private var id: Int

  /// Last unique ID of `PeerConnectionProxy`s.
  private var lastTransceiverId: Int = 0

  /// Creates new `PeerConnectionProxy` with provided peer and ID.
  init(id: Int, peer: RTCPeerConnection) {
    self.peer = peer
    self.id = id
  }

  /// - Returns: ID of this peer.
  func getId() -> Int {
    return self.id
  }

  /*
    Synchronizes and returns all the `RtpTransceiverProxy`s of this `PeerConnectionProxy`.

    - Returns: all `RtpTransceiverProxy`s of this `PeerConnectionProxy`.
  */
  func getTransceivers() -> [RtpTransceiverProxy] {
    self.syncTransceivers()
    return Array(self.transceivers.values.map { $0 })
  }

  /// - Returns: All `RtpSenderProxy`s of this `PeerConnectionProxy`.
  func getSenders() -> [RtpSenderProxy] {
    return Array(self.senders.values.map { $0 })
  }

  /// - Returns: All `RtpReceiverProxy`s of this `PeerConnectionProxy`.
  func getReceivers() -> [RtpReceiverProxy] {
    return Array(self.receivers.values.map { $0 })
  }

  /**
    Creates a new `RtpTransceiverProxy` based on the provided config.

    - Parameters:
      - mediaType: Initial `MediaType` of the newly created `RtpTransceiverProxy`.
      - init: Configuration of the newly created `RtpTransceiverProxy`.

    - Returns: Newly created `RtpTransceiverProxy`.
  */
  func addTransceiver(mediaType: MediaType, transceiverInit: TransceiverInit) -> RtpTransceiverProxy
  {
    let transceiver = self.peer.addTransceiver(
      of: mediaType.intoWebRtc(), init: transceiverInit.intoWebRtc())
    self.syncTransceivers()
    return self.transceivers[lastTransceiverId]!
  }

  /**
    Sets the provided local `SessionDescription` to the underlying `PeerConnection`.

    - Parameters:
      description: SDP to be applied.
  */
  func setLocalDescription(description: SessionDescription?) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      let completionHandler = { (error: Error?) in
        if error == nil {
          continuation.resume(returning: ())
        } else {
          continuation.resume(throwing: error!)
        }
      }
      if description == nil {
        self.peer.setLocalDescriptionWithCompletionHandler(completionHandler)
      } else {
        let sdp = description!.intoWebRtc()
        self.peer.setLocalDescription(sdp, completionHandler: completionHandler)
      }
    }
  }

  /**
    Sets the provided remote `SessionDescription` to the underlying `PeerConnection`.

    - Parameters:
      - description: SDP to be applied.
  */
  func setRemoteDescription(description: SessionDescription) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      self.peer.setRemoteDescription(
        description.intoWebRtc(),
        completionHandler: { error in
          if error == nil {
            continuation.resume(returning: ())
          } else {
            continuation.resume(throwing: error!)
          }
        })
    }
  }

  /**
    Creates a new `SessionDescription` offer.

    Returns: Newly created `SessionDescription`.
  */
  func createOffer() async throws -> SessionDescription {
    return try await withCheckedThrowingContinuation { continuation in
      self.peer.offer(
        for: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]),
        completionHandler: { description, error in
          if error == nil {
            continuation.resume(returning: SessionDescription(sdp: description!))
          } else {
            continuation.resume(throwing: error!)
          }
        })
    }
  }

  /**
    Synchronizes underlying pointers of old `RtpTransceiverProxy`s and creates
    `RtpTransceiverProxy`s for new `RtpTransceiver`s.
  */
  func syncTransceivers() {
    let transceivers = self.peer.transceivers.enumerated()
    for (index, transceiver) in transceivers {
      if self.transceivers[index] == nil {
        let transceiverProxy = RtpTransceiverProxy(transceiver: transceiver)
        let sender = transceiverProxy.getSender()
        let receiver = transceiverProxy.getReceiver()
        self.senders[sender.id()] = sender
        self.receivers[receiver.id()] = receiver
        self.transceivers[index] = transceiverProxy

        self.lastTransceiverId = index
      }
    }
  }

  /**
    Creates a new `SessionDescription` answer.

    - Returns: Newly created `SessionDescription`.
  */
  func createAnswer() async throws -> SessionDescription {
    return try await withCheckedThrowingContinuation { continuation in
      self.peer.answer(
        for: RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:]),
        completionHandler: { description, error in
          if error == nil {
            continuation.resume(returning: SessionDescription(sdp: description!))
          } else {
            continuation.resume(throwing: error!)
          }
        })
    }
  }

  /** Adds a new `IceCandidate` to the underlying `PeerConnection`. */
  func addIceCandidate(candidate: IceCandidate) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      self.peer.add(
        candidate.intoWebRtc(),
        completionHandler: { error in
          if error == nil {
            continuation.resume(returning: ())
          } else {
            continuation.resume(throwing: error!)
          }
        })
    }
  }

  /// Requests the underlying `PeerConnection` to redo `IceCandidate` gathering.
  func restartIce() {
    self.peer.restartIce()
  }

  /// Notifies `RtpReceiverProxy` that it was ended.
  func receiverRemoved(endedReceiver: RTCRtpReceiver) {
    let receiver = self.receivers[endedReceiver.receiverId]
    receiver?.notifyRemoved()
  }

  /**
    Adds an `PeerEventObserver` for this `PeerConnectionProxy`.

    - Parameters:
      - eventObserver: `PeerEventObserver` which will be subscribed.
  */
  func addEventObserver(eventObserver: PeerEventObserver) {
    self.observers.append(eventObserver)
  }

  /**
    Creates a broadcaster to all the `observers` of this `PeerConnectionProxy`.

    - Returns: `EventObserver` broadcasting calls to all the `observers`.
  */
  func broadcastEventObserver() -> PeerEventObserver {
    class BroadcastEventObserver: PeerEventObserver {
      private var observers: [PeerEventObserver]

      init(observers: [PeerEventObserver]) {
        self.observers = observers
      }

      func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
        for observer in self.observers {
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

  func dispose() {
    self.peer.close()
    for receiver in self.receivers.values {
      receiver.notifyRemoved()
    }
    self.receivers = [:]
  }
}
