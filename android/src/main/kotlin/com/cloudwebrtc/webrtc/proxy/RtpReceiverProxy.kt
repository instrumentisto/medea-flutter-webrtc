package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpReceiver

/**
 * Wrapper around [RtpReceiver]
 *
 * @param receiver underlying [RtpReceiver].
 */
class RtpReceiverProxy(receiver: RtpReceiver) : IWebRTCProxy<RtpReceiver> {
    /**
     * Actual underlying [RtpReceiver].
     */
    override var obj: RtpReceiver = receiver;

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
     * @return unique ID of the underlying [RtpReceiver].
     */
    fun id(): String {
        return obj.id()
    }

    /**
     * Synchronizes [MediaStreamTrackProxy] of this [RtpReceiverProxy] with
     * a underlying [RtpReceiver].
     */
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