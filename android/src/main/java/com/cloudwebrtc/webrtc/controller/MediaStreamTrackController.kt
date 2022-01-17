package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object MediaStreamTrackChannelIdGenerator {
    private var lastId: Int = 0;

    fun nextId(): Int {
        return lastId++
    }
}

class MediaStreamTrackController(binaryMessenger: BinaryMessenger, val track: MediaStreamTrackProxy) : MethodChannel.MethodCallHandler {
    private val channelId: Int = MediaStreamTrackChannelIdGenerator.nextId();
    private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, "com.instrumentisto.flutter_webrtc/MediaStreamTrack/$channelId")

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEnabled" -> {
                val enabled: Boolean = call.argument("enabled")!!
                track.setEnabled(enabled)
                result.success(null)
            }
            "state" -> {
                val trackState = track.state()
                result.success(trackState.intoFlutterResult())
            }
            "stop" -> {
                track.stop()
                result.success(null)
            }
            "dispose" -> {
                track.dispose()
                result.success(null)
                methodChannel.setMethodCallHandler(null)
            }
        }
    }

    fun channelId(): Int {
        return channelId
    }
}