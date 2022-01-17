package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.model.RtpTransceiverDirection
import com.cloudwebrtc.webrtc.proxy.RtpTransceiverProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RtpTransceiver(binaryMessenger: BinaryMessenger, private val transceiver: RtpTransceiverProxy) : MethodChannel.MethodCallHandler, IdentifiableController {
    private val channelId = nextChannelId()
    private val methodChannel = MethodChannel(binaryMessenger, ChannelNameGenerator.withId("RtpTransceiver", channelId))

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setDirection" -> {
                val direction = RtpTransceiverDirection.fromInt(call.argument("direction")!!)
                transceiver.setDirection(direction)
                result.success(null)
            }
            "getMid" -> {
                result.success(transceiver.getMid())
            }
            "getDirection" -> {
                result.success(transceiver.getDirection())
            }
            "getCurrentDirection" -> {
                result.success(transceiver.getCurrentDirection()?.value)
            }
            "getSender" -> {
                TODO("")
            }
            "stop" -> {
                transceiver.stop()
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}