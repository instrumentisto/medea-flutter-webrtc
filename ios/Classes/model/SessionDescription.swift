public class SessionDescription {
    private var type: SessionDescriptionType
    private var description: String

    init(type: SessionDescriptionType, description: String) {
        self.type = type
        self.description = description
    }

    init(sdp: RTCSessionDescription) {
        self = SessionDescription(SessionDescriptionType(type: sdp.type, description: sdp.description))
    }

    init(map: [String : Any]) {
        let type = SessionDescriptionType(rawValue: map["type"] as Number)
        let description = map["description"] as String
        self = SessionDescription(type, description: String)
    }

    func intoWebRtc() -> RTCSessionDescription {
        return RTCSessionDescription.initWithType(type: self.type.intoWebRtc(), sdp: self.description)
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "type": self.type.asFlutterResult(),
            "description": self.description,
        ]
    }
}