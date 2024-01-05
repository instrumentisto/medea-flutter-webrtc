package com.instrumentisto.medea_flutter_webrtc.model

import android.media.MediaCodecInfo
import android.os.Build

/**
 * Video codec kind.
 *
 * @property value [String] representation of this enum which will be expected on the Flutter side.
 */
enum class VideoCodecMimeType(val value: String) {
  VP8("video/x-vnd.on2.vp8"),
  VP9("video/x-vnd.on2.vp9"),
  H264("video/avc"),
  AV1("video/av01"),
  H265("video/hevc")
}

/**
 * Represents an information about video codec.
 *
 * @property isHardwareAccelerated Identifier of the HW accelerated.
 * @property kind codec kind of the video codec.
 * @property mime type of the video codec.
 */
data class VideoCodecInfo(
    val isHardwareAccelerated: Boolean,
    val kind: VideoCodecMimeType,
    val mimeType: String,
) {
  companion object {
    private const val EXYNOS_PREFIX: String = "OMX.Exynos."
    private const val INTEL_PREFIX = "OMX.Intel."
    private const val QCOM_PREFIX = "OMX.qcom."
    private val H264_HW_EXCEPTION_MODELS = listOf("SAMSUNG-SGH-I337", "Nexus 7", "Nexus 4")
    var enableIntelVp8Encoder = true

    fun isHardwareSupportedInCurrentSdkVp8(mimeType: String): Boolean {
      // QCOM Vp8 encoder is always supported.
      return mimeType.startsWith(QCOM_PREFIX)
      // Exynos VP8 encoder is supported in M or later.
      ||
          (mimeType.startsWith(EXYNOS_PREFIX) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
          // Intel Vp8 encoder is always supported, with the intel encoder enabled.
          ||
          (mimeType.startsWith(INTEL_PREFIX) && enableIntelVp8Encoder)
    }

    fun isHardwareSupportedInCurrentSdkVp9(mimeType: String): Boolean {
      return (mimeType.startsWith(QCOM_PREFIX) || mimeType.startsWith(EXYNOS_PREFIX))
      // Both QCOM and Exynos VP9 encoders are supported in N or later.
      && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
    }

    fun isHardwareSupportedInCurrentSdkH264(mimeType: String): Boolean {
      // First, H264 hardware might perform poorly on this model.
      if (H264_HW_EXCEPTION_MODELS.contains(Build.MODEL)) {
        return false
      }
      // QCOM and Exynos H264 encoders are always supported.
      return mimeType.startsWith(QCOM_PREFIX) || mimeType.startsWith(EXYNOS_PREFIX)
    }

    fun isHardwareSupportedInCurrentSdk(codecInfo: MediaCodecInfo): Boolean {
      val codec = VideoCodecMimeType.values().find { it.value == codecInfo.supportedTypes[0] }
      return when (codec) {
        VideoCodecMimeType.VP8 -> isHardwareSupportedInCurrentSdkVp8(codecInfo.name)
        VideoCodecMimeType.VP9 -> isHardwareSupportedInCurrentSdkVp9(codecInfo.name)
        VideoCodecMimeType.H264 -> isHardwareSupportedInCurrentSdkH264(codecInfo.name)
        else -> false
      }
    }
  }

  /** Converts this [VideoCodecInfo] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> =
      mapOf(
          "isHardwareAccelerated" to isHardwareAccelerated,
          "kind" to kind.ordinal,
          "mimeType" to mimeType)
}
