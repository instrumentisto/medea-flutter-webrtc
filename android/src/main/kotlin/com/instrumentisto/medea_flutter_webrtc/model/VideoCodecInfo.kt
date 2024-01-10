package com.instrumentisto.medea_flutter_webrtc.model

/**
 * Video codec kind.
 *
 * @property value [String] representation of this enum which will be expected on the Flutter side.
 */
enum class VideoCodec {
  VP8,
  VP9,
  H264,
  AV1,
  H265;

  companion object {
    fun valueOfOrNull(name: String): VideoCodec? {
      return values().firstOrNull { it.name == name }
    }
  }
}

/**
 * Represents an information about video codec.
 *
 * @property isHardwareAccelerated Identifier of the HW accelerated.
 * @property codec video codec kind.
 */
data class VideoCodecInfo(
    val codec: VideoCodec,
    val isHardwareAccelerated: Boolean,
) {
  /** Converts this [VideoCodecInfo] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> =
      mapOf("isHardwareAccelerated" to isHardwareAccelerated, "codec" to codec.ordinal)
}
