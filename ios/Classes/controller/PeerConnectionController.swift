import Flutter
import OSLog
import os

public class PeerConnectionController {
    private var messenger: FlutterBinaryMessenger
    private var peer: PeerConnectionProxy
    private var channelId: Int = ChannelNameGenerator.nextId()
    private var channelName: String
    private var eventController: EventController
    private var eventChannel: FlutterEventChannel
    private var channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger, peer: PeerConnectionProxy) {
        self.channelName  = ChannelNameGenerator.name(name: "PeerConnection", id: self.channelId)
        self.eventController = EventController()
        self.messenger = messenger
        self.peer = peer
        self.peer.addEventObserver(eventObserver: PeerEventController(messenger: self.messenger, eventController: self.eventController))
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "FlutterWebRtc/PeerConnectionEvent/\(self.channelId)", binaryMessenger: messenger)
        self.channel.setMethodCallHandler({ (call, result) in
            try! self.onMethodCall(call: call, result: result)
        })
        self.eventChannel.setStreamHandler(self.eventController)
    }

    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        let argsMap = call.arguments as? [String : Any]
        switch (call.method) {
            case "createOffer":
                os_log(OSLogType.error, "createOffer")
                Task { 
                    let sdp = try! await self.peer.createOffer()
                    result(sdp.asFlutterResult())
                }
            case "createAnswer":
                os_log(OSLogType.error, "createAnswer")
                Task {
                    let sdp = try! await self.peer.createAnswer()
                    result(sdp.asFlutterResult())
                }
            case "setLocalDescription":
                os_log(OSLogType.error, "setLocalDescription")
                let description = argsMap!["description"] as? [String : Any]
                let type = description!["type"] as? Int
                let sdp = description!["description"] as? String
                Task {
                    var desc: SessionDescription?
                    if (sdp == nil) {
                        desc = nil
                    } else {
                        desc = SessionDescription(type: SessionDescriptionType(rawValue: type!)!, description: sdp!)
                    }
                    try! await self.peer.setLocalDescription(description: desc)
                    result(nil)
                }
            case "setRemoteDescription":
                os_log(OSLogType.error, "setRemoteDescription")
                let descriptionMap = argsMap!["description"] as? [String : Any]
                let type = descriptionMap!["type"] as? Int
                let sdp = descriptionMap!["description"] as? String
                Task {
                    try! await self.peer.setRemoteDescription(description: SessionDescription(type: SessionDescriptionType(rawValue: type!)!, description: sdp!))
                    result(nil)
                }
            case "addIceCandidate":
                os_log(OSLogType.error, "addIceCandidate")
                let candidateMap = argsMap!["candidate"] as? [String : Any]
                let sdpMid = candidateMap!["sdpMid"] as? String
                let sdpMLineIndex = candidateMap!["sdpMLineIndex"] as? Int
                let candidate = candidateMap!["candidate"] as? String
                Task {
                    try! await self.peer.addIceCandidate(candidate: IceCandidate(sdpMid: sdpMid!, sdpMLineIndex: sdpMLineIndex!, candidate: candidate!))
                    result(nil)
                }
            case "addTransceiver":
                let mediaType = argsMap!["mediaType"] as? Int
                let initArgs = argsMap!["init"] as? [String : Any]
                let transceiver = RtpTransceiverController(messenger: self.messenger, transceiver: self.peer.addTransceiver(mediaType: MediaType(rawValue: mediaType!)!))
                result(transceiver.asFlutterResult())
            case "getTransceivers":
                result(self.peer.getTransceivers().map {
                    RtpTransceiverController(messenger: self.messenger, transceiver: $0).asFlutterResult()
                })
            case "restartIce":
                self.peer.restartIce()
                result(nil)
            case "dispose":
                // TODO:
                result(nil)
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
