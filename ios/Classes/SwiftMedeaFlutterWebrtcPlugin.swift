import Flutter
import UIKit

public class SwiftMedeaFlutterWebrtcPlugin: NSObject, FlutterPlugin {
  var binaryMessenger: FlutterBinaryMessenger?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "medea_flutter_webrtc", binaryMessenger: registrar.messenger())
    let instance = SwiftMedeaFlutterWebrtcPlugin()
    instance.binaryMessenger = registrar.messenger()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
