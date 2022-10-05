import WebRTC

/// Representation of an [RtpTransceiver.RtpTransceiverDirection].
enum TransceiverDirection: Int {
  /**
    Indicates that the transceiver is both sending to and receiving from the remote peer
    connection.
  */
  case sendRecv

  /**
    Indicates that the transceiver is sending to the remote peer, but is not receiving any media
    from the remote peer.
  */
  case sendOnly

  /**
    Indicates that the transceiver is receiving from the remote peer, but is not sending any media
    to the remote peer.
  */
  case recvOnly

  /// Indicates that the transceiver is inactive, neither sending nor receiving any media data.
  case inactive

  /// Indicates that the transceiver is stopped.
  case stopped

  /**
    Converts the provided `RTCRtpTransceiverDirection` into an `RtpTransceiverDirection`.

    - Returns: `RtpTransceiverDirection` created based on the provided `RTCRtpTransceiverDirection`.
  */
  static func fromWebRtc(direction: RTCRtpTransceiverDirection) -> TransceiverDirection {
    switch direction {
    case .sendRecv:
      return TransceiverDirection.sendRecv
    case .sendOnly:
      return TransceiverDirection.sendOnly
    case .recvOnly:
      return TransceiverDirection.recvOnly
    case .inactive:
      return TransceiverDirection.inactive
    case .stopped:
      return TransceiverDirection.stopped
    }
  }

  /**
    Converts this `RtpTransceiverDirection` into an `RTCRtpTransceiverDirection`.

    - Returns: `RTCRtpTransceiverDirection` based on this `RtpTransceiverDirection`.
  */
  func intoWebRtc() -> RTCRtpTransceiverDirection {
    switch self {
    case .sendRecv:
      return RTCRtpTransceiverDirection.sendRecv
    case .sendOnly:
      return RTCRtpTransceiverDirection.sendOnly
    case .recvOnly:
      return RTCRtpTransceiverDirection.recvOnly
    case .inactive:
      return RTCRtpTransceiverDirection.inactive
    case .stopped:
      return RTCRtpTransceiverDirection.stopped
    }
  }
}
