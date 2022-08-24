public class MediaDeviceInfo {
    var deviceId: String
    var label: String
    var kind: MediaDeviceKind

    init(deviceId: String, label: String, kind: MediaDeviceKind) {
        self.deviceId = deviceId
        self.label = label
        self.kind = kind
    }

    public func asFlutterResult() -> [String : Any?] {
        return [
            "deviceId": self.deviceId,
            "label": self.label,
            "kind": self.kind.toInt()
        ]
    }
}