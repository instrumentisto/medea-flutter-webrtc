import WebRTC

public enum PeerConnectionState: Int {
  case new, connecting, connected, disconnected, failed, closed

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

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
