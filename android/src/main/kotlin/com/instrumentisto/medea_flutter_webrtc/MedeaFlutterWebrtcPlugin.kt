package com.instrumentisto.medea_flutter_webrtc

import com.instrumentisto.medea_flutter_webrtc.controller.MediaDevicesController
import com.instrumentisto.medea_flutter_webrtc.controller.PeerConnectionFactoryController
import com.instrumentisto.medea_flutter_webrtc.controller.VideoRendererFactoryController
import io.flutter.embedding.engine.plugins.FlutterPlugin

class MedeaFlutterWebrtcPlugin : FlutterPlugin {
  private var peerConnectionFactory: PeerConnectionFactoryController? = null
  private var mediaDevices: MediaDevicesController? = null
  private var videoRendererFactory: VideoRendererFactoryController? = null

  override fun onAttachedToEngine(registar: FlutterPlugin.FlutterPluginBinding) {
    val messenger = registar.binaryMessenger
    val state = State(registar.applicationContext)
    mediaDevices = MediaDevicesController(messenger, state)
    peerConnectionFactory = PeerConnectionFactoryController(messenger, state)
    videoRendererFactory = VideoRendererFactoryController(messenger, registar.textureRegistry)
  }

  override fun onDetachedFromEngine(registrar: FlutterPlugin.FlutterPluginBinding) {}
}
