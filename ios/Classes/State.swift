import WebRTC

class RTCMyVP8VideoDecoderFactory: NSObject, RTCVideoDecoderFactory {
    func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs: [RTCVideoCodecInfo] = []
        let codecName = kRTCVp8CodecName

        let vp8CodecInfo = RTCVideoCodecInfo(name: codecName)
        codecs.append(vp8CodecInfo)

        return codecs
    }

    func createDecoder(_ info: RTCVideoCodecInfo) -> RTCVideoDecoder? {
        // if (info.name == kRTCVideoCodecVp8Name) {
        //     return RTCVideoEncoderVP8.vp8Encoder()
        // }

        return nil
    }
}

class RTCMyVP8VideoEncoderFactory: NSObject, RTCVideoEncoderFactory {
    func supportedCodecs() -> [RTCVideoCodecInfo] {
        var codecs: [RTCVideoCodecInfo] = []
        let codecName = kRTCVp8CodecName

        let vp8CodecInfo = RTCVideoCodecInfo(name: codecName)
        codecs.append(vp8CodecInfo)

        return codecs
    }

    func createEncoder(_ info: RTCVideoCodecInfo) -> RTCVideoEncoder? {
        if (info.name == kRTCVideoCodecVp8Name) {
            return RTCVideoEncoderVP8.vp8Encoder()
        }

        return nil
    }
}

/// Global context of the `medea_flutter_webrtc` plugin.
///
/// Used for creating tracks/peers.
class State {
  /// Factory for producing `PeerConnection`s and `MediaStreamTrack`s.
  private var factory: RTCPeerConnectionFactory

  /// Initializes a new `State`.
  init() {
    let decoderFactory = MedeaVideoDecoderFactory()
    let encoderFactory = MedeaVideoEncoderFactory()
    self.factory = RTCPeerConnectionFactory(
      encoderFactory: encoderFactory, decoderFactory: decoderFactory
    )
  }

  /// Returns the `RTCPeerConnectionFactory` of this `State`.
  func getPeerFactory() -> RTCPeerConnectionFactory {
    self.factory
  }
}
