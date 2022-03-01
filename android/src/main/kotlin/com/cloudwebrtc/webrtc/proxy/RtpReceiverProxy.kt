package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpReceiver

/**
 * Wrapper around an [RtpReceiver].
 *
 * @param receiver  Underlying [RtpReceiver].
 */
class RtpReceiverProxy(receiver: RtpReceiver) : Proxy<RtpReceiver> {
    /**
     * Actual underlying [RtpReceiver].
     */
    override var obj: RtpReceiver = receiver

    /**
     * [MediaStreamTrackProxy] of this [RtpReceiverProxy].
     */
    private var track: MediaStreamTrackProxy? = null

    init {
        syncWithObject()
    }

    override fun syncWithObject() {
        syncMediaStreamTrack()
    }

    /**
     * @return  Unique ID of the underlying [RtpReceiver].
     */
    fun id(): String {
        return obj.id()
    }

    /**
     * Notifies [RtpReceiverProxy], that it's [MediaStreamTrackProxy] is ended.
     */
    fun ended() {
        track?.observableEventBroadcaster()?.onEnded()
    }

    /**
     * Synchronizes the [MediaStreamTrackProxy] of this [RtpReceiverProxy] with
     * the underlying [RtpReceiver].
     */
    private fun syncMediaStreamTrack() {
        val newReceiverTrack = obj.track()
        if (newReceiverTrack == null) {
            track = null
        } else {
            if (track == null) {
                track = MediaStreamTrackProxy(newReceiverTrack)
            } else {
                track!!.replace(newReceiverTrack)
            }
        }
    }
}
