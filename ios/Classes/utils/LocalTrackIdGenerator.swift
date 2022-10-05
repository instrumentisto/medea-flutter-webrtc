/// Unique ID generator for the all local `MediaStreamTrackProxy`s.
class LocalTrackIdGenerator {
  /// Singleton instance of `LocalTrackIdGenerator`.
  static let shared: LocalTrackIdGenerator = LocalTrackIdGenerator()

  /// Last generated track ID.
  private var lastId: Int = 0

  /// Returns new local `MediaStreamTrackProxy` unique ID.
  func nextId() -> String {
    lastId += 1
    return "local-\(lastId)"
  }
}
