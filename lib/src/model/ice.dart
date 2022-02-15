/// Represents a candidate Interactive Connectivity Establishment (ICE)
/// configuration which may be used to establish an PeerConnection.
class IceCandidate {
  /// Creates new [IceCandidate] with the provided parameters.
  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.candidate);

  /// Creates [IceCandidate] based on the [Map] received from the native side.
  IceCandidate.fromMap(dynamic map) {
    sdpMid = map['sdpMid'];
    sdpMLineIndex = map['sdpMLineIndex'];
    candidate = map['candidate'];
  }

  /// Mid of this [IceCandidate].
  late String sdpMid;

  /// SDP m line index of this [IceCandidate].
  late int sdpMLineIndex;

  /// SDP of this [IceCandidate].
  late String candidate;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'candidate': candidate,
    };
  }
}

/// Description of the error occurred with ICE candidate from PeerConnection.
class IceCandidateErrorEvent {
  /// Creates [IceCandidateErrorEvent] based on the [Map] received
  /// from the native side.
  IceCandidateErrorEvent.fromMap(dynamic map) {
    address = map['address'];
    port = map['port'];
    url = map['url'];
    errorCode = map['errorCode'];
    errorText = map['errorText'];
  }

  /// The local IP address used to communicate with the STUN or TURN server.
  late String address;

  /// The port used to communicate with the STUN or TURN server.
  late int port;

  /// The STUN or TURN URL that identifies the STUN or TURN server for which
  /// the failure occurred.
  late String url;

  /// The numeric STUN error code returned by the STUN or TURN server. If no
  /// host candidate can reach the server, errorCode will be set to the value
  /// 701 which is outside the STUN error code range. This error is only fired
  /// once per server URL while in the RTCIceGatheringState of "gathering".
  late int errorCode;

  /// The STUN reason text returned by the STUN or TURN server. If the server
  /// could not be reached, errorText will be set to an implementation-specific
  /// value providing details about the error.
  late String errorText;
}
