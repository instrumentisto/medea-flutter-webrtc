import WebRTC

/// Representation of an `RTCSdpType`.
enum SessionDescriptionType: Int {
  /// Indicates that the description is the initial proposal in an offer/answer exchange.
  case offer

  /**
    Indicates that the description is a provisional answer and may be changed when the definitive
    choice will be given.
  */
  case prAnswer

  /// Indicates that the description is the definitive choice in an offer/answer exchange.
  case answer

  /// Indicates that the description rolls back from an offer/answer state to the last stable state.
  case rollback

  /// Creates new `SessionDescriptionType` based on the provided `RTCSdpType`.
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

  /**
    Converts this `SessionDescriptionType` into an [RTCSdpType].

    - Returns: `RTCSdpType` based on this `SessionDescriptionType`.
  */
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
}
