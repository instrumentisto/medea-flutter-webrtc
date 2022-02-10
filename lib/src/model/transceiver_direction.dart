enum TransceiverDirection {
  /// Indicates that Transceiver is both sending to and receiving from
  /// the remote peer connection.
  SEND_RECV,

  /// Indicates that Transceiver is sending to the remote peer, but is
  /// not receiving  any media from the remote peer.
  SEND_ONLY,

  /// Indicates that Transceiver is receiving from the remote peer, but is
  /// not sending any media to the remote peer.
  RECV_ONLY,

  /// Indicates that Transceiver is inactive, neither sending nor receiving
  /// any media data.
  INACTIVE,

  // TODO(#31): stopped?
}
