/// Representation of the `MediaStreamTrack` readiness.
enum MediaStreamTrackState {
  /// Indicates that the input is not giving any more data and will
  /// never provide new data.
  ended,

  /// Indicates that an input is connected and does its best-effort in
  /// providing real-time data.
  live,
}
