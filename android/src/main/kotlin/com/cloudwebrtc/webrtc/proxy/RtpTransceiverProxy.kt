package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.model.RtpTransceiverDirection
import org.webrtc.RtpTransceiver

/**
 * Wrapper around [RtpTransceiver].
 */
class RtpTransceiverProxy(override var obj: RtpTransceiver) : IWebRTCProxy<RtpTransceiver> {
    /**
     * [RtpSenderProxy] of this [RtpTransceiverProxy].
     */
    private lateinit var sender: RtpSenderProxy

    /**
     * [RtpReceiverProxy] of this [RtpTransceiverProxy].
     */
    private lateinit var receiver: RtpReceiverProxy

    init {
        syncWithObject()
    }

    override fun syncWithObject() {
        syncSender()
        syncReceiver()
    }

    /**
     * @return [RtpSenderProxy] of this [RtpTransceiverProxy].
     */
    fun getSender(): RtpSenderProxy {
        return sender
    }

    /**
     * @return [RtpReceiverProxy] of this [RtpTransceiverProxy].
     */
    fun getReceiver(): RtpReceiverProxy {
        return receiver
    }

    /**
     * Sets [RtpTransceiverDirection] of the underlying [RtpTransceiver].
     */
    fun setDirection(direction: RtpTransceiverDirection) {
        obj.direction = direction.intoWebRtc()
    }

    /**
     * Returns mID of the underlying [RtpTransceiver].
     */
    fun getMid(): String? {
        return obj.mid
    }

    /**
     * @return preferred [RtpTransceiverDirection] of the underlying [RtpTransceiver].
     */
    fun getDirection(): RtpTransceiverDirection {
        return RtpTransceiverDirection.fromWebRtc(obj.direction)
    }

    /**
     * Stops underlying [RtpTransceiver].
     */
    fun stop() {
        obj.stop()
    }

    /**
     * Synchronizes [RtpSenderProxy] of this [RtpTransceiverProxy] with the
     * underlying [RtpTransceiver].
     */
    private fun syncSender() {
        val newSender = obj.sender
        if (this::sender.isInitialized) {
            sender.updateObject(newSender)
        } else {
            sender = RtpSenderProxy(newSender)
        }
    }

    /**
     * Synchronizes [RtpReceiverProxy] of this [RtpTransceiverProxy] with the
     * underlying [RtpTransceiver].
     */
    private fun syncReceiver() {
        val newReceiver = obj.receiver
        if (this::receiver.isInitialized) {
            receiver.updateObject(newReceiver)
        } else {
            receiver = RtpReceiverProxy(newReceiver)
        }
    }
}