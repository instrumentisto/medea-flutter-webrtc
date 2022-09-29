import Flutter
import UIKit
import AVFoundation
import WebRTC

public class SwiftMedeaFlutterWebrtcPlugin: NSObject, FlutterPlugin {
  var messenger: FlutterBinaryMessenger;
  var peerConnectionFactory: PeerConnectionFactoryController
  var mediaDevices: MediaDevicesController
  var videoRendererFactory: VideoRendererFactoryController
  var textures: FlutterTextureRegistry
  var state: State

  init(messenger: FlutterBinaryMessenger, textures: FlutterTextureRegistry) {
    // RTCSetMinDebugLogLevel(RTCLoggingSeverity.verbose);
    NSLog("Hello world")
    self.state = State()
    self.messenger = messenger
    self.textures = textures
    self.peerConnectionFactory = PeerConnectionFactoryController(messenger: self.messenger, state: self.state)
    self.mediaDevices = MediaDevicesController(messenger: self.messenger, mediaDevices: MediaDevices(state: self.state))
    self.videoRendererFactory = VideoRendererFactoryController(messenger: self.messenger, registry: self.textures)
    NSLog("Plugin init 1")
    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { granted in
        if (granted) {
            NSLog("Permission granted")
        }
    })
    NSLog("Plugin init 2")
    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
        if (granted) {
            NSLog("Permission granted")
        }
    })
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "medea_flutter_webrtc", binaryMessenger: registrar.messenger())
    let instance = SwiftMedeaFlutterWebrtcPlugin(messenger: registrar.messenger(), textures: registrar.textures())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
