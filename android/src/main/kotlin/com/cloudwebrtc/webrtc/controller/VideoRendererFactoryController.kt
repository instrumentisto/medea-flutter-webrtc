package com.cloudwebrtc.webrtc.controller

import android.util.Log
import com.cloudwebrtc.webrtc.FlutterRtcVideoRenderer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

class VideoRendererFactoryController(private val binaryMessenger: BinaryMessenger, private val textureRegistry: TextureRegistry) :
    MethodChannel.MethodCallHandler {
    private val methodChannel =
        MethodChannel(binaryMessenger, ChannelNameGenerator.withoutId("VideoRendererFactory"))

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                val renderer = FlutterRtcVideoRenderer(textureRegistry)
                result.success(VideoRendererController(binaryMessenger, renderer).asFlutterResult())
            }
        }
    }
}
