package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpSender

class RtpSenderProxy(sender: RtpSender) : IWebRTCProxy<RtpSender> {
    override var obj: RtpSender = sender;
    private var track: MediaStreamTrackProxy? = null;

    init {
        syncWithObject();
    }

    override fun syncWithObject() {
        syncMediaStreamTrack();
    }

    fun setTrack(t: MediaStreamTrackProxy?) {
        track = t;
        obj.setTrack(t?.obj, false);
    }

    private fun syncMediaStreamTrack() {
        val newSenderTrack = obj.track();
        if (newSenderTrack == null) {
            track = null;
        } else {
            if (track == null) {
                track = MediaStreamTrackProxy(newSenderTrack);
            } else {
                track!!.updateObject(newSenderTrack);
            }
        }
    }
}