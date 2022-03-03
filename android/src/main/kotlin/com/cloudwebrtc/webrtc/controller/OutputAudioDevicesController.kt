package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.OutputAudioDevices
import com.cloudwebrtc.webrtc.State
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [OutputAudioDevices] functional.
 *
 * @property messenger  Messenger used for creating new [MethodChannel]s.
 *
 * @param state  Global state used for output audio devices management.
 */
class OutputAudioDevicesController(
    private val messenger: BinaryMessenger,
    state: State
) :
    MethodChannel.MethodCallHandler {
    /**
     * Underlying [MediaDevices] to perform [MethodCall]s on.
     */
    private val outputAudioDevices = OutputAudioDevices(state)

    /**
     * Channel listener for [MethodCall]s.
     */
    private val chan =
            MethodChannel(messenger, ChannelNameGenerator.name("OutputAudioDevices", 0))

    init {
        chan.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enumerateDevices" -> {
                result.success(
                    outputAudioDevices.enumerateDevices()
                        .map { it.asFlutterResult() }
                )
            }
            "setDevice" -> {
                val deviceId: String = call.argument("deviceId")!!
                outputAudioDevices.setDevice(deviceId)
                result.success(null)
            }
        }
    }
}
