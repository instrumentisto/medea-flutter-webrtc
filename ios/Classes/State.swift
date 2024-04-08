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
    override func supportedCodecs() -> [RTCVideoCodecInfo] {
        super.supportedCodecs().filterDisabledCodecs()
    }
}

private class VideoDecoderFactory: RTCDefaultVideoDecoderFactory {
    override func supportedCodecs() -> [RTCVideoCodecInfo] {
        super.supportedCodecs().filterDisabledCodecs()
    }
}

private extension Array where Element: RTCVideoCodecInfo {
    func filterDisabledCodecs() -> [RTCVideoCodecInfo] {
      return filter { $0.name != kRTCVideoCodecH264Name };
    }
}
