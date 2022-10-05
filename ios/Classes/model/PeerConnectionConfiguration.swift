import WebRTC

/// Representation of an `RTCRtpTransceiverInit`.
class TransceiverInit {
  /// Direction of the transceiver, created from this config.
  private var direction: TransceiverDirection

  /// Creates new `TransceiverInit` with a provided data.
  init(direction: TransceiverDirection) {
    self.direction = direction
  }

  /**
    Converts this `RtpTransceiverInit` into an `RTCRtpTransceiverInit`.

    - Returns: `RTCRtpTransceiverInit` created based on this `RtpTransceiverInit`.
   */
  func intoWebRtc() -> RTCRtpTransceiverInit {
    let conf = RTCRtpTransceiverInit()
    conf.direction = self.direction.intoWebRtc()
    return conf
  }
}

/// Representation of a [PeerConnection.IceTransportsType].
enum IceTransportType: Int {
  /// Offer all types of ICE candidates.
  case all

  /**
    Only advertise relay-type candidates, like TURN servers, to avoid leaking IP addresses of the
    client.
  */
  case relay

  /// Gather all ICE candidate types except host candidates.
  case noHost

  /// No ICE candidate offered.
  case none

  /**
    Converts this `IceTransportType` into a `RTCIceTransportsType`.

    Returns: `RTCIceTransportsType` based on this `IceTransportType`.
  */
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

/// Representation of a [PeerConnection.IceServer].
class IceServer {
  /// List of URLs of this [IceServer].
  private var urls: [String]

  /// Username for authentication on this [IceServer].
  private var username: String?

  /// Password for authentication on this [IceServer].
  private var password: String?

  /// Creates new `IceServer` with a provided data.
  init(urls: [String], username: String?, password: String?) {
    self.urls = urls
    self.username = username
    self.password = password
  }

  /**
    Converts this `IceServer` into a `RTCIceServer`.

    - Returns: `RTCIceServer` based on this `IceServer`.
   */
  func intoWebRtc() -> RTCIceServer {
    return RTCIceServer(urlStrings: self.urls, username: self.username, credential: self.password)
  }
}

/// Representation of a [PeerConnection.RTCConfiguration].
class PeerConnectionConfiguration {
  /**
    List of `IceServer`s, used by the `PeerConnection` created with this
    `PeerConnectionConfiguration`.
  */
  var iceServers: [IceServer]

  /**
    Type of the ICE transport, used by the `PeerConnection` created with
    this `PeerConnectionConfiguration`.
  */
  var iceTransportType: IceTransportType

  /// Creates new `PeerConnectionConfiguration` based on provided data.
  init(iceServers: [IceServer], iceTransportType: IceTransportType) {
    self.iceServers = iceServers
    self.iceTransportType = iceTransportType
  }

  /**
    Converts this `PeerConnectionConfiguration` into a `RTCConfiguration`.

    - Returns: `RTCConfiguration` based on this `PeerConnectionConfiguration`.
  */
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
