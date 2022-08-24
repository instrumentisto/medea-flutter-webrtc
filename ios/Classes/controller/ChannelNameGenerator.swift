public class ChannelNameGenerator {
    private static let prefix: String = "FlutterWebRtc"

    func name(name: String, id: Number) -> String {
        return "\(ChannelNameGenerator.prefix)/\(name)/\(id)"
    }
}
