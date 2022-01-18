package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpReceiver

class RtpReceiverProxy(receiver: RtpReceiver) : IWebRTCProxy<RtpReceiver> {
    override var obj: RtpReceiver = receiver;
    private var track: MediaStreamTrackProxy? = null;

    init {
        syncWithObject();
    }

    override fun syncWithObject() {
        syncMediaStreamTrack();
    }

    private fun syncMediaStreamTrack() {
        val newReceiverTrack = obj.track();
        if (newReceiverTrack == null) {
            track = null;
        } else {
            if (track == null) {
                track = MediaStreamTrackProxy(newReceiverTrack);
            } else {
                track!!.updateObject(newReceiverTrack);
            }
        }
    }
}