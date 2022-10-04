import Dispatch
import OSLog
import WebRTC
import os

public class PeerObserver: NSObject, RTCPeerConnectionDelegate {
  var peer: PeerConnectionProxy?

  override init() {}

  public func setPeer(peer: PeerConnectionProxy) {
    self.peer = peer
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onSignalingStateChange(
        state: SignalingState.fromWebRtc(state: stateChanged))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceConnectionStateChange(
        state: IceConnectionState.fromWebRtc(state: newState))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onConnectionStateChange(
        state: PeerConnectionState.fromWebRtc(state: newState))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceGatheringStateChange(
        state: IceGatheringState.fromWebRtc(state: newState))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate
  ) {
    DispatchQueue.main.async {
      self.peer!.broadcastEventObserver().onIceCandidate(
        candidate: IceCandidate(candidate: candidate))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]
  ) {

  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver
  ) {
    DispatchQueue.main.async {
      let track = transceiver.receiver.track!
      self.peer!.broadcastEventObserver().onTrack(
        track: MediaStreamTrackProxy(track: track, deviceId: nil, source: nil),
        transceiver: RtpTransceiverProxy(transceiver: transceiver))
    }
  }

  public func peerConnection(
    _ peerConnection: RTCPeerConnection, didAdd receiver: RTCRtpReceiver,
    streams mediaStreams: [RTCMediaStream]
  ) {
  }

  public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
  }

  public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream)
  {
  }

  public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen stream: RTCDataChannel) {
  }

  public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
  }
}
