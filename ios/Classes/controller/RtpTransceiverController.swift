import Flutter

public class RtpTransceiverController {
    private var messenger: FlutterBinaryMessenger
    private var transceiver: RtpTransceiverProxy
    private var channelId: String = ChannelNameGenerator.name(name: "RtpTransceiver", id: ChannelNameGenerator.nextId())
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, transceiver: RtpTransceiverProxy) {
        self.messenger = messenger
        self.transceiver = transceiver
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
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

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId": self.channelId,
            "sender": RtpSenderController(messenger: self.messenger, rtpSender: transceiver.getSender()).asFlutterResult(),
            "mid": transceiver.getMid()
        ]
    }
}
