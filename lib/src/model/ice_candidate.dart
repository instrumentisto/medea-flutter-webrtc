class IceCandidate {
  /// Creates new [IceCandidate] with the provided parameters.
  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.sdp);

  /// Creates [IceCandidate] based on the [Map] received from the native side.
  IceCandidate.fromMap(dynamic map) {
    sdpMid = map['sdpMid'];
    sdpMLineIndex = map['sdpMLineIndex'];
    sdp = map['sdp'];
  }

  /// Mid of this [IceCandidate].
  late String sdpMid;

  /// SDP m line index of this [IceCandidate].
  late int sdpMLineIndex;

  /// SDP of this [IceCandidate].
  late String sdp;

  /// Converts this model to the [Map] expected by Flutter.
  dynamic toMap() {
    return {
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'sdp': sdp,
    };
  }
}
