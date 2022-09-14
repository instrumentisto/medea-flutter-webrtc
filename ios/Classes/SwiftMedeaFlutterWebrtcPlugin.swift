import Flutter
import UIKit
import AVFoundation

public class SwiftMedeaFlutterWebrtcPlugin: NSObject, FlutterPlugin {
  var messenger: FlutterBinaryMessenger;
  var peerConnectionFactory: PeerConnectionFactoryController
  var mediaDevices: MediaDevicesController
  var state: State

  init(messenger: FlutterBinaryMessenger) {
    NSLog("Hello world")
    self.state = State()
    self.messenger = messenger
    self.peerConnectionFactory = PeerConnectionFactoryController(messenger: self.messenger, state: self.state)
    self.mediaDevices = MediaDevicesController(messenger: self.messenger, mediaDevices: MediaDevices(state: self.state))
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
    let instance = SwiftMedeaFlutterWebrtcPlugin(messenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
