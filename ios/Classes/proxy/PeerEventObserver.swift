protocol PeerEventObserver {
  func onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy)
  func onIceConnectionStateChange(state: IceConnectionState)
  func onSignalingStateChange(state: SignalingState)
  func onConnectionStateChange(state: PeerConnectionState)
  func onIceGatheringStateChange(state: IceGatheringState)
  func onIceCandidate(candidate: IceCandidate)
  func onNegotiationNeeded()
}
