package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpReceiver
import org.webrtc.RtpSender

/**
 * Wrapper around [RtpSender].
 *
 * @param sender actual underlying [RtpSender].
 */
class RtpSenderProxy(sender: RtpSender) : IWebRTCProxy<RtpSender> {
    /**
     * Actual underlying [RtpReceiver].
     */
    override var obj: RtpSender = sender;

    /**
     * [MediaStreamTrackProxy] of this [RtpReceiverProxy].
     */
    private var track: MediaStreamTrackProxy? = null;

    init {
        syncWithObject();
    }

    override fun syncWithObject() {
        syncMediaStreamTrack();
    }

    /**
     * Sets [MediaStreamTrackProxy] of the underlying [RtpSender] to the provided one.
     *
     * @param t [MediaStreamTrackProxy] which will be set to the underlying [RtpSender].
     */
    fun setTrack(t: MediaStreamTrackProxy?) {
        track = t;
        obj.setTrack(t?.obj, false);
    }

    /**
     * Synchronizes [MediaStreamTrackProxy] of this [RtpSenderProxy] with
     * a underlying [RtpSender].
     */
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