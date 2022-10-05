/// Store for all created `MediaStreamTrackProxy`s.
class MediaStreamTrackStore {
  /// All `MediaStreamTrackProxy`s created in this plugin.
  static var tracks: [String: MediaStreamTrackProxy] = [:]
}
