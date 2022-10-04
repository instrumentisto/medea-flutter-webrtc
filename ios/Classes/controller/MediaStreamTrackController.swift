import Flutter
import OSLog
import os

public class MediaStreamTrackController {
    private var messenger: FlutterBinaryMessenger
    private var track: MediaStreamTrackProxy
    private var channelName: String
    private var channelId: Int = ChannelNameGenerator.nextId()
    private var channel: FlutterMethodChannel
    private var eventChannel: FlutterEventChannel
    private var eventController: EventController

    init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
        self.channelName = ChannelNameGenerator.name(name: "MediaStreamTrack", id: self.channelId)
        self.eventChannel = FlutterEventChannel(name: ChannelNameGenerator.name("MediaStreamTrackEvent", self.channelId), binaryMessenger: messenger)
        self.eventController = EventController()
        self.messenger = messenger
        self.track = track
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
        self.eventChannel.setStreamHandler(self.eventController)
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
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
                result(nil)
            case "clone":
                result(MediaStreamTrackController(messenger: self.messenger, track: try self.track.fork()).asFlutterResult())
            case "dispose":
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
