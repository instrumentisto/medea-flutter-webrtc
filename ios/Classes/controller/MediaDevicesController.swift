import Flutter

public class MediaDevicesController {
  private var messenger: FlutterBinaryMessenger
  private var mediaDevices: MediaDevices
  private var channelId: String = ChannelNameGenerator.name(name: "MediaDevices", id: 0)
  private var channel: FlutterMethodChannel
  private var eventChannel: FlutterEventChannel
  private var eventController: EventController

  init(messenger: FlutterBinaryMessenger, mediaDevices: MediaDevices) {
    self.messenger = messenger
    self.mediaDevices = mediaDevices
    self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
    self.eventChannel = FlutterEventChannel(
      name: ChannelNameGenerator.name(name: "MediaDevicesEvent", id: 0), binaryMessenger: messenger)
    self.eventController = EventController()
    self.eventChannel.setStreamHandler(eventController)
    self.channel.setMethodCallHandler({ (call, result) in
      try! self.onMethodCall(call: call, result: result)
    })
  }

  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) throws {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "enumerateDevices":
      result(self.mediaDevices.enumerateDevices().map { $0.asFlutterResult() })
    case "getUserMedia":
      let constraintsArg = argsMap!["constraints"] as? [String: Any]
      let tracks = self.mediaDevices.getUserMedia(constraints: Constraints(map: constraintsArg!))
      return result(
        tracks.map {
          MediaStreamTrackController(messenger: self.messenger, track: $0).asFlutterResult()
        })
    case "setOutputAudioId":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
