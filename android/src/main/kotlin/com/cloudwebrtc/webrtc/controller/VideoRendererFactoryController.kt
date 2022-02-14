package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.FlutterRtcVideoRenderer
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

/**
 * Controller for creating new [FlutterRtcVideoRenderer]s.
 *
 * @property binaryMessenger messenger used for creating new [MethodChannel]s.
 * @property textureRegistry registry with which new textures will be created.
 */
class VideoRendererFactoryController(
    private val binaryMessenger: BinaryMessenger,
    private val textureRegistry: TextureRegistry
) :
    MethodChannel.MethodCallHandler {
    /**
     * Channel which will be listened for the [MethodCall]s.
     */
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
