import Flutter

public class MediaStreamTrackController : FlutterPlugin {
    private var messenger: FlutterBinaryMessenger
    private var track: MediaStreamTrackProxy

    init(messenger: FlutterBinaryMessenger, track: MediaStreamTrackProxy) {
        self.messenger = messenger
        self.track = track
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch (call.method) {
            case "setEnabled":
                abort()
            case "state":
                abort()
            case "stop":
                abort()
            case "clone":
                abort()
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
