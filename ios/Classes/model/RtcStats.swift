class RtcStats {
  var statsList: [[String: Any]] = []

  init(report: RTCStatisticsReport) {
    for (_, stats) in report.statistics {
      var statDetails: [String: Any] = [:]
      statDetails["id"] = stats.id
      statDetails["type"] = stats.type
      statDetails["timestampUs"] = Int(stats.timestamp_us * 1000.0)

      for (statName, statValue) in stats.values {
        statDetails[statName] = statValue
      }

      self.statsList.append(statDetails)
    }
  }

  func asFlutterResult() -> [[String: Any]] {
    return self.statsList
  }
}
