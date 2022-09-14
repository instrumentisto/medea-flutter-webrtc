public enum MediaDeviceKind: Int {
    case audioInput = 0, videoInput = 1, audioOutput = 2

    public func asFlutterResult() -> Int {
        return self.rawValue
    }
}