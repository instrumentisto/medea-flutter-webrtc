import Flutter

public class PeerConnectionController {
    private var messenger: FlutterBinaryMessenger
    private var peer: PeerConnectionProxy

    init(messenger: FlutterBinaryMessenger, peer: PeerConnectionProxy) {
        self.messenger = messenger
        self.peer = peer
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch (call.method) {
            case "createOffer":
                abort()
            case "createAnswer":
                abort()
            case "setLocalDescription":
                abort()
            case "setRemoteDescription":
                abort()
            case "addIceCandidate":
                abort()
            case "addTransceiver":
                abort()
            case "getTransceivers":
                abort()
            case "restartIce":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
