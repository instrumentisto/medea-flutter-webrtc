import WebRTC

/// Representation of an `RTCSessionDescription`.
class SessionDescription {
  /// Type of this [SessionDescription].
  private var type: SessionDescriptionType

  /// Description SDP of this [SessionDescription].
  private var description: String

  /// Creates new `SessionDescription` with a provided data.
  init(type: SessionDescriptionType, description: String) {
    self.type = type
    self.description = description
  }

  /// Converts the provided `RTCSessionDescription` into a `SessionDescription`.
  init(sdp: RTCSessionDescription) {
    self.type = SessionDescriptionType(type: sdp.type)
    self.description = sdp.sdp
  }

  /// Creates a new `SessionDescription` object based on the method call received from the Flutter side.
  init(map: [String: Any]) {
    let ty = map["type"] as? Int
    self.type = SessionDescriptionType(rawValue: ty!)!
    let description = map["description"] as? String
    self.description = description!
  }

  /// Converts this `SessionDescription` into an `RTCSessionDescription`.
  func intoWebRtc() -> RTCSessionDescription {
    return RTCSessionDescription(type: self.type.intoWebRtc(), sdp: self.description)
  }

  /// Converts this `SessionDescription` into a `Dictionary` which can be returned to the Flutter side.
  func asFlutterResult() -> [String: Any] {
    return [
      "type": self.type.rawValue,
      "description": self.description,
    ]
  }
}
