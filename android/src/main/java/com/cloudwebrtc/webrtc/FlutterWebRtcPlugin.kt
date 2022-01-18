package com.cloudwebrtc.webrtc

import android.util.Log
import com.cloudwebrtc.webrtc.controller.MediaDevicesController
import com.cloudwebrtc.webrtc.controller.PeerConnectionFactoryController
import io.flutter.embedding.engine.plugins.FlutterPlugin

class FlutterWebRtcPlugin : FlutterPlugin {
    private var peerConnectionFactory: PeerConnectionFactoryController? = null
    private var mediaDevices: MediaDevicesController? = null

    override fun onAttachedToEngine(registar: FlutterPlugin.FlutterPluginBinding) {
        Log.d("FlutterWEBRTC", "Kotlin plugin was attached")
        peerConnectionFactory = PeerConnectionFactoryController(registar.binaryMessenger, State(registar.applicationContext))
        mediaDevices = MediaDevicesController(registar.binaryMessenger, State(registar.applicationContext))
    }

    override fun onDetachedFromEngine(registrar: FlutterPlugin.FlutterPluginBinding) {
        // TODO: Implement disposing mechanism on application close
    }
}