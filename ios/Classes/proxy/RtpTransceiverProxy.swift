import WebRTC

/// Wrapper around an `RTCRtpTransceiver`.
class RtpTransceiverProxy {
  /// Actual underlying `RTCRtpTransceiver`.
  private var transceiver: RTCRtpTransceiver

  /// `RtpSenderProxy` of this `RtpTransceiverProxy`.
  private var sender: RtpSenderProxy

  /// `RtpReceiverProxy` of this `RtpTransceiverProxy`.
  private var receiver: RtpReceiverProxy

  /// Creates a new `RtpTransceiverProxy` for the provided `RTCRtpTransceiver`
  init(transceiver: RTCRtpTransceiver) {
    self.sender = RtpSenderProxy(sender: transceiver.sender)
    self.receiver = RtpReceiverProxy(receiver: transceiver.receiver)
    self.transceiver = transceiver
  }

  /// - Returns: `RtpSenderProxy` of this `RtpTransceiverProxy`.
  func getSender() -> RtpSenderProxy {
    self.sender
  }

  /// - Returns: `RtpReceiverProxy` of this `RtpTransceiverProxy`.
  func getReceiver() -> RtpReceiverProxy {
    self.receiver
  }

  /// Sets `TransceiverDirection` of the underlying `RtpTransceiver`.
  func setDirection(direction: TransceiverDirection) {
    self.transceiver.setDirection(direction.intoWebRtc(), error: nil)
  }

  /**
    Sets recv state of this `RtpTransceiver`.

    - Parameters:
      - recv: Is receiver direction is enabled.
  */
  func setRecv(recv: Bool) {
    let direction = self.getDirection()
    var newDirection = RTCRtpTransceiverDirection.stopped
    if recv {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .stopped:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .stopped:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    }

    if newDirection != RTCRtpTransceiverDirection.stopped {
      setDirection(direction: direction)
    }
  }

  /**
    Sets send state of this `RtpTransceiver`.

    - Parameters:
      - send: Is send direction is enabled.
  */
  func setSend(send: Bool) {
    let direction = self.getDirection()
    var newDirection = RTCRtpTransceiverDirection.stopped
    if send {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.sendOnly
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.sendRecv
      case .stopped:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    } else {
      switch direction {
      case .inactive:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendOnly:
        newDirection = RTCRtpTransceiverDirection.inactive
      case .sendRecv:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .recvOnly:
        newDirection = RTCRtpTransceiverDirection.recvOnly
      case .stopped:
        newDirection = RTCRtpTransceiverDirection.stopped
      }
    }

    if newDirection != RTCRtpTransceiverDirection.stopped {
      setDirection(direction: direction)
    }
  }

  /// - Returns: mID of the underlying `RtpTransceiver`.
  func getMid() -> String? {
    if transceiver.mid != nil && transceiver.mid.count == 0 {
      return nil
    }
    return transceiver.mid
  }

  /// - Returns: Preferred `RtpTransceiverDirection` of the underlying `RtpTransceiver`.
  func getDirection() -> TransceiverDirection {
    if self.transceiver.isStopped {
      return TransceiverDirection.stopped
    } else {
      return TransceiverDirection.fromWebRtc(direction: self.transceiver.direction)
    }
  }

  /// Stops the underlying `RTCRtpTransceiver`.
  func stop() {
    self.setDirection(direction: TransceiverDirection.stopped)
  }
}
