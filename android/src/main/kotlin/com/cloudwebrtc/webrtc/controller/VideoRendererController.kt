package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.FlutterRtcVideoRenderer
import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.proxy.VideoTrackProxy
import com.cloudwebrtc.webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VideoRendererController(
    val binaryMessenger: BinaryMessenger,
    private val videoRenderer: FlutterRtcVideoRenderer
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, IdentifiableController {
    private val channelId: Int = nextChannelId();
    private val methodChannel: MethodChannel = MethodChannel(
        binaryMessenger,
        ChannelNameGenerator.withId("VideoRenderer", channelId)
    )
    private val eventChannel: EventChannel =
        EventChannel(binaryMessenger, ChannelNameGenerator.withId("VideoRendererEvent", channelId))
    private var eventSink: AnyThreadSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)

        videoRenderer.setEventListener(object : FlutterRtcVideoRenderer.Companion.EventListener {
            override fun onFirstFrameRendered(id: Long) {
                eventSink?.success(
                    mapOf(
                        "event" to "onFirstFrameRendered",
                        "id" to id
                    )
                )
            }

            override fun onTextureChangeVideoSize(id: Long, height: Int, width: Int) {
                eventSink?.success(
                    mapOf(
                        "event" to "onTextureChangeVideoSize",
                        "id" to id,
                        "width" to width,
                        "height" to height
                    )
                )
            }

            override fun onTextureChangeRotation(id: Long, rotation: Int) {
                eventSink?.success(
                    mapOf(
                        "event" to "onTextureChangeRotation",
                        "id" to id,
                        "rotation" to rotation
                    )
                )
            }

        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setSrcObject" -> {
                val trackId: String = call.argument("trackId")!!

                val track = TrackRepository.getTrack(trackId)!!
                val videoTrack = VideoTrackProxy(track)
                videoRenderer.setVideoTrack(videoTrack)

                result.success(null)
            }
        }
    }

    fun asFlutterResult(): Map<String, Any> = mapOf(
        "channelId" to channelId
    )

    override fun onListen(obj: Any?, sink: EventChannel.EventSink?) {
        eventSink = AnyThreadSink(sink)
    }

    override fun onCancel(obj: Any?) {
        eventSink = null
    }
}