package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.IceConnectionState
import com.cloudwebrtc.webrtc.model.IceGatheringState
import com.cloudwebrtc.webrtc.model.SignalingState
import org.webrtc.DataChannel
import org.webrtc.MediaStream
import org.webrtc.PeerConnection
import org.webrtc.RtpReceiver
import org.webrtc.IceCandidate as WIceCandidate

/**
 * Implementor of the [PeerConnection.Observer] which notifies [PeerConnectionProxy] about
 * [PeerConnection] events.
 *
 */
class PeerObserver : PeerConnection.Observer {
    /**
     * [PeerConnectionProxy] which will be notified about all events.
     */
    private var peer: PeerConnectionProxy? = null

    override fun onSignalingChange(signallingState: PeerConnection.SignalingState?) {
        if (signallingState != null) {
            peer?.observableEventBroadcaster()
                ?.onSignalingStateChange(
                    SignalingState.fromWebRtc(
                        signallingState
                    )
                )

        }
    }

    override fun onIceConnectionChange(iceConnectionState: PeerConnection.IceConnectionState?) {
        if (iceConnectionState != null) {
            peer?.observableEventBroadcaster()
                ?.onIceConnectionStateChange(
                    IceConnectionState.fromWebRtc(
                        iceConnectionState
                    )
                )
        }
    }

    override fun onIceGatheringChange(iceGatheringState: PeerConnection.IceGatheringState?) {
        if (iceGatheringState != null) {
            peer?.observableEventBroadcaster()
                ?.onIceGatheringStateChange(
                    IceGatheringState.fromWebRtc(
                        iceGatheringState
                    )
                )
        }
    }

    override fun onIceCandidate(candidate: WIceCandidate?) {
        if (candidate != null) {
            peer?.observableEventBroadcaster()
                ?.onIceCandidate(IceCandidate.fromWebRtc(candidate))
        }
    }

    // TODO(#34): we should prefer onTrack
    override fun onAddTrack(
        receiver: RtpReceiver?,
        mediaStreams: Array<out MediaStream>?
    ) {
        if (receiver != null) {
            val track = receiver.track()
            if (track != null) {
                val transceivers = peer?.getTransceivers()!!
                for (trans in transceivers) {
                    if (trans.getReceiver().id() == receiver.id()) {
                        peer?.observableEventBroadcaster()
                            ?.onTrack(MediaStreamTrackProxy(track), trans)
                    }
                }
            }
        }
        super.onAddTrack(receiver, mediaStreams)
    }

    override fun onRenegotiationNeeded() {
        peer?.observableEventBroadcaster()?.onNegotiationNeeded()
    }

    override fun onIceConnectionReceivingChange(receiving: Boolean) {}
    override fun onIceCandidatesRemoved(candidates: Array<out WIceCandidate>?) {}
    override fun onAddStream(stream: MediaStream?) {}
    override fun onRemoveStream(stream: MediaStream?) {}
    override fun onDataChannel(chan: DataChannel?) {}

    /**
     * Sets [PeerConnectionProxy] which will be notified about all events.
     */
    fun setPeerConnection(newPeer: PeerConnectionProxy) {
        peer = newPeer
    }
}