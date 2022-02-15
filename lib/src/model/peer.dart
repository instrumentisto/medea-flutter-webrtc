/// ICE transport which should be used by some `PeerConnection`.
enum IceTransportType {
  /// Offer all types of ICE candidates.
  all,

  /// Only advertize relay-type candidates, like TURN servers, to avoid leaking the IP address of the client.
  relay,

  /// Gather all ICE candidate types except for host candidates.
  nohost,

  /// No ICE candidate offered.
  none,
}

/// ICE server which should be used by some `PeerConnection`.
class IceServer {
  /// Creates new ICE server with a provided parameters.
  IceServer(this.urls, this.username, this.password);

  /// List of URLs of this [IceServer].
  late List<String> urls;

  /// Username for auth on this [IceServer].
  String? username;

  /// Password for auth on this [IceServer].
  String? password;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {
      'urls': urls,
      'username': username,
      'password': password,
    };
  }
}

/// The current state of the ICE agent and its connection.
enum IceConnectionState {
  /// The ICE agent is gathering addresses or is waiting to be given remote
  /// candidates through calls to `PeerConnection.addIceCandidate()` (or both).
  new_,

  /// The ICE agent has been given one or more remote candidates and is
  /// checking pairs of local and remote candidates against one another to try
  /// to find a compatible match, but has not yet found a pair which will allow
  /// the peer connection to be made. It is possible that gathering of
  /// candidates is also still underway.
  checking,

  /// A usable pairing of local and remote candidates has been found for all
  /// components of the connection, and the connection has been established.
  /// It is possible that gathering is still underway, and it is also possible
  /// that the ICE agent is still checking candidates against one another
  /// looking for a better connection to use.
  connected,

  /// The ICE agent has finished gathering candidates, has checked all pairs
  /// against one another, and has found a connection for all components.
  completed,

  /// The ICE candidate has checked all candidates pairs against one another
  /// and has failed to find compatible matches for all components of the
  /// connection.
  /// It is, however, possible that the ICE agent did find compatible
  /// connections for some components.
  failed,

  /// Checks to ensure that components are still connected failed for at least
  /// one component of the `PeerConnection`. This is a less stringent test
  /// than failed and may trigger intermittently and resolve just as
  /// spontaneously on less reliable networks, or during temporary
  /// disconnections. When the problem resolves, the connection may
  /// return to the connected state.
  disconnected,

  /// The ICE agent for this `PeerConnection` has shut down and is no
  /// longer handling requests.
  closed,
}

/// Connection's ICE gathering state.
enum IceGatheringState {
  /// The peer connection was just created and hasn't done any networking yet.
  new_,

  /// The ICE agent is in the process of gathering candidates for the connection.
  gathering,

  /// The ICE agent has finished gathering candidates. If something happens
  /// that requires collecting new candidates, such as a new interface being
  /// added or the addition of a new ICE server, the state will revert to
  /// gathering to gather those candidates.
  complete,
}

/// State of the signaling process on the local end of the connection while
/// connecting or reconnecting to another peer.
enum SignalingState {
  /// There is no ongoing exchange of offer and answer underway.
  stable,

  /// The local peer has called `PeerConnection.setLocalDescription()`,
  /// passing in SDP representing an offer (usually created by calling
  /// `PeerConnection.createOffer()`), and the offer has been applied
  /// successfully.
  haveLocalOffer,

  /// The offer sent by the remote peer has been applied and an answer has
  /// been created (usually by calling `PeerConnection.createAnswer()`) and
  /// applied by calling `PeerConnection.setLocalDescription()`.
  haveLocalPranswer,

  /// The remote peer has created an offer and used the signaling server to
  /// deliver it to the local peer, which has set the offer as the remote
  /// description by calling `PeerConnection.setRemoteDescription()`.
  haveRemoteOffer,

  /// The offer sent by the remote peer has been applied and an answer has been
  /// created (usually by calling `PeerConnection.createAnswer()`) and applied
  /// by calling `PeerConnection.setLocalDescription()`. This provisional
  /// answer describes the supported media formats and so forth, but may
  /// not have a complete set of ICE candidates included. Further candidates
  /// will be delivered separately later.
  haveRemotePranswer,

  /// The `PeerConnection` has been closed.
  closed,
}

/// Indicates the current state of the peer connection.
enum PeerConnectionState {
  /// At least one of the connection's ICE transports is in the new state,
  /// and none of them are in one of the following states: connecting,
  /// checking, failed, disconnected, or all of the connection's transports are
  /// in the closed state.
  new_,

  /// One or more of the ICE transports are currently in the process of
  /// establishing a connection; that is, their `iceConnectionState` is
  /// either checking or connected, and no transports are in the failed state.
  connecting,

  /// Every ICE transport used by the connection is either in use (state
  /// connected or completed) or is closed (state closed); in addition,
  /// at least one transport is either connected or completed.
  connected,

  /// At least one of the ICE transports for the connection is in the
  /// disconnected state and none of the other transports are in the state
  /// failed, connecting, or checking.
  disconnected,

  /// One or more of the ICE transports on the connection is in the failed
  /// state.
  failed,

  /// The `PeerConnection` is closed.
  closed,
}
