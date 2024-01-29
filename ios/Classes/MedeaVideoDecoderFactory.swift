import WebRTC

class MedeaVideoDecoderFactory: NSObject, RTCVideoDecoderFactory {
  func supportedCodecs() -> [RTCVideoCodecInfo] {
    let constrainedHighParams: [String: String] = [
      "profile-level-id": kRTCMaxSupportedH264ProfileLevelConstrainedHigh,
      "level-asymmetry-allowed": "1",
      "packetization-mode": "1",
    ]
    let constrainedHighInfo = RTCVideoCodecInfo(
      name: kRTCVideoCodecH264Name,
      parameters: constrainedHighParams
    )

    let constrainedBaselineParams: [String: String] = [
      "profile-level-id": kRTCMaxSupportedH264ProfileLevelConstrainedBaseline,
      "level-asymmetry-allowed": "1",
      "packetization-mode": "1",
    ]
    let constrainedBaselineInfo = RTCVideoCodecInfo(
      name: kRTCVideoCodecH264Name,
      parameters: constrainedBaselineParams
    )
    let vp8Info = RTCVideoCodecInfo(name: kRTCVideoCodecVp8Name)

    return [
      constrainedHighInfo,
      constrainedBaselineInfo,
    ]
  }

  func createDecoder(_ info: RTCVideoCodecInfo) -> RTCVideoDecoder? {
    if info.name == kRTCVideoCodecH264Name {
      return RTCVideoDecoderH264()
    } else if info.name == kRTCVideoCodecVp8Name {
      return RTCVideoDecoderVP8.vp8Decoder()
    }

    return nil
  }
}
