public class ChannelNameGenerator {
    private static let prefix: String = "FlutterWebRtc"
    private static var lastId: Int = 0

    static func nextId() -> Int {
        ChannelNameGenerator.lastId += 1
        return lastId
    }

    static func name(name: String, id: Int) -> String {
        return "\(ChannelNameGenerator.prefix)/\(name)/\(id)"
    }
}
