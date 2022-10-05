import WebRTC

public enum SessionDescriptionType: Int {
  case offer, prAnswer, answer, rollback

  init(type: RTCSdpType) {
    switch type {
    case .offer:
      self = SessionDescriptionType.offer
    case .answer:
      self = SessionDescriptionType.answer
    case .prAnswer:
      self = SessionDescriptionType.prAnswer
    case .rollback:
      self = SessionDescriptionType.rollback
    }
  }

  func intoWebRtc() -> RTCSdpType {
    switch self {
    case .offer:
      return RTCSdpType.offer
    case .answer:
      return RTCSdpType.answer
    case .prAnswer:
      return RTCSdpType.prAnswer
    case .rollback:
      return RTCSdpType.rollback
    }
  }

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
