/// Represents a candidate Interactive Connectivity Establishment (ICE)
/// configuration which may be used to establish an PeerConnection.
class IceCandidate {
  /// Creates new [IceCandidate] with the provided parameters.
  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.candidate);

  /// Creates [IceCandidate] based on the [Map] received from the native side.
  IceCandidate.fromMap(Map<String, dynamic> map) {
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
