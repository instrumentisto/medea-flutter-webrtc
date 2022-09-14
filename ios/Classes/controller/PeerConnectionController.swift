import Flutter

public class PeerConnectionController {
    private var messenger: FlutterBinaryMessenger
    private var peer: PeerConnectionProxy
    private var channelId: String = ChannelNameGenerator.name(name: "PeerConnection", id: ChannelNameGenerator.nextId())
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, peer: PeerConnectionProxy) {
        self.messenger = messenger
        self.peer = peer
        self.channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
    }

    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "createOffer":
                Task { 
                    let sdp = try! await self.peer.createOffer()
                    result(sdp)
                }
            case "createAnswer":
                Task {
                    let sdp = try! await self.peer.createAnswer()
                    result(sdp)
                }
            case "setLocalDescription":
                let description = argsMap!["description"] as? [String : Any]
                let type = description!["type"] as? Int
                let sdp = description!["description"] as? String
                Task {
                    try! await self.peer.setLocalDescription(description: SessionDescription(type: SessionDescriptionType(rawValue: type!)!, description: sdp!))
                }
            case "setRemoteDescription":
                let descriptionMap = argsMap!["description"] as? [String : Any]
                let type = descriptionMap!["type"] as? Int
                let sdp = descriptionMap!["description"] as? String
                Task {
                    try! await self.peer.setRemoteDescription(description: SessionDescription(type: SessionDescriptionType(rawValue: type!)!, description: sdp!))
                    result(nil)
                }
            case "addIceCandidate":
                let candidateMap = argsMap!["candidate"] as? [String : Any]
                let sdpMid = candidateMap!["sdpMid"] as? String
                let sdpMLineIndex = candidateMap!["sdpMLineIndex"] as? Int
                let candidate = candidateMap!["candidate"] as? String
                Task {
                    try! await self.peer.addIceCandidate(candidate: IceCandidate(sdpMid: sdpMid!, sdpMLineIndex: sdpMLineIndex!, candidate: candidate!))
                    result(nil)
                }
            case "addTransceiver":
                abort()
            case "getTransceivers":
                result(self.peer.getTransceivers().map {
                    RtpTransceiverController(messenger: self.messenger, transceiver: $0).asFlutterResult()
                })
            case "restartIce":
                self.peer.restartIce()
                result(nil)
            case "dispose":
                abort()
            default:
                result(FlutterMethodNotImplemented)
        }
    }

    func asFlutterResult() -> [String : Any] {
        return [
            "channelId" : self.channelId,
            "id" : self.peer.getId()
        ]
    }
}
