import WebRTC

public enum TransceiverDirection {
    case sendRecv, sendOnly, recvOnly, inactive, stopped

    static func fromWebRtc(direction: RTCRtpTransceiverDirection) -> TransceiverDirection {
        switch direction {
            case .sendRecv:
                return TransceiverDirection.sendRecv
            case .sendOnly:
                return TransceiverDirection.sendOnly
            case .recvOnly:
                return TransceiverDirection.recvOnly
            case .inactive:
                return TransceiverDirection.inactive
            case .stopped:
                return TransceiverDirection.stopped
        }
    }

    func intoWebRtc() -> RTCRtpTransceiverDirection {
        switch self {
            case .sendRecv:
                return RTCRtpTransceiverDirection.sendRecv
            case .sendOnly:
                return RTCRtpTransceiverDirection.sendOnly
            case .recvOnly:
                return RTCRtpTransceiverDirection.recvOnly
            case .inactive:
                return RTCRtpTransceiverDirection.inactive
            case .stopped:
                return RTCRtpTransceiverDirection.stopped
        }
    }
}