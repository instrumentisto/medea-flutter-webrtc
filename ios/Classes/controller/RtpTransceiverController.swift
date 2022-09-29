import Flutter

public class RtpTransceiverController {
    private var messenger: FlutterBinaryMessenger
    private var transceiver: RtpTransceiverProxy
    private var channelId: Int = ChannelNameGenerator.nextId()
    private var channelName: String
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, transceiver: RtpTransceiverProxy) {
        self.channelName = ChannelNameGenerator.name(name: "RtpTransceiver", id: self.channelId)
        self.messenger = messenger
        self.transceiver = transceiver
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "setDirection":
                let direction = argsMap!["direction"] as? Int
                self.transceiver.setDirection(direction: TransceiverDirection(rawValue: direction!)!)
                result(nil)
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
                let direction = self.transceiver.getDirection()
                result(direction.rawValue)
            case "stop":
                result(nil)
            case "dispose":
                result(nil)
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
