import WebRTC

public enum IceGatheringState: Int {
    case new = 0, gathering, complete

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
}