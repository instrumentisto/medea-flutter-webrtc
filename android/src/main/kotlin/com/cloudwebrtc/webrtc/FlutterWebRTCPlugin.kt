package com.cloudwebrtc.webrtc

import com.cloudwebrtc.webrtc.controller.MediaDevicesController
import com.cloudwebrtc.webrtc.controller.OutputAudioDevicesController
import com.cloudwebrtc.webrtc.controller.PeerConnectionFactoryController
import com.cloudwebrtc.webrtc.controller.VideoRendererFactoryController
import io.flutter.embedding.engine.plugins.FlutterPlugin

class FlutterWebRTCPlugin : FlutterPlugin {
    private var peerConnectionFactory: PeerConnectionFactoryController? = null
    private var mediaDevices: MediaDevicesController? = null
    private var videoRendererFactory: VideoRendererFactoryController? = null
    private var outputAudioDevices: OutputAudioDevicesController? = null

    override fun onAttachedToEngine(registar: FlutterPlugin.FlutterPluginBinding) {
        val messenger = registar.binaryMessenger
        val state = State(registar.applicationContext)
        mediaDevices = MediaDevicesController(messenger, state)
        peerConnectionFactory =
            PeerConnectionFactoryController(messenger, state)
        videoRendererFactory =
            VideoRendererFactoryController(messenger, registar.textureRegistry)
        outputAudioDevices = OutputAudioDevicesController(messenger, state)
    }

    override fun onDetachedFromEngine(registrar: FlutterPlugin.FlutterPluginBinding) {}
}