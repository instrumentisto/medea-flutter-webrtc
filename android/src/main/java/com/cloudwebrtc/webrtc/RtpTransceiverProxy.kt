package com.cloudwebrtc.webrtc

import org.webrtc.RtpTransceiver

class RtpTransceiverProxy(override var obj: RtpTransceiver) : IWebRTCProxy<RtpTransceiver> {
    private lateinit var sender: RtpSenderProxy;
    private lateinit var receiver: RtpReceiverProxy;

    init {
        syncWithObject()
    }

    override fun syncWithObject() {
        syncSender()
        syncReceiver()
    }

    override fun dispose() {
        TODO("Not yet implemented")
    }

    fun getSender() : RtpSenderProxy {
        return sender
    }

    fun getReceiver(): RtpReceiverProxy {
        return receiver
    }

    fun setDirection(direction : RtpTransceiverDirection) {
        obj.direction = direction.intoWebRtc()
    }

    fun getMid() : String? {
        return obj.mid
    }

    fun getDirection() : RtpTransceiverDirection {
        return RtpTransceiverDirection.fromWebRtc(obj.direction)
    }

    fun getCurrentDirection() : RtpTransceiverDirection? {
        val direction = obj.currentDirection
        return if (direction == null) {
            null
        } else {
            RtpTransceiverDirection.fromWebRtc(direction)
        }
    }

    fun stop() {
        obj.stop();
    }

    private fun syncSender() {
        val newSender = obj.sender;
        if (this::sender.isInitialized) {
            sender.updateObject(newSender)
        } else {
            sender = RtpSenderProxy(newSender)
        }
    }

    private fun syncReceiver() {
        val newReceiver = obj.receiver
        if (this::receiver.isInitialized) {
            receiver.updateObject(newReceiver)
        } else {
            receiver = RtpReceiverProxy(newReceiver)
        }
    }
}