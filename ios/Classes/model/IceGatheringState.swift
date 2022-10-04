import WebRTC

public enum IceGatheringState: Int {
  case new = 0
  case gathering, complete

  static func fromWebRtc(state: RTCIceGatheringState) -> IceGatheringState {
    switch state {
    case .new:
      return IceGatheringState.new
    case .gathering:
      return IceGatheringState.gathering
    case .complete:
      return IceGatheringState.complete
    }
  }

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
