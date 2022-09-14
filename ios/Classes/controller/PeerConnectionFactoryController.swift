import Flutter

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
        switch (call.method) {
            case "create":
                let peer = PeerConnectionController(messenger: self.messenger, peer: self.peerFactory.create())
                result(peer.asFlutterResult())
            case "dispose":
                self.channel.setMethodCallHandler(nil)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
