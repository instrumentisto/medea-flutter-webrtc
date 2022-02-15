package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.exception.OverconstrainedException
import com.cloudwebrtc.webrtc.model.Constraints
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller for [MediaDevices] functional.
 *
 * @property binaryMessenger messenger used for creating new [MethodChannel]s.
 * @param state will be used for creating new [MediaStreamTrackProxy]s.
 */
class MediaDevicesController(private val binaryMessenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler {
    /**
     * Underlying [MediaDevices] on which method calls will be performed.
     */
    private val mediaDevices = MediaDevices(state)

    /**
     * Channel which will be listened for the [MethodCall]s.
     */
    private val methodChannel =
        MethodChannel(binaryMessenger, ChannelNameGenerator.name("MediaDevices", 0))

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
                try {
                    val tracks = mediaDevices.getUserMedia(Constraints.fromMap(constraintsArg))
                    result.success(tracks.map {
                        MediaStreamTrackController(
                                binaryMessenger,
                                it
                        ).asFlutterResult()
                    })
                } catch (e: OverconstrainedException) {
                    result.error("OverconstrainedError", null, null)
                }
            }
        }
    }
}