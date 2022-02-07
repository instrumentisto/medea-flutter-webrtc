package com.cloudwebrtc.webrtc.controller

import android.util.Log
import com.cloudwebrtc.webrtc.model.*
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.proxy.PeerConnectionProxy
import com.cloudwebrtc.webrtc.proxy.RtpTransceiverProxy
import com.cloudwebrtc.webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking

/**
 * Controller for the [PeerConnectionProxy] functional.
 */
class PeerConnectionController(
    private val messenger: BinaryMessenger,
    private val peer: PeerConnectionProxy
) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler, IdentifiableController {
    private val channelId = nextChannelId()
    private val methodChannel: MethodChannel =
        MethodChannel(messenger, ChannelNameGenerator.withId("PeerConnection", channelId))
    private val eventChannel: EventChannel =
        EventChannel(messenger, ChannelNameGenerator.withId("PeerConnectionEvent", channelId))
    private var eventSink: AnyThreadSink? = null
    private val eventObserver = object : PeerConnectionProxy.Companion.EventObserver {
        override fun onAddTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
            eventSink?.success(
                mapOf(
                    "event" to "onAddTrack",
                    "track" to MediaStreamTrackController(messenger, track).asFlutterResult(),
                    "transceiver" to RtpTransceiverController(
                        messenger,
                        transceiver
                    ).asFlutterResult()
                )
            )
        }

        override fun onIceConnectionStateChange(iceConnectionState: IceConnectionState) {
            eventSink?.success(
                mapOf(
                    "event" to "onIceConnectionStateChange",
                    "state" to iceConnectionState.value
                )
            )
        }

        override fun onSignalingStateChange(signalingState: SignalingState) {
            eventSink?.success(
                mapOf(
                    "event" to "onSignalingStateChange",
                    "state" to signalingState.value
                )
            )
        }

        override fun onConnectionStateChange(peerConnectionState: PeerConnectionState) {
            eventSink?.success(
                mapOf(
                    "event" to "onConnectionStateChange",
                    "state" to peerConnectionState.value
                )
            )
        }

        override fun onIceGatheringStateChange(iceGatheringState: IceGatheringState) {
            eventSink?.success(
                mapOf(
                    "event" to "onIceGatheringStateChange",
                    "state" to iceGatheringState.value
                )
            )
        }

        override fun onIceCandidate(candidate: IceCandidate) {
            eventSink?.success(
                mapOf(
                    "event" to "onIceCandidate",
                    "candidate" to candidate.intoMap()
                )
            )
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        peer.addEventObserver(eventObserver)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLocalDescription" -> {
                result.success(peer.getLocalDescription().intoMap())
            }
            "getRemoteDescription" -> {
                result.success(peer.getRemoteDescription()?.intoMap())
            }
            "createOffer" -> {
                runBlocking {
                    result.success(peer.createOffer().intoMap())
                }
            }
            "createAnswer" -> {
                runBlocking {
                    result.success(peer.createAnswer().intoMap())
                }
            }
            "setLocalDescription" -> {
                val descriptionArg: Map<String, Any>? = call.argument("description")
                val description = if (descriptionArg == null) {
                    null
                } else {
                    SessionDescription.fromMap(descriptionArg)
                }
                runBlocking {
                    peer.setLocalDescription(description)
                }
                result.success(null)
            }
            "setRemoteDescription" -> {
                val descriptionArg: Map<String, Any> = call.argument("description")!!
                runBlocking {
                    peer.setRemoteDescription(SessionDescription.fromMap(descriptionArg))
                }
                result.success(null)
            }
            "addIceCandidate" -> {
                val candidate: Map<String, Any> = call.argument("candidate")!!
                runBlocking {
                    peer.addIceCandidate(IceCandidate.fromMap(candidate))
                }
                result.success(null)
            }
            "addTransceiver" -> {
                val mediaType = MediaType.fromInt(call.argument("mediaType")!!)
                val transceiverInitArg: Map<String, Any>? = call.argument("init")
                val transceiver = if (transceiverInitArg == null) {
                    peer.addTransceiver(mediaType, null)
                } else {
                    peer.addTransceiver(mediaType, RtpTransceiverInit.fromMap(transceiverInitArg))
                }
                val transceiverController = RtpTransceiverController(messenger, transceiver)
                result.success(transceiverController.asFlutterResult())
            }
            "getSenders" -> {
                result.success(
                    peer.getSenders().map { RtpSenderController(messenger, it).asFlutterResult() })
            }
            "getTransceivers" -> {
                result.success(
                    peer.getTransceivers()
                        .map { RtpTransceiverController(messenger, it).asFlutterResult() })
            }
            "restartIce" -> {
                peer.restartIce()
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    override fun onListen(obj: Any?, sink: EventChannel.EventSink?) {
        if (sink != null) {
            eventSink = AnyThreadSink(sink)
        }
    }

    override fun onCancel(obj: Any?) {
        eventSink = null
    }

    /**
     * Converts this [PeerConnectionController] to the Flutter's method call result.
     *
     * @return [Map] generated from this controller which can be returned to the Flutter side.
     */
    fun asFlutterResult(): Map<String, Any> = mapOf<String, Any>(
        "channelId" to channelId,
        "id" to peer.id
    )

    /**
     * Closes method and event channels of this [PeerConnectionController].
     *
     * Disposes underlying [PeerConnectionProxy].
     */
    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
        peer.removeEventObserver(eventObserver)
        peer.dispose()
        eventChannel.setStreamHandler(null)
        eventSink?.endOfStream()
    }
}
