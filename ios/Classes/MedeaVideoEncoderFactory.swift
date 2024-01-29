import WebRTC

class MedeaVideoEncoderFactory: NSObject, RTCVideoEncoderFactory {
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
      vp8Info,
    ]
  }

  func createEncoder(_ info: RTCVideoCodecInfo) -> RTCVideoEncoder? {
    if info.name == kRTCVideoCodecH264Name {
      return RTCVideoEncoderH264(codecInfo: info)
    } else if info.name == kRTCVideoCodecVp8Name {
      return RTCVideoEncoderVP8.vp8Encoder()
    }

    return nil
  }
}
