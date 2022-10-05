/// Controller for the PeerConnection events.
class PeerEventController: PeerEventObserver {
  /// Controller for the PeerConnection event channel.
  private var eventController: EventController

  /// Flutter messenger for creating another controllers.
  private var messenger: FlutterBinaryMessenger

  /// Creates new controller for sending all `PeerConnectionProxy` events to the Flutter side.
  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  /// Sends `onTrack` event to the Flutter side.
  func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
    self.eventController.sendEvent(data: [
      "event": "onTrack",
      "track": MediaStreamTrackController(messenger: self.messenger, track: track)
        .asFlutterResult(),
      "transceiver": RtpTransceiverController(messenger: self.messenger, transceiver: transceiver)
        .asFlutterResult(),
    ])
  }

  /// Sends `onIceConnectionStateChange` event to the Flutter side.
  func onIceConnectionStateChange(state: IceConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onIceConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends `onSignalingStateChange` event to the Flutter side.
  func onSignalingStateChange(state: SignalingState) {
    self.eventController.sendEvent(data: [
      "event": "onSignalingStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends `onConnectionStateChange` event to the Flutter side.
  func onConnectionStateChange(state: PeerConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends `onIceGatheringStateChange` event to the Flutter side.
  func onIceGatheringStateChange(state: IceGatheringState) {
    self.eventController.sendEvent(data: [
      "event": "onIceGatheringStateChange",
      "state": state.rawValue,
    ])
  }

  /// Sends `onIceCandidate` event to the Flutter side.
  func onIceCandidate(candidate: IceCandidate) {
    self.eventController.sendEvent(data: [
      "event": "onIceCandidate",
      "candidate": candidate.asFlutterResult(),
    ])
  }

  /// Sends `onNegotiationNeeded` event to the Flutter side.
  func onNegotiationNeeded() {
    self.eventController.sendEvent(data: [
      "event": "onNegotiationNeeded"
    ])
  }
}
