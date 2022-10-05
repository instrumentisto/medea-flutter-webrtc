import Flutter

/// Controller for the all Flutter event channels of this plugin.
class EventController: NSObject, FlutterStreamHandler {
  /// Flutter event sink for sending messages to the Flutter side.
  private var eventSink: FlutterEventSink?

  /// Sets `eventSink` into which will be sent all events.
  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = eventSink
    return nil
  }

  /// Resets `eventSink`.
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  /// Sends provided `data` to the Flutter side with Flutter event sink.
  ///
  /// If `eventSink` is `nil` then doesn't sends anything.
  func sendEvent(data: [String: Any]) {
    if self.eventSink != nil {
      self.eventSink!(data)
    }
  }
}
