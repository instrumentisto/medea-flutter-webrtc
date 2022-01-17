package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.proxy.PeerConnectionProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PeerConnectionController(messenger: BinaryMessenger, val peer: PeerConnectionProxy) :
    MethodChannel.MethodCallHandler, IdentifiableController {
    private val channelId = nextChannelId()
    private val methodChannel: MethodChannel =
        MethodChannel(messenger, ChannelNameGenerator.withId("PeerConnection", channelId))

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    fun intoFlutterResult(): Map<String, Any> {
        return mapOf<String, Any>(
            "channelId" to channelId,
            "id" to peer.id
        )
    }

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}