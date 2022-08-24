import Flutter

public class RtpSenderController {
    private var messenger: FlutterBinaryMessenger
    private var rtpSender: RtpSenderProxy

    init(messenger: FlutterBinaryMessenger, rtpSender: RtpSenderProxy) {
        self.messenger = messenger
        self.rtpSender = rtpSender
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch (call.method) {
            case "replaceTrack":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
