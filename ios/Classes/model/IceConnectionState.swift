import WebRTC

public enum IceConnectionState: Int {
  case new, checking, connected, completed, failed, disconnected, closed

  static func fromWebRtc(state: RTCIceConnectionState) -> IceConnectionState {
    switch state {
    case .new:
      return IceConnectionState.new
    case .checking:
      return IceConnectionState.checking
    case .connected:
      return IceConnectionState.connected
    case .completed:
      return IceConnectionState.completed
    case .failed:
      return IceConnectionState.failed
    case .disconnected:
      return IceConnectionState.disconnected
    case .closed:
      return IceConnectionState.closed
    case .count:
      // TODO: in Rust impl it's marked just unreachable. Why???
      abort()
    }
  }

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
