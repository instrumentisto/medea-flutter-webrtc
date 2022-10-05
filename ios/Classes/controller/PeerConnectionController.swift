import Flutter

/// Controller for the `PeerConnection`.
class PeerConnectionController {
  /// Flutter messenger for creating channels.
  private var messenger: FlutterBinaryMessenger

  /// Instance of the proxy of PeerConnection.
  private var peer: PeerConnectionProxy

  /// ID of channels created for this controller.
  private var channelId: Int = ChannelNameGenerator.nextId()

  /// Controller for the `eventChannel` management.
  private var eventController: EventController

  /// Event channel for communicating with Flutter side.
  private var eventChannel: FlutterEventChannel

  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Creates new `PeerConnectionController` for the provided `PeerConnectionProxy`.
  init(messenger: FlutterBinaryMessenger, peer: PeerConnectionProxy) {
    let channelName = ChannelNameGenerator.name(name: "PeerConnection", id: self.channelId)
    self.eventController = EventController()
    self.messenger = messenger
    self.peer = peer
    self.peer.addEventObserver(
      eventObserver: PeerEventController(
        messenger: self.messenger, eventController: self.eventController))
    self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    self.eventChannel = FlutterEventChannel(
      name: ChannelNameGenerator.name(name: "PeerConnectionEvent", id: self.channelId),
      binaryMessenger: messenger)
    self.channel.setMethodCallHandler({ (call, result) in
      try! self.onMethodCall(call: call, result: result)
    })
    self.eventChannel.setStreamHandler(self.eventController)
  }

  /// Handles all supported Flutter method calls for the `PeerConnectionProxy`.
  func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "createOffer":
      Task {
        let sdp = try! await self.peer.createOffer()
        result(sdp.asFlutterResult())
      }
    case "createAnswer":
      Task {
        let sdp = try! await self.peer.createAnswer()
        result(sdp.asFlutterResult())
      }
    case "setLocalDescription":
      let description = argsMap!["description"] as? [String: Any]
      let type = description!["type"] as? Int
      let sdp = description!["description"] as? String
      Task {
        var desc: SessionDescription?
        if sdp == nil {
          desc = nil
        } else {
          desc = SessionDescription(
            type: SessionDescriptionType(rawValue: type!)!, description: sdp!)
        }
        try! await self.peer.setLocalDescription(description: desc)
        result(nil)
      }
    case "setRemoteDescription":
      let descriptionMap = argsMap!["description"] as? [String: Any]
      let type = descriptionMap!["type"] as? Int
      let sdp = descriptionMap!["description"] as? String
      Task {
        try! await self.peer.setRemoteDescription(
          description: SessionDescription(
            type: SessionDescriptionType(rawValue: type!)!, description: sdp!))
        result(nil)
      }
    case "addIceCandidate":
      let candidateMap = argsMap!["candidate"] as? [String: Any]
      let sdpMid = candidateMap!["sdpMid"] as? String
      let sdpMLineIndex = candidateMap!["sdpMLineIndex"] as? Int
      let candidate = candidateMap!["candidate"] as? String
      Task {
        try! await self.peer.addIceCandidate(
          candidate: IceCandidate(
            sdpMid: sdpMid!, sdpMLineIndex: sdpMLineIndex!, candidate: candidate!))
        result(nil)
      }
    case "addTransceiver":
      let mediaType = argsMap!["mediaType"] as? Int
      let initArgs = argsMap!["init"] as? [String: Any]
      let direction = initArgs!["direction"] as? Int
      let transceiverInit = TransceiverInit(direction: TransceiverDirection(rawValue: direction!)!)
      let transceiver = RtpTransceiverController(
        messenger: self.messenger,
        transceiver: self.peer.addTransceiver(
          mediaType: MediaType(rawValue: mediaType!)!, transceiverInit: transceiverInit))
      result(transceiver.asFlutterResult())
    case "getTransceivers":
      result(
        self.peer.getTransceivers().map {
          RtpTransceiverController(messenger: self.messenger, transceiver: $0).asFlutterResult()
        })
    case "restartIce":
      self.peer.restartIce()
      result(nil)
    case "dispose":
      self.channel.setMethodCallHandler(nil)
      self.eventChannel.setStreamHandler(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Converts this controller to the Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    return [
      "channelId": self.channelId,
      "id": self.peer.getId(),
    ]
  }
}
