import Flutter
import OSLog
import os

class VideoRendererFactoryController {
  private var messenger: FlutterBinaryMessenger
  private var channel: FlutterMethodChannel
  private var channelName: String
  private var registry: FlutterTextureRegistry

  init(messenger: FlutterBinaryMessenger, registry: FlutterTextureRegistry) {
    self.channelName = ChannelNameGenerator.name(name: "VideoRendererFactory", id: 0)
    self.messenger = messenger
    self.registry = registry
    self.channel = FlutterMethodChannel(name: self.channelName, binaryMessenger: messenger)
    self.channel.setMethodCallHandler({ (call, result) in
      try! self.onMethodCall(call: call, result: result)
    })
  }

  func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
    switch call.method {
    case "create":
      let renderer = FlutterRtcVideoRenderer(registry: self.registry)
      result(
        VideoRendererController(messenger: self.messenger, renderer: renderer).asFlutterResult())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
