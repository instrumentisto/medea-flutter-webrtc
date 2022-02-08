package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller for the [MediaStreamTrackProxy] functional.
 *
 * @property binaryMessenger messenger used for creating new [MethodChannel]s.
 * @property track underlying [MediaStreamTrackProxy] on which method calls will be performed.
 */
class MediaStreamTrackController(
        private val binaryMessenger: BinaryMessenger,
        private val track: MediaStreamTrackProxy
) : MethodChannel.MethodCallHandler, IdentifiableController {
    /**
     * Unique ID of the [MethodChannel] of this controller.
     */
    private val channelId: Int = nextChannelId()

    /**
     * Channel which will be listened for the [MethodCall]s.
     */
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
                result.success(trackState.value)
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

    /**
     * Converts this [MediaStreamTrackController] to the Flutter's method call result.
     *
     * @return [Map] generated from this controller which can be returned to the Flutter side.
     */
    fun asFlutterResult(): Map<String, Any> = mapOf(
            "channelId" to channelId,
            "id" to track.id(),
            "kind" to track.kind().value,
            "deviceId" to track.deviceId()
    )

    /**
     * Closes method channel of this [MediaStreamTrackController].
     */
    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}