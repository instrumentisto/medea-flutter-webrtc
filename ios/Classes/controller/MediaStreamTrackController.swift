import Flutter

public class MediaStreamTrackController {
    private var messenger: FlutterBinaryMessenger
    private var track: MediaStreamTrackProxy
    private var channelId: String = ChannelNameGenerator.name(name: "MediaStreamTrack", id: ChannelNameGenerator.nextId())
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
        self.messenger = messenger
        self.track = track
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "setEnabled":
                let enabled = argsMap!["enabled"] as? Bool
                self.track.setEnabled(enabled: enabled!)
                result(nil)
            case "state":
                result(self.track.state().asFlutterResult())
            case "stop":
                self.track.stop()
            case "clone":
                result(MediaStreamTrackController(self.messenger, self.track.fork()).asFlutterResult())
            case "dispose":
                self.channel.setMethodChannel(nil)
                result.success(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId" : self.channelId,
            "id" : self.track.id(),
            "kind" : self.track.kind().asFlutterResult(),
            "deviceId" : self.deviceId
        ]
    }
}
