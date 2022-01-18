package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.IceConnectionState
import com.cloudwebrtc.webrtc.model.IceGatheringState
import com.cloudwebrtc.webrtc.model.SignalingState
import org.webrtc.DataChannel
import org.webrtc.MediaStream
import org.webrtc.PeerConnection
import org.webrtc.IceCandidate as WIceCandidate

class PeerObserver : PeerConnection.Observer {
    private var peer: PeerConnectionProxy? = null;

    override fun onSignalingChange(signallingState: PeerConnection.SignalingState?) {
        if (signallingState != null) {
            peer?.observableEventBroadcaster()
                ?.onSignalingStateChange(SignalingState.fromWebRtc(signallingState))

        }
    }

    override fun onIceConnectionChange(iceConnectionState: PeerConnection.IceConnectionState?) {
        if (iceConnectionState != null) {
            peer?.observableEventBroadcaster()
                ?.onIceConnectionStateChange(IceConnectionState.fromWebRtc(iceConnectionState))
        }
    }

    override fun onIceGatheringChange(iceGatheringState: PeerConnection.IceGatheringState?) {
        if (iceGatheringState != null) {
            peer?.observableEventBroadcaster()
                ?.onIceGatheringStateChange(IceGatheringState.fromWebRtc(iceGatheringState))
        }
    }

    override fun onIceCandidate(candidate: WIceCandidate?) {
        if (candidate != null) {
            peer?.observableEventBroadcaster()?.onIceCandidate(IceCandidate.fromWebRtc(candidate))
        }
    }

    override fun onIceConnectionReceivingChange(p0: Boolean) {}
    override fun onIceCandidatesRemoved(candidates: Array<out WIceCandidate>?) {}
    override fun onAddStream(p0: MediaStream?) {}
    override fun onRemoveStream(p0: MediaStream?) {}
    override fun onDataChannel(p0: DataChannel?) {}
    override fun onRenegotiationNeeded() {}

    fun setPeerConnection(newPeer: PeerConnectionProxy) {
        peer = newPeer;
    }
}