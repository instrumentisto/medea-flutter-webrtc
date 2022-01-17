package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.MediaType
import com.cloudwebrtc.webrtc.model.RtpTransceiverInit
import com.cloudwebrtc.webrtc.model.SessionDescription
import com.cloudwebrtc.webrtc.proxy.PeerConnectionProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.runBlocking

class PeerConnectionController(messenger: BinaryMessenger, val peer: PeerConnectionProxy) :
    MethodChannel.MethodCallHandler, IdentifiableController {
    private val channelId = nextChannelId()
    private val methodChannel: MethodChannel =
        MethodChannel(messenger, ChannelNameGenerator.withId("PeerConnection", channelId))

    init {
        methodChannel.setMethodCallHandler(this)
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
                    peer.addTransceiver(mediaType)
                } else {
                    peer.addTransceiver(mediaType, RtpTransceiverInit.fromMap(transceiverInitArg))
                }
                TODO("Return RtpTransceiverController")
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
        }
    }

    fun intoFlutterResult(): Map<String, Any> {
        return mapOf<String, Any>(
            "channelId" to channelId,
            "id" to peer.id
        )
    }

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}