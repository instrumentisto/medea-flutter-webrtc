/// Generator of names for Flutter method/event channels.
public class ChannelNameGenerator {
  /// Static prefix for all channels of this plugin
  private static let prefix: String = "FlutterWebRtc"

  /// Last generated ID.
  private static var lastId: Int = 0

  /// Returns new ID for the channel.
  static func nextId() -> Int {
    ChannelNameGenerator.lastId += 1
    return lastId
  }

  /// Returns name for the channel with provided name and ID.
  static func name(name: String, id: Int) -> String {
    return "\(ChannelNameGenerator.prefix)/\(name)/\(id)"
  }
}
