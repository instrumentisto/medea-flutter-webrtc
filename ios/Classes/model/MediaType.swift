import WebRTC

public enum MediaType: Int {
  case audio, video

  func intoWebRtc() -> RTCRtpMediaType {
    switch self {
    case .audio:
      return RTCRtpMediaType.audio
    case .video:
      return RTCRtpMediaType.video
    }
  }

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
