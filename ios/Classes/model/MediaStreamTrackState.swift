public enum MediaStreamTrackState: Int {
    case live
    case ended

    func asFlutterResult() -> Int {
        return self.rawValue
    }
}