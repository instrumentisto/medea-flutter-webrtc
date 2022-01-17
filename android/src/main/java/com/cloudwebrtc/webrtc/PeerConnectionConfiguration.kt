package com.cloudwebrtc.webrtc

import io.flutter.plugin.common.MethodCall
import org.webrtc.PeerConnection
import org.webrtc.PeerConnection.RTCConfiguration as WRTCConfiguration;
import org.webrtc.PeerConnection.IceServer as WIceServer;
import org.webrtc.PeerConnection.IceTransportsType as WIceTransportType;

enum class IceTransportType(val value: Int) {
    ALL(0),
    RELAY(1),
    NOHOST(2),
    NONE(3);

    companion object {
        fun fromInt(value: Int) = values().first { it.value == value }
    }

    fun intoWebRtc(): WIceTransportType {
        return when (this) {
            ALL -> WIceTransportType.ALL
            RELAY -> WIceTransportType.RELAY
            NOHOST -> WIceTransportType.NOHOST
            NONE -> WIceTransportType.NONE
        }
    }
}

data class IceServer(val urls: List<String>, val username: String?, val password: String?) {
    fun intoWebRtc(): WIceServer {
        val iceServerBuilder = WIceServer.builder(urls)
        if (username != null) {
            iceServerBuilder.setUsername(username)
        }
        if (password != null) {
            iceServerBuilder.setPassword(password)
        }
        return iceServerBuilder.createIceServer()
    }
}

data class PeerConnectionConfiguration(val iceServers: List<IceServer>, val iceTransportType: IceTransportType) {
    fun intoWebRtc(): WRTCConfiguration {
        val conf = WRTCConfiguration(iceServers.map { server -> server.intoWebRtc() }.toList())
        conf.iceTransportsType = iceTransportType.intoWebRtc()
        conf.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN

        return conf
    }
}
