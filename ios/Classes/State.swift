import WebRTC

///  Global context of the `flutter_webrtc` plugin.
///
///  Used for creating tracks/peers.
class State {
  /// Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
  private var factory: RTCPeerConnectionFactory

  /// Creates a new `State`.
  init() {
    let decoderFactory = RTCDefaultVideoDecoderFactory()
    let encoderFactory = RTCDefaultVideoEncoderFactory()
    self.factory = RTCPeerConnectionFactory(
      encoderFactory: encoderFactory, decoderFactory: decoderFactory)
  }

  /// - Returns: `RTCPeerConnectionFactory` from this `State`.
  func getPeerFactory() -> RTCPeerConnectionFactory {
    self.factory
  }
}
