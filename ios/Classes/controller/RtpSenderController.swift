import Flutter
import OSLog
import os

public class RtpSenderController {
    private var messenger: FlutterBinaryMessenger
    private var rtpSender: RtpSenderProxy
    private var channelId: Int = ChannelNameGenerator.nextId()
    private var channelName: String
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, rtpSender: RtpSenderProxy) {
        self.channelName = ChannelNameGenerator.name(name: "RtpSender", id: channelId)
        self.messenger = messenger
        self.rtpSender = rtpSender
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "replaceTrack":
                let trackId = argsMap!["trackId"] as? String
                var track: MediaStreamTrackProxy?
                if (trackId != nil) {
                    track = MediaStreamTrackStore.tracks[trackId!]
                } else {
                    track = nil
                }
                self.rtpSender.replaceTrack(t: track)
                result(nil)
            case "dispose":
                self.channel.setMethodCallHandler(nil)
                result(nil)
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
