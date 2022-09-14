import Flutter

public class RtpSenderController {
    private var messenger: FlutterBinaryMessenger
    private var rtpSender: RtpSenderProxy
    private var channelId: String = ChannelNameGenerator.name(name: "RtpSender", id: ChannelNameGenerator.nextId())
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, rtpSender: RtpSenderProxy) {
        self.messenger = messenger
        self.rtpSender = rtpSender
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        switch (call.method) {
            case "replaceTrack":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId": self.channelId
        ]
    }
}
