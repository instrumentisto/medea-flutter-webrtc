/// Represents an information about some media device.
class MediaDeviceInfo {
  /// Identifier of the represented media device.
  var deviceId: String

  /// Human-readable device description (for example, "External USB Webcam").
  var label: String

  /// Media kind of the media device.
  var kind: MediaDeviceKind

  /// Creates new `MediaDeviceInfo` based on provided data.
  init(deviceId: String, label: String, kind: MediaDeviceKind) {
    self.deviceId = deviceId
    self.label = label
    self.kind = kind
  }

  /// Converts this `MediaDeviceInfo` into a `Dictionary` which can be returned to the Flutter side.
  func asFlutterResult() -> [String: Any?] {
    [
      "deviceId": deviceId,
      "label": label,
      "kind": kind.rawValue,
    ]
  }
}
