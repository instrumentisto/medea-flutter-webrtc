import Flutter

/// Controller for the `PeerConnection` factory management.
class PeerConnectionFactoryController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of `PeerConnection` factory manager.
  private var peerFactory: PeerConnectionFactoryProxy

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /**
    Creates a new `PeerConnectionFactoryController` and `PeerConnectionFactoryProxy`
    based on provided `state`.
  */
  init(messenger: FlutterBinaryMessenger, state: State) {
    let channelName = ChannelNameGenerator.name(name: "PeerConnectionFactory", id: 0)
    self.messenger = messenger
    self.peerFactory = PeerConnectionFactoryProxy(state: state)
    self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    self.channel.setMethodCallHandler({ (call, result) in
      self.onMethodCall(call: call, result: result)
    })
  }

  /// Handles all supported Flutter method calls for the `PeerConnectionFactoryProxy`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "create":
      let iceTransportTypeArg = argsMap!["iceTransportType"] as? Int
      let iceTransportType = IceTransportType(rawValue: iceTransportTypeArg!)!
      let iceServersArg = argsMap!["iceServers"] as? [Any]

      let iceServers = iceServersArg!.map({ iceServerArg -> IceServer in
        let iceServer = iceServerArg as? [String: Any]
        let urlsArg = iceServer!["urls"] as? [String]
        let username = iceServer!["username"] as? String
        let password = iceServer!["password"] as? String

        return IceServer(urls: urlsArg!, username: username, password: password)
      })
      let conf = PeerConnectionConfiguration(
        iceServers: iceServers, iceTransportType: iceTransportType)
      let peer = PeerConnectionController(
        messenger: self.messenger, peer: self.peerFactory.create(conf: conf))
      result(peer.asFlutterResult())
    case "dispose":
      self.channel.setMethodCallHandler(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
