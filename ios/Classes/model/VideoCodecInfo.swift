
/// Video codecs.
enum VideoCodec: Int {
  /// VP8 video codec.
  case VP8

  /// VP9 video codec.
  case VP9

  /// H264 video codec.
  case H264

  /// AV1 video codec.
  case AV1

  /// H265 video codec.
  case H265
}

/// Represents an information about video codec.
class VideoCodecInfo {
  /// Identifier of the HW accelerated.
  private var isHardwareAccelerated: Bool

  /// Codec kind of the video codec.
  private var codec: VideoCodec

  /// Initializes a new `VideoCodecInfo` with the provided data.
  init(isHardwareAccelerated: Bool, codec: VideoCodec) {
    self.isHardwareAccelerated = isHardwareAccelerated
    self.codec = codec
  }

  /// Converts this controller into a Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    [
      "isHardwareAccelerated": self.isHardwareAccelerated,
      "codec": self.codec.rawValue,
    ]
  }
}
