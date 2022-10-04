import WebRTC

public class IceCandidate {
  var sdpMid: String
  var sdpMLineIndex: Int
  var candidate: String

  init(candidate: RTCIceCandidate) {
    self.sdpMid = candidate.sdpMid!
    self.candidate = candidate.sdp
    self.sdpMLineIndex = Int(candidate.sdpMLineIndex)

  }

  init(sdpMid: String, sdpMLineIndex: Int, candidate: String) {
    self.sdpMid = sdpMid
    self.sdpMLineIndex = sdpMLineIndex
    self.candidate = candidate
  }

  func intoWebRtc() -> RTCIceCandidate {
    RTCIceCandidate(
      sdp: self.candidate, sdpMLineIndex: Int32(self.sdpMLineIndex), sdpMid: self.sdpMid)
  }

  func asFlutterResult() -> [String: Any] {
    return [
      "sdpMid": self.sdpMid,
      "sdpMLineIndex": self.sdpMLineIndex,
      "candidate": self.candidate,
    ]
  }
}
