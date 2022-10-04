import WebRTC

class TransceiverInit {
  private var direction: TransceiverDirection

  init(direction: TransceiverDirection) {
    self.direction = direction
  }

  func intoWebRtc() -> RTCRtpTransceiverInit {
    let conf = RTCRtpTransceiverInit()
    conf.direction = self.direction.intoWebRtc()
    return conf
  }
}

enum IceTransportType: Int {
  case all, relay, noHost, none

  func intoWebRtc() -> RTCIceTransportPolicy {
    switch self {
    case .all:
      return RTCIceTransportPolicy.all
    case .relay:
      return RTCIceTransportPolicy.relay
    case .noHost:
      return RTCIceTransportPolicy.noHost
    case .none:
      return RTCIceTransportPolicy.none
    }
  }
}

class IceServer {
  private var urls: [String]
  private var username: String?
  private var password: String?

  init(urls: [String], username: String?, password: String?) {
    self.urls = urls
    self.username = username
    self.password = password
  }

  func intoWebRtc() -> RTCIceServer {
    return RTCIceServer(urlStrings: self.urls, username: self.username, credential: self.password)
  }
}

class PeerConnectionConfiguration {
  var iceServers: [IceServer]
  var iceTransportType: IceTransportType

  init(iceServers: [IceServer], iceTransportType: IceTransportType) {
    self.iceServers = iceServers
    self.iceTransportType = iceTransportType
  }

  func intoWebRtc() -> RTCConfiguration {
    let conf = RTCConfiguration()
    conf.iceServers = iceServers.map({ serv -> RTCIceServer in
      return serv.intoWebRtc()
    })
    conf.iceTransportPolicy = self.iceTransportType.intoWebRtc()
    conf.sdpSemantics = RTCSdpSemantics.unifiedPlan
    return conf
  }
}
