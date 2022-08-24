import Flutter

public class MediaDevicesController {
    private var messenger: FlutterBinaryMessenger
    private var mediaDevices: MediaDevices

    init(messenger: FlutterBinaryMessenger, mediaDevices: MediaDevices) {
        self.messenger = messenger
        self.mediaDevices = mediaDevices
    }

    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch (call.method) {
            case "enumerateDevices":
                result(self.mediaDevices.enumerateDevices().map { $0.asFlutterResult() })
            case "getUserMedia":
                let tracks = self.mediaDevices.getUserMedia()
                return result(tracks.map { MediaStreamTrackController(messenger: self.messenger, track: $0) })
            case "setOutputAudioId":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }
}
