import WebRTC

/// `RTCRtpMediaType` representation.
enum MediaType: Int {
  case audio
  case video

  /**
    Converts this `MediaType` into an `RTCRTPMediaType`.

    - Returns: `RTCRtpMediaType` based on this `MediaType`.
   */
  func intoWebRtc() -> RTCRtpMediaType {
    switch self {
    case .audio:
      return RTCRtpMediaType.audio
    case .video:
      return RTCRtpMediaType.video
    }
  }
}
