public class LocalTrackIdGenerator {
    static let shared: LocalTrackIdGenerator = LocalTrackIdGenerator()
    private var lastId: Int = 0

    public func nextId() -> String {
        lastId += 1
        return "local-\(lastId)"
    }
}