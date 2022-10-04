public enum MediaDeviceKind: Int {
  case audioInput = 0
  case videoInput = 1
  case audioOutput = 2

  public func asFlutterResult() -> Int {
    return self.rawValue
  }
}
