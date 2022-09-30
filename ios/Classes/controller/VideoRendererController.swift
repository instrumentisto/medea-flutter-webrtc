import Flutter

class VideoRendererController {
    private var messenger: FlutterBinaryMessenger
    private var renderer: FlutterRtcVideoRenderer
    private var channelId: Int = ChannelNameGenerator.nextId()
    private var eventChannelId: Int = ChannelNameGenerator.nextId()
    private var eventChannelName: String;
    private var channel: FlutterMethodChannel
    private var channelName: String
    private var eventChannel: FlutterEventChannel
    private var eventController: EventController

    init(messenger: FlutterBinaryMessenger, renderer: FlutterRtcVideoRenderer) {
        self.channelName  = ChannelNameGenerator.name(name: "VideoRenderer", id: self.channelId)
        self.eventChannelName  = ChannelNameGenerator.name(name: "VideoRendererEvent", id: self.channelId)
        self.messenger = messenger
        self.renderer = renderer
        self.channel = FlutterMethodChannel(name: self.channelName, binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: self.eventChannelName, binaryMessenger: messenger)
        self.eventController = EventController()
        self.renderer.subscribe(sub: VideoRendererEventController(messenger: self.messenger, eventController: self.eventController))
        self.eventChannel.setStreamHandler(eventController)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "setSrcObject":
                let trackId = argsMap!["trackId"] as? String
                var track: MediaStreamTrackProxy?
                if (trackId != nil) {
                    track = MediaStreamTrackStore.tracks[trackId!]
                } else {
                    track = nil
                }
                self.renderer.setVideoTrack(newTrack: track)
                result(nil)
            case "dispose":
                self.renderer.dispose()
                self.channel.setMethodCallHandler(nil)
                self.eventChannel.setStreamHandler(nil)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId" : self.channelId,
            "textureId": self.renderer.getTextureId(),
        ]
    }
}