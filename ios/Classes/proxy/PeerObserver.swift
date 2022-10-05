import Dispatch
import WebRTC

/// Observer for native `RTCPeerConnectionDelegate`.
class PeerObserver: NSObject, RTCPeerConnectionDelegate {
  /// `PeerConnectionProxy` into which callbacks will be provided.
  var peer: PeerConnectionProxy?

  override init() {}

  /// Sets underlying `PeerConnectionProxy` for this `PeerObserver`.
  func setPeer(peer: PeerConnectionProxy) {
    self.peer = peer
  }

  /// Fires `onSignalingStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onSignalingStateChange(
        state: SignalingState.fromWebRtc(state: stateChanged))
    }
  }

  /// Fires `onIceConnectionStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceConnectionStateChange(
        state: IceConnectionState.fromWebRtc(state: newState))
    }
  }

  /// Fires `onConnectionStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onConnectionStateChange(
        state: PeerConnectionState.fromWebRtc(state: newState))
    }
  }

  /// Fires `onIceGatheringStateChange` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceGatheringStateChange(
        state: IceGatheringState.fromWebRtc(state: newState))
    }
  }

  /// Fires `onIceCandidate` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceCandidate(
        candidate: IceCandidate(candidate: candidate))
    }
  }

  /// Fires `onTrack` callback in the `PeerConnectionProxy`.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver
  ) {
    DispatchQueue.main.async {
      let track = transceiver.receiver.track!
      self.peer!.broadcastEventObserver().onTrack(
        track: MediaStreamTrackProxy(track: track, deviceId: nil, source: nil),
        transceiver: RtpTransceiverProxy(transceiver: transceiver))
    }
  }

  /// Does nothing.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didAdd receiver: RTCRtpReceiver,
    streams mediaStreams: [RTCMediaStream]
  ) {
  }

  /// Does nothing.
  func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
  }

  /// Does nothing.
  func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
  }

  /// Does nothing.
  func peerConnection(_ peerConnection: RTCPeerConnection, didOpen stream: RTCDataChannel) {
  }

  /// Does nothing.
  func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
  }

  /// Does nothing.
  func peerConnection(
    _ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]
  ) {
  }
}
