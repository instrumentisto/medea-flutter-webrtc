package com.instrumentisto.medea_flutter_webrtc.model

//todo
data class Stats(
    val type: String,
    val id: String,
    val timestampUs: Long,
    val kind: Map<String, Any>
) {
  companion object {
    fun fromWebRtc(stats: org.webrtc.RTCStats): Stats {
      var members = stats.members
      return Stats(stats.type, stats.id, stats.timestampUs.toLong(), members)
    }
  }
//todo

  fun asFlutterResult(): Map<String, Any> {
    return mapOf("id" to id, "timestampUs" to timestampUs, "kind" to kind, "type" to type)
  }
}

data class StatsReport(val stats: Map<String, Stats>) {
  companion object {
//todo

    fun fromWebRtc(report: org.webrtc.RTCStatsReport): StatsReport {
      return StatsReport(report.statsMap.mapValues { Stats.fromWebRtc(it.value) })
    }
  }
//todo

  fun asFlutterResult(): List<Map<String, Any>> {
    return stats.map { it.value.asFlutterResult() }
  }
}
