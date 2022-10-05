import WebRTC

class State {
  private var factory: RTCPeerConnectionFactory

  init() {
    let decoderFactory = RTCDefaultVideoDecoderFactory()
    let encoderFactory = RTCDefaultVideoEncoderFactory()
    self.factory = RTCPeerConnectionFactory(
      encoderFactory: encoderFactory, decoderFactory: decoderFactory)
  }

  func getPeerFactory() -> RTCPeerConnectionFactory {
    return self.factory
  }
}
