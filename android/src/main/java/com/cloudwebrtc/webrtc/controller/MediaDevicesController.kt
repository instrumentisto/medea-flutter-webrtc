package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.*
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
                val audioConstraintsArg = constraintsArg["audio"] as? Map<*, *>?
                var audioConstraints: AudioConstraints? = null
                if (audioConstraintsArg != null) {
                    val mandatoryArg =
                        audioConstraintsArg["mandatory"] as Map<*, *>? ?: mapOf<String, String>()
                    val optionalArg =
                        audioConstraintsArg["optional"] as Map<*, *>? ?: mapOf<String, String>()
                    val mandatory =
                        mandatoryArg.entries.associate { it.key as String to it.value as String }
                    val optional =
                        optionalArg.entries.associate { it.key as String to it.value as String }
                    audioConstraints = AudioConstraints(mandatory, optional)
                }

                val videoConstraintsArg = constraintsArg["video"] as Map<*, *>?
                var videoConstraints: VideoConstraints? = null
                if (videoConstraintsArg != null) {
                    val constraintCheckers = mutableListOf<ConstraintChecker>()

                    val mandatoryArg =
                        videoConstraintsArg["mandatory"] as Map<*, *>?
                    for ((key, value) in mandatoryArg ?: mapOf<Any, Any>()) {
                        when (key as String) {
                            "deviceId" -> {
                                constraintCheckers.add(DeviceIdConstraint(value as String, true))
                            }
                            "facingMode" -> {
                                constraintCheckers.add(
                                    FacingModeConstraint(
                                        FacingMode.fromInt(value as Int),
                                        true
                                    )
                                )
                            }
                        }
                    }

                    val optionalArg = videoConstraintsArg["optional"] as Map<*, *>?
                    for ((key, value) in optionalArg ?: mapOf<Any, Any>()) {
                        when (key as String) {
                            "deviceId" -> {
                                constraintCheckers.add(DeviceIdConstraint(value as String, false))
                            }
                            "facingMode" -> {
                                constraintCheckers.add(
                                    FacingModeConstraint(
                                        FacingMode.fromInt(value as Int),
                                        false
                                    )
                                )
                            }
                        }
                    }
                    videoConstraints = VideoConstraints(constraintCheckers)
                }

                val constraints = Constraints(audioConstraints, videoConstraints)
                val tracks = mediaDevices.getUserMedia(constraints)

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