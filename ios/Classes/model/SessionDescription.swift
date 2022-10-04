import WebRTC

public class SessionDescription {
  private var type: SessionDescriptionType
  private var description: String

  init(type: SessionDescriptionType, description: String) {
    self.type = type
    self.description = description
  }

  init(sdp: RTCSessionDescription) {
    self.type = SessionDescriptionType(type: sdp.type)
    self.description = sdp.sdp
  }

  init(map: [String: Any]) {
    let ty = map["type"] as? Int
    self.type = SessionDescriptionType(rawValue: ty!)!
    let description = map["description"] as? String
    self.description = description!
  }

  func intoWebRtc() -> RTCSessionDescription {
    return RTCSessionDescription(type: self.type.intoWebRtc(), sdp: self.description)
  }

  func asFlutterResult() -> [String: Any] {
    return [
      "type": self.type.asFlutterResult(),
      "description": self.description,
    ]
  }
}
