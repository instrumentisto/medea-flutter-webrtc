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
    // Uncomment the underlying line for `libwebrtc` debug logs:
    // RTCSetMinDebugLogLevel(RTCLoggingSeverity.verbose)
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
  
  /// Registers this `MedeaFlutterWebrtcPlugin` in the provided
  /// `FlutterPluginRegistrar`.
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
    /// Handles the `setIdleAudioSession` Flutter method call.
    ///
    /// Resets `AVAudioSession` to a non-invasive idle configuration so other
    /// apps (e.g., Spotify/Apple Music) can resume playback after a call ends.
    /// Dispatched onto the main queue to keep AVAudioSession interactions
    /// consistent with typical iOS audio lifecycle expectations.
      DispatchQueue.main.async {
        self.mediaDevicesImpl.setIdleAudioSession()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

}

