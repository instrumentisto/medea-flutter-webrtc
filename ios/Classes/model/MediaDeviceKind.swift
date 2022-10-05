public enum MediaDeviceKind: Int {
  case audioInput, videoInput, audioOutput

  public func asFlutterResult() -> Int {
    return self.rawValue
  }
}
