import WebRTC

/// Representation of an [org.webrtc.PeerConnection.SignalingState].
enum SignalingState: Int {
  /// Indicates that there is no ongoing exchange of offer and answer underway.
  case stable

  /// Indicates that the local peer has called `RTCPeerConnection.setLocalDescription()`.
  case haveLocalOffer

  /**
    Indicates that the offer sent by the remote peer has been applied and an answer has been
    created.
  */
  case haveLocalPrAnswer

  /**
    Indicates that the remote peer has created an offer and used the signaling server to deliver it
    to the local peer, which has set the offer as the remote description by calling
    `PeerConnection.setRemoteDescription()`.
  */
  case haveRemoteOffer

  /**
    Indicates that the provisional answer has been received and successfully applied in response to
    the offer previously sent and established.
  */
  case haveRemotePrAnswer

  /// Indicates that the peer was closed.
  case closed

  /**
    Converts the provided `RTCSignalingState` into a `SignalingState`.

    - Returns: `SignalingState` created based on the provided `RTCSignalingState`.
  */
  static func fromWebRtc(state: RTCSignalingState) -> SignalingState {
    switch state {
    case .stable:
      return SignalingState.stable
    case .haveLocalOffer:
      return SignalingState.haveLocalOffer
    case .haveLocalPrAnswer:
      return SignalingState.haveLocalPrAnswer
    case .haveRemoteOffer:
      return SignalingState.haveRemoteOffer
    case .haveRemotePrAnswer:
      return SignalingState.haveRemotePrAnswer
    case .closed:
      return SignalingState.closed
    }
  }
}
