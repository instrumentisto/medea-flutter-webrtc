import Flutter

public class MediaDevicesController {
    private var messenger: FlutterBinaryMessenger
    private var mediaDevices: MediaDevices
    private var channelId: String = ChannelNameGenerator.name(name: "MediaDevices", id: 0)
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, mediaDevices: MediaDevices) {
        self.messenger = messenger
        self.mediaDevices = mediaDevices
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        switch (call.method) {
            case "enumerateDevices":
                result(self.mediaDevices.enumerateDevices().map { $0.asFlutterResult() })
            case "getUserMedia":
                let tracks = self.mediaDevices.getUserMedia()
                return result(tracks.map { MediaStreamTrackController(messenger: self.messenger, track: $0).asFlutterResult() })
            case "setOutputAudioId":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
