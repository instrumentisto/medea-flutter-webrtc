package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.Constraints
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MediaDevicesController(private val binaryMessenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler {
    private val mediaDevices = MediaDevices(state)
    private val methodChannel =
        MethodChannel(binaryMessenger, ChannelNameGenerator.withoutId("MediaDevices"))

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enumerateDevices" -> {
                result.success(mediaDevices.enumerateDevices().map { it.intoMap() })
            }
            "getUserMedia" -> {
                val constraintsArg: Map<String, Any> = call.argument("constraints")!!
                val tracks = mediaDevices.getUserMedia(Constraints.fromMap(constraintsArg))

                result.success(tracks.map {
                    MediaStreamTrackController(
                        binaryMessenger,
                        it
                    ).asFlutterResult()
                })
            }
        }
    }
}