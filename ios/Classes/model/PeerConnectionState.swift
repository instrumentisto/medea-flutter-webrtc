import WebRTC

/// Representation of an [org.webrtc.PeerConnection.PeerConnectionState].
enum PeerConnectionState: Int {
  /**
    Indicates that any of the ICE transports or DTLS transports are in the "new" state and none of
    the transports are in the "connecting", "checking", "failed" or "disconnected" state, or all
    transports are in the "closed" state, or there are no transports.
  */
  case new

  /**
    Indicates that any of the ICE transports or DTLS transports are in the "connecting" or
    "checking" state and none of them is in the "failed" state.
  */
  case connecting

  /**
    Indicates that all the ICE transports and DTLS transports are in the "connected", "completed"
    or "closed" state, and at least one of them is in the "connected" or "completed" state.
  */
  case connected

  /**
    Indicates that any of the ICE transports or DTLS transports are in the "disconnected" state,
    and none of them are in the "failed", "connecting" or "checking" state.
  */
  case disconnected

  /// Indicates that any of the ICE transports or DTLS transports are in the "failed" state.
  case failed

  /// Indicates that the peer connection is closed.
  case closed

  /**
    Converts the provided `RTCPeerConnectionState` into a `PeerConnectionState`.

    - Returns: `PeerConnectionState` created based on the provided `RTCPeerConnectionState`.
  */
  static func fromWebRtc(state: RTCPeerConnectionState) -> PeerConnectionState {
    switch state {
    case .new:
      return PeerConnectionState.new
    case .connecting:
      return PeerConnectionState.connecting
    case .connected:
      return PeerConnectionState.connected
    case .disconnected:
      return PeerConnectionState.disconnected
    case .failed:
      return PeerConnectionState.failed
    case .closed:
      return PeerConnectionState.closed
    }
  }
}
