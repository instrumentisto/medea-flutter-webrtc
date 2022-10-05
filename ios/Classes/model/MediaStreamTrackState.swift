/// Representation of a [MediaStreamTrack] readiness.
enum MediaStreamTrackState: Int {
  /// Indicates that an input is connected and does its best-effort in providing real-time data.
  case live

  /// Indicates that an input is not giving any more data and will never provide new data.
  case ended
}
