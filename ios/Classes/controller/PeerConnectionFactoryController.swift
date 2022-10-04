import Flutter
import OSLog
import os

public class PeerConnectionFactoryController {
  private var messenger: FlutterBinaryMessenger
  private var peerFactory: PeerConnectionFactoryProxy
  private var channelId: String = ChannelNameGenerator.name(name: "PeerConnectionFactory", id: 0)
  private var channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger, state: State) {
    self.messenger = messenger
    self.peerFactory = PeerConnectionFactoryProxy(state: state)
    self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
    self.channel.setMethodCallHandler({ (call, result) in
      try! self.onMethodCall(call: call, result: result)
    })
  }

  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
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
