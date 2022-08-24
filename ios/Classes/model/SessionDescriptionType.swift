public enum SessionsDescriptionType {
    case offer
    case pranswer
    case answer
    case rollback

    init(type: RTCSdpType) {
        switch (type) {
            case .offer:
                self = SessionsDescriptionType.offer
            case .answer:
                self = SessionDescriptionType.answer
            case .pranswer:
                self = SessionDescriptionType.pranswer
            case .rollback:
                self = SessionDescriptionType.rollback
        }
    }

    func intoWebRtc() -> RTCSdpType {
        switch (self) {
            case .offer:
                return RTCSdpType.offer
            case .answer:
                return RTCSdpType.answer
            case .pranswer:
                return RTCSdpType.pranswer
            case .rollback:
                return RTCSdpType.rollback
        }
    }
}
