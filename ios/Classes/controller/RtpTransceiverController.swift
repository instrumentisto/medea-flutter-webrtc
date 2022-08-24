import Flutter

public class RtpTransceiverController {
    private var messenger: FlutterBinaryMessenger
    private var transceiver: RtpTransceiverProxy

    init(messenger: FlutterBinaryMessenger, transceiver: RtpTransceiverProxy) {
        self.messenger = messenger
        self.transceiver = transceiver
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        let argsMap = call.arguments
        switch (call.method) {
            case "setDirection":
                abort()
            case "setRecv":
                let enabled: Bool = argsMap["enabled"]
                self.transceiver.setRecv(enabled)
            case "setSend":
                let enabled: Bool = argsMap["enabled"]
                self.transceiver.setSend(enabled)
            case "getMid":
                abort()
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
