import Flutter

class EventController : NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func sendEvent(data: [String : Any]) {
        self.eventSink!(data)
    }
}