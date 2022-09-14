public enum MediaType: Int {
    case audio, video

    func asFlutterResult() -> Int {
        return self.rawValue
    }
}