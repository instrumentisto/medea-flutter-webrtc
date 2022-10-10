import Flutter

/// Controller for the `MediaStreamTrack`.
class MediaStreamTrackController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of `MediaStreamTrack` proxy.
  private var track: MediaStreamTrackProxy

  /// ID of channels created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Controller for the `eventChannel` management.
  private var eventController: EventController

  /// Creates new `MediaStreamTrackController` for the provided `MediaStreamTrackProxy`.
  init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
    let channelName = ChannelNameGenerator.name(name: "MediaStreamTrack", id: self.channelId)
    self.eventChannel = FlutterEventChannel(
      name: ChannelNameGenerator.name(name: "MediaStreamTrackEvent", id: self.channelId),
      binaryMessenger: messenger)
    self.eventController = EventController()
    self.messenger = messenger
    self.track = track
    self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    self.channel.setMethodCallHandler({ (call, result) in
      self.onMethodCall(call: call, result: result)
    })
    self.eventChannel.setStreamHandler(self.eventController)
    self.track.onEnded(cb: {
      self.eventController.sendEvent(data: [
        "event": "onEnded"
      ])
    })
  }

  /// Handles all supported Flutter method calls for the `MediaStreamTrackProxy`.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "setEnabled":
      let enabled = argsMap!["enabled"] as? Bool
      self.track.setEnabled(enabled: enabled!)
      result(nil)
    case "state":
      result(self.track.state().rawValue)
    case "stop":
      self.track.stop()
      result(nil)
    case "clone":
      do {
        result(
          MediaStreamTrackController(messenger: self.messenger, track: try self.track.fork())
            .asFlutterResult())
      } catch {
        result(error)
      }
    case "dispose":
      self.channel.setMethodCallHandler(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Converts this controller to the Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    [
      "channelId": channelId,
      "id": track.id(),
      "kind": track.kind().rawValue,
      "deviceId": track.getDeviceId(),
    ]
  }
}
