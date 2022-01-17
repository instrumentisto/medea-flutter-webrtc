package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.proxy.RtpSenderProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RtpSenderController(messenger: BinaryMessenger, val sender: RtpSenderProxy) : MethodChannel.MethodCallHandler, IdentifiableController{
    private val channelId = nextChannelId()
    private val methodChannel = MethodChannel(messenger, ChannelNameGenerator.withId("RtpSender", channelId))

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
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