import Flutter

public class RtpTransceiverController {
    private var messenger: FlutterBinaryMessenger
    private var transceiver: RtpTransceiverProxy

    init(messenger: FlutterBinaryMessenger, transceiver: RtpTransceiverProxy) {
        self.messenger = messenger
        self.transceiver = transceiver
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "setDirection":
                abort()
            case "setRecv":
                let enabled = argsMap!["enabled"] as? Bool
                self.transceiver.setRecv(recv: enabled!)
                result(nil)
            case "setSend":
                let enabled = argsMap!["enabled"] as? Bool
                self.transceiver.setSend(send: enabled!)
                result(nil)
            case "getMid":
                let mid = self.transceiver.getMid()
                result(mid)
            case "getDirection":
                abort()
            case "stop":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
