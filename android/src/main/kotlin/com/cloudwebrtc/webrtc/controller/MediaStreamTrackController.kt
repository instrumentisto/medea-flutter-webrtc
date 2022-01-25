package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MediaStreamTrackController(
    private val binaryMessenger: BinaryMessenger,
    private val track: MediaStreamTrackProxy
) : MethodChannel.MethodCallHandler, IdentifiableController {
    private val channelId: Int = nextChannelId();
    private val methodChannel: MethodChannel = MethodChannel(
        binaryMessenger,
        ChannelNameGenerator.withId("MediaStreamTrack", channelId)
    )

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
            "clone" -> {
                result.success(
                    MediaStreamTrackController(
                        binaryMessenger,
                        track.clone()
                    ).asFlutterResult()
                )
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    fun asFlutterResult(): Map<String, Any> = mapOf(
        "channelId" to channelId,
        "id" to track.id(),
        "kind" to track.kind().value,
        "deviceId" to track.deviceId()
    )

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}