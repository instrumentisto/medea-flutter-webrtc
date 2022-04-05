import '/src/api/transceiver.dart';
import '/src/model/ice.dart';
import '/src/model/peer.dart';
import '/src/platform/native/media_stream_track.dart';

export '/src/api/ffi/peer.dart'
    if (dart.library.html) '/src/api/channel/peer.dart';

/// Shortcut for the `on_track` callback.
typedef OnTrackCallback = void Function(NativeMediaStreamTrack, RtpTransceiver);

/// Shortcut for the `on_ice_candidate` callback.
typedef OnIceCandidateCallback = void Function(IceCandidate);

/// Shortcut for the `on_ice_connection_state_change` callback.
typedef OnIceConnectionStateChangeCallback = void Function(IceConnectionState);

/// Shortcut for the `on_connection_state_change` callback.
typedef OnConnectionStateChangeCallback = void Function(PeerConnectionState);

/// Shortcut for the `on_ice_gathering_state_change` callback.
typedef OnIceGatheringStateChangeCallback = void Function(IceGatheringState);

/// Shortcut for the `on_negotiation_needed` callback.
typedef OnNegotiationNeededCallback = void Function();

/// Shortcut for the `on_signaling_state_change` callback.
typedef OnSignalingStateChangeCallback = void Function(SignalingState);

/// Shortcut for the `on_ice_candidate_error` callback.
typedef OnIceCandidateErrorCallback = void Function(IceCandidateErrorEvent);
