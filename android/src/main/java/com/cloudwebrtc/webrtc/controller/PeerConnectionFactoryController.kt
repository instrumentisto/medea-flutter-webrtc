package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.IceServer
import com.cloudwebrtc.webrtc.model.IceTransportType
import com.cloudwebrtc.webrtc.model.PeerConnectionConfiguration
import com.cloudwebrtc.webrtc.proxy.PeerConnectionFactoryProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PeerConnectionFactoryController(private val binaryMessenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler {
    private val factory: PeerConnectionFactoryProxy = PeerConnectionFactoryProxy(state)
    private val methodChannel =
        MethodChannel(binaryMessenger, ChannelNameGenerator.withoutId("PeerConnectionFactory"))

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                val iceTransportTypeArg: Int = call.argument("iceTransportType") ?: 0
                val iceTransportType = IceTransportType.fromInt(iceTransportTypeArg)

                val iceServersArg: List<Map<String, Any>> = call.argument("iceServers") ?: listOf()
                val iceServers: List<IceServer> = iceServersArg.map { serv ->
                    val urlsArg = serv["urls"] as? List<*>
                    val urls = urlsArg?.mapNotNull {
                        it as? String
                    }
                    val username = serv["username"] as? String
                    val password = serv["password"] as? String

                    IceServer(urls ?: listOf(), username, password)
                }

                val newPeer =
                    factory.create(PeerConnectionConfiguration(iceServers, iceTransportType))
                val peerController = PeerConnectionController(binaryMessenger, newPeer)
                result.success(peerController.intoFlutterResult())
            }
        }
    }

    private fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}