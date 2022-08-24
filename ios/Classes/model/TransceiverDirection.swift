import WebRTC

public enum TransceiverDirection {
    case sendrecv
    case sendonly
    case recvonly
    case inactive
    case stopped

    static func fromWebRtc()

    func intoWebRtc() -> RTCRtpTransceiverDirection {
        switch self {
            case .sendrecv:
                return RTCRtpTransceiverDirection.sendRecv
            case .sendonly:
                return RTCRtpTransceiverDirection.sendOnly
            case .recvonly:
                return RTCRtpTransceiverDirection.recvOnly
            case .inactive:
                return RTCRtpTransceiverDirection.inactive
            case .stopped:
                return RTCRtpTransceiverDirection.stopped
        }
    }
}