import Flutter
import WebRTC

/// Controller of the global logging configuration.
class LoggingController {
  /// Method channel for communicating with Flutter side.
  private var channel: FlutterMethodChannel

  /// Initializes a new `LoggingController` and binds method channel handlers.
  init(messenger: FlutterBinaryMessenger) {
    let channelName = ChannelNameGenerator.name(
      name: "logging",
      id: 0
    )
    self.channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    self.channel.setMethodCallHandler { call, result in
      self.onMethodCall(call: call, result: result)
    }
  }

  /// Handles all the supported Flutter method calls.
  func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
    let argsMap = call.arguments as? [String: Any]
    switch call.method {
    case "setLogLevel":
      let level = argsMap?["level"] as? Int
      let severity: RTCLoggingSeverity
      switch level {
      case 0:
        severity = .verbose
      case 1:
        severity = .info
      case 2:
        severity = .warning
      case 3:
        severity = .error
      default:
        severity = .warning
      }

      RTCSetMinDebugLogLevel(severity)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
