import WebRTC

/// Representation of an `RTCIceCandidate`.
class IceCandidate {
  /// `mid` of this `IceCandidate`.
  var sdpMid: String

  /// `sdpMLineIndex` of this `IceCandidate`.
  var sdpMLineIndex: Int

  /// `candidate` of this `IceCandidate`.
  var candidate: String

  /// Creates a new `IceCandidate` object based on the method call received from the Flutter side.
  init(candidate: RTCIceCandidate) {
    self.sdpMid = candidate.sdpMid!
    self.candidate = candidate.sdp
    self.sdpMLineIndex = Int(candidate.sdpMLineIndex)

  }

  /// Creates new `IceCandidate` with a provided data.
  init(sdpMid: String, sdpMLineIndex: Int, candidate: String) {
    self.sdpMid = sdpMid
    self.sdpMLineIndex = sdpMLineIndex
    self.candidate = candidate
  }

  /// Converts this `IceCandidate` to an `RTCIceCandidate`.
  func intoWebRtc() -> RTCIceCandidate {
    RTCIceCandidate(
      sdp: self.candidate, sdpMLineIndex: Int32(self.sdpMLineIndex), sdpMid: self.sdpMid)
  }

  /// Converts this `IceCandidate` into a `Dictionary` which can be returned to the Flutter side.
  func asFlutterResult() -> [String: Any] {
    [
      "sdpMid": sdpMid,
      "sdpMLineIndex": sdpMLineIndex,
      "candidate": candidate,
    ]
  }
}
