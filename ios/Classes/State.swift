import WebRTC

/// Global context of the `medea_flutter_webrtc` plugin.
///
/// Used for creating tracks/peers.
class State {
  /// Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
  private var factory: RTCPeerConnectionFactory

  /// Initializes a new `State`.
  init() {
    let decoderFactory = VideoDecoderFactory()
    let encoderFactory = VideoEncoderFactory()

    self.factory = RTCPeerConnectionFactory(
      encoderFactory: encoderFactory, decoderFactory: decoderFactory
    )
  }

  /// Returns the `RTCPeerConnectionFactory` of this `State`.
  func getPeerFactory() -> RTCPeerConnectionFactory {
    self.factory
  }
}

private class VideoEncoderFactory: RTCDefaultVideoEncoderFactory {
  // Disabled codecs.
  static var codecBlocklist: [String] = ["H264", "H265"]

  override func supportedCodecs() -> [RTCVideoCodecInfo] {
    super.supportedCodecs()
      .filterDisabledCodecs(codecBlocklist: VideoEncoderFactory.codecBlocklist)
  }
}

private class VideoDecoderFactory: RTCDefaultVideoDecoderFactory {
  // Disabled codecs.
  static var codecBlocklist: [String] = ["H264", "H265"]

  override func supportedCodecs() -> [RTCVideoCodecInfo] {
    super.supportedCodecs()
      .filterDisabledCodecs(codecBlocklist: VideoEncoderFactory.codecBlocklist)
  }
}

private extension Array where Element: RTCVideoCodecInfo {
  func filterDisabledCodecs(codecBlocklist: [String]) -> [RTCVideoCodecInfo] {
    return filter { !codecBlocklist.contains($0.name) }
  }
}
