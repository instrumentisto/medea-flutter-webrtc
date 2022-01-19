enum IceConnectionState {
  new_,
  checking,
  connected,
  completed,
  failed,
  disconnected,
  closed,
}

enum IceGatheringState {
  new_,
  gathering,
  complete,
}

enum SignalingState {
  stable,
  haveLocalOffer,
  haveLocalPranswer,
  haveRemoteOffer,
  haveRemotePranswer,
  closed,
}

enum PeerConnectionState {
  new_,
  connecting,
  connected,
  disconnected,
  failed,
  closed,
}
