/// Interface which can create new `MediaStreamTrackProxy`s from some media device.
protocol MediaTrackSource {
  /// Creates a new `MediaStreamTrackProxy` based on this `MediaTrackSource`.
  func newTrack() -> MediaStreamTrackProxy
}
