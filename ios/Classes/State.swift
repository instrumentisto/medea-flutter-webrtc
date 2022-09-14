import WebRTC

public class State {
    private var factory: RTCPeerConnectionFactory

    init() {
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let simulcastFactory = RTCVideoEncoderFactorySimulcast(primary: encoderFactory, fallback: encoderFactory)
        self.factory = RTCPeerConnectionFactory(encoderFactory: simulcastFactory, decoderFactory: decoderFactory)
    }

    public func getPeerFactory() -> RTCPeerConnectionFactory {
        return self.factory
    }
}