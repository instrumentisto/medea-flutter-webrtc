class AudioMediaTrackSourceProxy: MediaTrackSource {
  private var track: MediaStreamTrackProxy?

  func newTrack() -> MediaStreamTrackProxy {
    return self.track!
  }

  func setTrack(track: MediaStreamTrackProxy) {
    self.track = track
  }
}
