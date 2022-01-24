package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.proxy.RtpSenderProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RtpSenderController(messenger: BinaryMessenger, val sender: RtpSenderProxy) :
    MethodChannel.MethodCallHandler, IdentifiableController {
    private val channelId = nextChannelId()
    private val methodChannel =
        MethodChannel(messenger, ChannelNameGenerator.withId("RtpSender", channelId))

    init {
        methodChannel.setMethodCallHandler(this);
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setTrack" -> {
                val trackId: String = call.argument("trackId")!!
                val track = TrackRepository.getTrack(trackId)!!
                sender.setTrack(track)
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    fun asFlutterResult(): Map<String, Any> = mapOf("channelId" to channelId)

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}