class PeerEventController: PeerEventObserver {
  private var eventController: EventController
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger, eventController: EventController) {
    self.messenger = messenger
    self.eventController = eventController
  }

  func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
    self.eventController.sendEvent(data: [
      "event": "onTrack",
      "track": MediaStreamTrackController(messenger: self.messenger, track: track)
        .asFlutterResult(),
      "transceiver": RtpTransceiverController(messenger: self.messenger, transceiver: transceiver)
        .asFlutterResult(),
    ])
  }

  func onIceConnectionStateChange(state: IceConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onIceConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  func onSignalingStateChange(state: SignalingState) {
    self.eventController.sendEvent(data: [
      "event": "onSignalingStateChange",
      "state": state.rawValue,
    ])
  }

  func onConnectionStateChange(state: PeerConnectionState) {
    self.eventController.sendEvent(data: [
      "event": "onConnectionStateChange",
      "state": state.rawValue,
    ])
  }

  func onIceGatheringStateChange(state: IceGatheringState) {
    self.eventController.sendEvent(data: [
      "event": "onIceGatheringStateChange",
      "state": state.rawValue,
    ])
  }

  func onIceCandidate(candidate: IceCandidate) {
    self.eventController.sendEvent(data: [
      "event": "onIceCandidate",
      "candidate": candidate.asFlutterResult(),
    ])
  }

  func onNegotiationNeeded() {
    self.eventController.sendEvent(data: [
      "event": "onNegotiationNeeded"
    ])
  }
}
