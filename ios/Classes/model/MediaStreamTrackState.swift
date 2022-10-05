public enum MediaStreamTrackState: Int {
  case live, ended

  func asFlutterResult() -> Int {
    return self.rawValue
  }
}
