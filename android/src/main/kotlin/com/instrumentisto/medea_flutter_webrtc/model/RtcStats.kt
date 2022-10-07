package com.instrumentisto.medea_flutter_webrtc.model

/**
 * Representation of an [org.webrtc.RTCStats].
 *
 * @property type `type` of this [RtcStats].
 * @property id `id` of this [RtcStats].
 * @property timestampUs `timestampUs` of this [RtcStats].
 * @property kind map of stats of this [RtcStats].
 */
data class RtcStats(
    val type: String,
    val id: String,
    val timestampUs: Long,
    val kind: Map<String, Any>
) {
  companion object {
    /**
     * Converts the provided [org.webrtc.RTCStats] into an [RtcStats].
     *
     * @return [RtcStats] created based on the provided [org.webrtc.RTCStats].
     */
    fun fromWebRtc(stats: org.webrtc.RTCStats): RtcStats {
      var members = stats.members
      return RtcStats(stats.type, stats.id, stats.timestampUs.toLong(), members)
    }
  }

  /** Converts this [RtcStatsReport] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> {
    return mapOf("id" to id, "timestampUs" to timestampUs, "kind" to kind, "type" to type)
  }
}
