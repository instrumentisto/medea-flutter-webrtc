class IceCandidate {
  IceCandidate.fromMap(Map<String, dynamic> map) {
    sdpMid = map['sdpMid'];
    sdpMLineIndex = map['sdpMLineIndex'];
    sdp = map['sdp'];
  }

  IceCandidate(this.sdpMid, this.sdpMLineIndex, this.sdp);

  late String sdpMid;
  late int sdpMLineIndex;
  late String sdp;

  Map<String, dynamic> toMap() {
    return {
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'sdp': sdp,
    };
  }
}
