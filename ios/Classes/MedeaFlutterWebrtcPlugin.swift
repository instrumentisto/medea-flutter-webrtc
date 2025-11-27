import AVFoundation
import Flutter
import UIKit
import WebRTC

/// Representation of a `medea_flutter_webrtc` plugin.
public class MedeaFlutterWebrtcPlugin: NSObject, FlutterPlugin {
  var messenger: FlutterBinaryMessenger
  var peerConnectionFactory: PeerConnectionFactoryController
  var mediaDevices: MediaDevicesController
  var videoRendererFactory: VideoRendererFactoryController
  var textures: FlutterTextureRegistry
  var state: State

  // ✅ keep the real MediaDevices instance
  private let mediaDevicesImpl: MediaDevices

  init(messenger: FlutterBinaryMessenger, textures: FlutterTextureRegistry) {
    self.state = State()
    self.messenger = messenger
    self.textures = textures

    self.peerConnectionFactory = PeerConnectionFactoryController(
      messenger: messenger, state: state
    )

    // ✅ create MediaDevices once, store it, and pass to controller
    self.mediaDevicesImpl = MediaDevices(state: state)
    self.mediaDevices = MediaDevicesController(
      messenger: messenger, mediaDevices: self.mediaDevicesImpl
    )

    self.videoRendererFactory = VideoRendererFactoryController(
      messenger: messenger, registry: textures
    )
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "medea_flutter_webrtc",
      binaryMessenger: registrar.messenger()
    )
    let instance = MedeaFlutterWebrtcPlugin(
      messenger: registrar.messenger(),
      textures: registrar.textures()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setIdleAudioSession":
      DispatchQueue.main.async {
        self.mediaDevicesImpl.setIdleAudioSession()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

}

