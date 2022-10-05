import Flutter

/// Controller for the media devices management.
class MediaDevicesController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of media devices manager.
  private var mediaDevices: MediaDevices

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Controller for the `eventChannel` management.
  private var eventController: EventController

  /// Creates new `MediaDevicesController` for the provided `MediaDevices`.
  init(messenger: FlutterBinaryMessenger, mediaDevices: MediaDevices) {
    let channelName = ChannelNameGenerator.name(name: "MediaDevices", id: 0)
    let eventChannelName = ChannelNameGenerator.name(name: "MediaDevicesEvent", id: 0)
    self.messenger = messenger
    self.mediaDevices = mediaDevices
    self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    self.eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: messenger)
    self.eventController = EventController()
    self.eventChannel.setStreamHandler(eventController)
    self.channel.setMethodCallHandler({ (call, result) in
      try! self.onMethodCall(call: call, result: result)
    })
  }

  /// Handles all supported Flutter method calls for the `MediaDevices`.
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
