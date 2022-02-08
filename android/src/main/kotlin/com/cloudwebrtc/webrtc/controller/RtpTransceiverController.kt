package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.model.RtpTransceiverDirection
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.proxy.RtpTransceiverProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller for the [RtpTransceiverProxy] functional.
 *
 * @property binaryMessenger messenger used for creating new [MethodChannel]s.
 * @property transceiver underlying [RtpTransceiverProxy] on which method calls will be performed.
 */
class RtpTransceiverController(
    private val binaryMessenger: BinaryMessenger,
    private val transceiver: RtpTransceiverProxy
) : MethodChannel.MethodCallHandler, IdentifiableController {
    /**
     * Unique ID of the [MethodChannel] of this controller.
     */
    private val channelId = nextChannelId()

    /**
     * Channel which will be listened for the [MethodCall]s.
     */
    private val methodChannel =
        MethodChannel(binaryMessenger, ChannelNameGenerator.withId("RtpTransceiver", channelId))

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setDirection" -> {
                val direction = RtpTransceiverDirection.fromInt(call.argument("direction")!!)
                transceiver.setDirection(direction)
                result.success(null)
            }
            "getMid" -> {
                result.success(transceiver.getMid())
            }
            "getDirection" -> {
                result.success(transceiver.getDirection().value)
            }
            "getCurrentDirection" -> {
                result.success(transceiver.getCurrentDirection()?.value)
            }
            "getSender" -> {
                result.success(
                    RtpSenderController(
                        binaryMessenger,
                        transceiver.getSender()
                    ).asFlutterResult()
                )
            }
            "stop" -> {
                transceiver.stop()
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    /**
     * Converts this [RtpTransceiverController] to the Flutter's method call result.
     *
     * @return [Map] generated from this controller which can be returned to the Flutter side.
     */
    fun asFlutterResult(): Map<String, Any?> {
        return mapOf(
            "channelId" to channelId,
            "sender" to RtpSenderController(
                binaryMessenger,
                transceiver.getSender()
            ).asFlutterResult(),
            "mid" to transceiver.getMid() as Any?
        )
    }

    /**
     * Closes method channel of this [RtpTransceiverController].
     */
    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}