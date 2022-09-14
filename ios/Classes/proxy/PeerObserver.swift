import WebRTC

public class PeerObserver : NSObject, RTCPeerConnectionDelegate {
    var peer: PeerConnectionProxy?

    override init() {}

    public func setPeer(peer: PeerConnectionProxy) {
        self.peer = peer
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        self.peer!.broadcastEventObserver().onSignalingStateChange(state: SignalingState.fromWebRtc(state: stateChanged))
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        self.peer!.broadcastEventObserver().onIceConnectionStateChange(state: IceConnectionState.fromWebRtc(state: newState))
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState) {
        self.peer!.broadcastEventObserver().onConnectionStateChange(state: PeerConnectionState.fromWebRtc(state: newState))
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        self.peer!.broadcastEventObserver().onIceGatheringStateChange(state: IceGatheringState.fromWebRtc(state: newState))
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.peer!.broadcastEventObserver().onIceCandidate(candidate: IceCandidate(candidate: candidate))
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        // let videoTracks = stream.videoTracks
        // let audioTracks = stream.audioTracks
        // videoTracks.forEach {
        //     self.peer.broadcastEventObserver().onTrack($0, $0.transceiver)
        // }
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
    }

    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen stream: RTCDataChannel) {
    }

    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
    }
}