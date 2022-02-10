/// Direction of the Transceiver.
enum TransceiverDirection {
  /// Indicates that Transceiver is both sending to and receiving from
  /// the remote peer connection.
  sendRecv,

  /// Indicates that Transceiver is sending to the remote peer, but is
  /// not receiving  any media from the remote peer.
  sendOnly,

  /// Indicates that Transceiver is receiving from the remote peer, but is
  /// not sending any media to the remote peer.
  recvOnly,

  /// Indicates that Transceiver is inactive, neither sending nor receiving
  /// any media data.
  inactive,

  /// The Transceiver will neither send nor receive RTP. It will generate a
  /// zero port in the offer.
  stopped,
}
