import WebRTC

public enum SignalingState: Int {
  case stable, haveLocalOffer, haveLocalPrAnswer, haveRemoteOffer, haveRemotePrAnswer, closed

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

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
