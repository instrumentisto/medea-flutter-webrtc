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
  var logging: LoggingController
  var textures: FlutterTextureRegistry
  var state: State

  /// Initializes a new `MedeaFlutterWebrtcPlugin` with the provided
  /// parameters.
  init(messenger: FlutterBinaryMessenger, textures: FlutterTextureRegistry) {
    // Uncomment the underlying line for `libwebrtc` debug logs:
    // RTCSetMinDebugLogLevel(RTCLoggingSeverity.verbose)
    self.state = State()
    self.messenger = messenger
    self.textures = textures
    let mediaDevices = MediaDevices(state: self.state)
    self.peerConnectionFactory = PeerConnectionFactoryController(
      messenger: self.messenger, state: self.state, mediaDevices: mediaDevices
    )
    self.mediaDevices = MediaDevicesController(
      messenger: self.messenger, mediaDevices: mediaDevices
    )
    self.videoRendererFactory = VideoRendererFactoryController(
      messenger: self.messenger, registry: self.textures
    )
    self.logging = LoggingController(messenger: self.messenger)
  }

  /// Registers this `MedeaFlutterWebrtcPlugin` in the provided
  /// `FlutterPluginRegistrar`.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "medea_flutter_webrtc", binaryMessenger: registrar.messenger()
    )
    let instance = MedeaFlutterWebrtcPlugin(
      messenger: registrar.messenger(), textures: registrar.textures()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles the provided `FlutterMethodCall`.
  public func handle(_: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
