import Flutter

public class PeerConnectionFactoryController {
    private var messenger: FlutterBinaryMessenger
    private var peerFactory: PeerConnectionFactoryProxy

    init(messenger: FlutterBinaryMessenger, peerFactory: PeerConnectionFactoryProxy) {
        self.messenger = messenger
        self.peerFactory = peerFactory
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch (call.method) {
            case "create":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
