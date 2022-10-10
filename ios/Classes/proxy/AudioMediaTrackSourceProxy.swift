///  Object representing a source of an input audio of an user.
///
///  This source can create new `MediaStreamTrackProxy`s with the same audio source.
///
///  Also, this object will track all child `MediaStreamTrackProxy`s and when they all disposed, will
///  dispose the underlying `AudioSource`.
class AudioMediaTrackSourceProxy: MediaTrackSource {
  /// Source `RTCMediaStreamTrack` which will be used for creating new tracks.
  private var track: RTCMediaStreamTrack

  /// Creates new `AudioMediaTrackSouceProxy` based on the provided track.
  init(track: RTCMediaStreamTrack) {
    self.track = track
  }

  /**
    Creates a new `MediaStreamTrackProxy`.

    - Returns: Newly created `MediaStreamTrackProxy`.
  */
  func newTrack() -> MediaStreamTrackProxy {
    return MediaStreamTrackProxy(track: self.track, deviceId: "audio", source: self)
  }
}
