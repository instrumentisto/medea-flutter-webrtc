///  Object representing a source of an input audio of an user.
///
///  This source can create new `MediaStreamTrackProxy`s with the same audio source.
///
///  Also, this object will track all child `MediaStreamTrackProxy`s and when they all disposed, will
///  dispose the underlying `AudioSource`.
class AudioMediaTrackSourceProxy: MediaTrackSource {
  // TODO: Does it need to be nullable?
  /// Source `MediaStreamTrackProxy` which will be used for creating new tracks.
  private var track: MediaStreamTrackProxy?

  /**
    Creates a new `MediaStreamTrackProxy`.

    - Returns: Newly created `MediaStreamTrackProxy`.
  */
  func newTrack() -> MediaStreamTrackProxy {
    self.track!
  }

  /// Sets source `MediaStreamTrackProxy` as source.
  func setTrack(track: MediaStreamTrackProxy) {
    self.track = track
  }
}
