package com.cloudwebrtc.webrtc

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private object ChannelIdGenerator {
    private var lastId: Int = 0

    fun nextId(): Int {
        return lastId++
    }
}

class PeerConnectionController(messenger: BinaryMessenger, val peer: PeerConnectionProxy) : MethodChannel.MethodCallHandler {
    private val channelId = ChannelIdGenerator.nextId()
    private val methodChannel: MethodChannel = MethodChannel(messenger, "com.instrumentisto.flutter_webrtc/PeerConnection/$channelId")

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        TODO()
    }

    fun channelId(): Int {
        return channelId
    }

    fun intoFlutterResult(): Map<String, Any> {
        return mapOf<String, Any>(
                "channelId" to channelId,
                "id" to peer.id
        )
    }
}