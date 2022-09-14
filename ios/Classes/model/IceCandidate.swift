import WebRTC

public class IceCandidate {
    var sdpMid: String
    var sdpMLineIndex: Int
    var candidate: String

    init(candidate: RTCIceCandidate) {
        abort()
    }

    init(sdpMid: String, sdpMLineIndex: Int, candidate: String) {
        self.sdpMid = sdpMid
        self.sdpMLineIndex = sdpMLineIndex
        self.candidate = candidate
    }

    func intoWebRtc() -> RTCIceCandidate {
        abort()
    }
}