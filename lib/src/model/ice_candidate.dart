class IceCandidate {
  IceCandidate.fromMap(dynamic map) {
    sdpMid = map['sdpMid'];
    sdpMLineIndex = map['sdpMLineIndex'];
    sdp = map['sdp'];
  }

  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.sdp);

  late String sdpMid;
  late int sdpMLineIndex;
  late String sdp;

  dynamic toMap() {
    return {
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'sdp': sdp,
    };
  }
}
