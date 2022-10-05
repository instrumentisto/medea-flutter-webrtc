class LocalTrackIdGenerator {
  static let shared: LocalTrackIdGenerator = LocalTrackIdGenerator()
  private var lastId: Int = 0

  func nextId() -> String {
    lastId += 1
    return "local-\(lastId)"
  }
}
