import Flutter
import OSLog
import os

public class MediaStreamTrackController {
    private var messenger: FlutterBinaryMessenger
    private var track: MediaStreamTrackProxy
    private var channelId: String = ChannelNameGenerator.name(name: "MediaStreamTrack", id: ChannelNameGenerator.nextId())
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
        self.messenger = messenger
        self.track = track
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "setEnabled":
                os_log(OSLogType.error, "setEnabled")
                let enabled = argsMap!["enabled"] as? Bool
                self.track.setEnabled(enabled: enabled!)
                result(nil)
            case "state":
                os_log(OSLogType.error, "state")
                result(self.track.state().asFlutterResult())
            case "stop":
                os_log(OSLogType.error, "stop")
                self.track.stop()
                result(nil)
            case "clone":
                os_log(OSLogType.error, "clone")
                result(MediaStreamTrackController(messenger: self.messenger, track: try self.track.fork()).asFlutterResult())
            case "dispose":
                os_log(OSLogType.error, "dispose")
                self.channel.setMethodCallHandler(nil)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId" : self.channelId,
            "id" : self.track.id(),
            "kind" : self.track.kind().asFlutterResult(),
            "deviceId" : self.track.getDeviceId()
        ]
    }
}
