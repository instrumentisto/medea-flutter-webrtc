package com.cloudwebrtc.webrtc

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

    override fun dispose() {
        TODO("Not yet implemented")
    }

    fun setTrack(track: MediaStreamTrackProxy?) {
        obj.setTrack(track?.obj, false);
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