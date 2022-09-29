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
                    // os_log(OSLogType.error, "RTPSender replaceTrack with trackId: %@", trackId!);
                    track = MediaStreamTrackStore.tracks[trackId!]
                    // os_log(OSLogType.error, "RTPSender replaceTrack with track is not nil: %@", (track != nil));
                } else {
                    // os_log(OSLogType.error, "RTPSender replaceTrack with nil");
                    track = nil
                }
                self.rtpSender.replaceTrack(t: track)
                result(nil)
            case "dispose":
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
