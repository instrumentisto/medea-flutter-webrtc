// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PeerConnectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEventCopyWith(
    PeerConnectionEvent value,
    $Res Function(PeerConnectionEvent) then,
  ) = _$PeerConnectionEventCopyWithImpl<$Res, PeerConnectionEvent>;
}

/// @nodoc
class _$PeerConnectionEventCopyWithImpl<$Res, $Val extends PeerConnectionEvent>
    implements $PeerConnectionEventCopyWith<$Res> {
  _$PeerConnectionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PeerConnectionEvent_PeerCreatedImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_PeerCreatedImplCopyWith(
    _$PeerConnectionEvent_PeerCreatedImpl value,
    $Res Function(_$PeerConnectionEvent_PeerCreatedImpl) then,
  ) = __$$PeerConnectionEvent_PeerCreatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ArcPeerConnection peer});
}

/// @nodoc
class __$$PeerConnectionEvent_PeerCreatedImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_PeerCreatedImpl
        >
    implements _$$PeerConnectionEvent_PeerCreatedImplCopyWith<$Res> {
  __$$PeerConnectionEvent_PeerCreatedImplCopyWithImpl(
    _$PeerConnectionEvent_PeerCreatedImpl _value,
    $Res Function(_$PeerConnectionEvent_PeerCreatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peer = null}) {
    return _then(
      _$PeerConnectionEvent_PeerCreatedImpl(
        peer: null == peer
            ? _value.peer
            : peer // ignore: cast_nullable_to_non_nullable
                  as ArcPeerConnection,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_PeerCreatedImpl
    extends PeerConnectionEvent_PeerCreated {
  const _$PeerConnectionEvent_PeerCreatedImpl({required this.peer}) : super._();

  /// Rust side [`PeerConnection`].
  @override
  final ArcPeerConnection peer;

  @override
  String toString() {
    return 'PeerConnectionEvent.peerCreated(peer: $peer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_PeerCreatedImpl &&
            (identical(other.peer, peer) || other.peer == peer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, peer);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_PeerCreatedImplCopyWith<
    _$PeerConnectionEvent_PeerCreatedImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_PeerCreatedImplCopyWithImpl<
        _$PeerConnectionEvent_PeerCreatedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return peerCreated(peer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return peerCreated?.call(peer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(peer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return peerCreated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return peerCreated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_PeerCreated extends PeerConnectionEvent {
  const factory PeerConnectionEvent_PeerCreated({
    required final ArcPeerConnection peer,
  }) = _$PeerConnectionEvent_PeerCreatedImpl;
  const PeerConnectionEvent_PeerCreated._() : super._();

  /// Rust side [`PeerConnection`].
  ArcPeerConnection get peer;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_PeerCreatedImplCopyWith<
    _$PeerConnectionEvent_PeerCreatedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateImplCopyWith(
    _$PeerConnectionEvent_IceCandidateImpl value,
    $Res Function(_$PeerConnectionEvent_IceCandidateImpl) then,
  ) = __$$PeerConnectionEvent_IceCandidateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_IceCandidateImpl
        >
    implements _$$PeerConnectionEvent_IceCandidateImplCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateImplCopyWithImpl(
    _$PeerConnectionEvent_IceCandidateImpl _value,
    $Res Function(_$PeerConnectionEvent_IceCandidateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdpMid = null,
    Object? sdpMlineIndex = null,
    Object? candidate = null,
  }) {
    return _then(
      _$PeerConnectionEvent_IceCandidateImpl(
        sdpMid: null == sdpMid
            ? _value.sdpMid
            : sdpMid // ignore: cast_nullable_to_non_nullable
                  as String,
        sdpMlineIndex: null == sdpMlineIndex
            ? _value.sdpMlineIndex
            : sdpMlineIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        candidate: null == candidate
            ? _value.candidate
            : candidate // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceCandidateImpl
    extends PeerConnectionEvent_IceCandidate {
  const _$PeerConnectionEvent_IceCandidateImpl({
    required this.sdpMid,
    required this.sdpMlineIndex,
    required this.candidate,
  }) : super._();

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  @override
  final String sdpMid;

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  @override
  final int sdpMlineIndex;

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  @override
  final String candidate;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidate(sdpMid: $sdpMid, sdpMlineIndex: $sdpMlineIndex, candidate: $candidate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidateImpl &&
            (identical(other.sdpMid, sdpMid) || other.sdpMid == sdpMid) &&
            (identical(other.sdpMlineIndex, sdpMlineIndex) ||
                other.sdpMlineIndex == sdpMlineIndex) &&
            (identical(other.candidate, candidate) ||
                other.candidate == candidate));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sdpMid, sdpMlineIndex, candidate);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceCandidateImplCopyWith<
    _$PeerConnectionEvent_IceCandidateImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_IceCandidateImplCopyWithImpl<
        _$PeerConnectionEvent_IceCandidateImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceCandidate(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidate?.call(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(sdpMid, sdpMlineIndex, candidate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceCandidate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceCandidate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceCandidate extends PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidate({
    required final String sdpMid,
    required final int sdpMlineIndex,
    required final String candidate,
  }) = _$PeerConnectionEvent_IceCandidateImpl;
  const PeerConnectionEvent_IceCandidate._() : super._();

  /// Media stream "identification-tag" defined in [RFC 5888] for the
  /// media component the discovered [RTCIceCandidate][1] is associated
  /// with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5888]: https://tools.ietf.org/html/rfc5888
  String get sdpMid;

  /// Index (starting at zero) of the media description in the SDP this
  /// [RTCIceCandidate][1] is associated with.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  int get sdpMlineIndex;

  /// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
  ///
  /// If this [RTCIceCandidate][1] represents an end-of-candidates
  /// indication or a peer reflexive remote candidate, candidate is an
  /// empty string.
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
  /// [RFC 5245]: https://tools.ietf.org/html/rfc5245
  String get candidate;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_IceCandidateImplCopyWith<
    _$PeerConnectionEvent_IceCandidateImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWith<
  $Res
> {
  factory _$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWith(
    _$PeerConnectionEvent_IceGatheringStateChangeImpl value,
    $Res Function(_$PeerConnectionEvent_IceGatheringStateChangeImpl) then,
  ) = __$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({IceGatheringState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_IceGatheringStateChangeImpl
        >
    implements
        _$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWith<$Res> {
  __$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWithImpl(
    _$PeerConnectionEvent_IceGatheringStateChangeImpl _value,
    $Res Function(_$PeerConnectionEvent_IceGatheringStateChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PeerConnectionEvent_IceGatheringStateChangeImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as IceGatheringState,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceGatheringStateChangeImpl
    extends PeerConnectionEvent_IceGatheringStateChange {
  const _$PeerConnectionEvent_IceGatheringStateChangeImpl(this.field0)
    : super._();

  @override
  final IceGatheringState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceGatheringStateChange(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceGatheringStateChangeImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWith<
    _$PeerConnectionEvent_IceGatheringStateChangeImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWithImpl<
        _$PeerConnectionEvent_IceGatheringStateChangeImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceGatheringStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceGatheringStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceGatheringStateChange != null) {
      return iceGatheringStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceGatheringStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceGatheringStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceGatheringStateChange != null) {
      return iceGatheringStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceGatheringStateChange
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_IceGatheringStateChange(
    final IceGatheringState field0,
  ) = _$PeerConnectionEvent_IceGatheringStateChangeImpl;
  const PeerConnectionEvent_IceGatheringStateChange._() : super._();

  IceGatheringState get field0;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_IceGatheringStateChangeImplCopyWith<
    _$PeerConnectionEvent_IceGatheringStateChangeImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateErrorImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateErrorImplCopyWith(
    _$PeerConnectionEvent_IceCandidateErrorImpl value,
    $Res Function(_$PeerConnectionEvent_IceCandidateErrorImpl) then,
  ) = __$$PeerConnectionEvent_IceCandidateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String address,
    int port,
    String url,
    int errorCode,
    String errorText,
  });
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateErrorImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_IceCandidateErrorImpl
        >
    implements _$$PeerConnectionEvent_IceCandidateErrorImplCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateErrorImplCopyWithImpl(
    _$PeerConnectionEvent_IceCandidateErrorImpl _value,
    $Res Function(_$PeerConnectionEvent_IceCandidateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? port = null,
    Object? url = null,
    Object? errorCode = null,
    Object? errorText = null,
  }) {
    return _then(
      _$PeerConnectionEvent_IceCandidateErrorImpl(
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        errorCode: null == errorCode
            ? _value.errorCode
            : errorCode // ignore: cast_nullable_to_non_nullable
                  as int,
        errorText: null == errorText
            ? _value.errorText
            : errorText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceCandidateErrorImpl
    extends PeerConnectionEvent_IceCandidateError {
  const _$PeerConnectionEvent_IceCandidateErrorImpl({
    required this.address,
    required this.port,
    required this.url,
    required this.errorCode,
    required this.errorText,
  }) : super._();

  /// Local IP address used to communicate with the STUN or TURN server.
  @override
  final String address;

  /// Port used to communicate with the STUN or TURN server.
  @override
  final int port;

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  @override
  final String url;

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  @override
  final int errorCode;

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  @override
  final String errorText;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceCandidateError(address: $address, port: $port, url: $url, errorCode: $errorCode, errorText: $errorText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidateErrorImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.errorText, errorText) ||
                other.errorText == errorText));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, address, port, url, errorCode, errorText);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceCandidateErrorImplCopyWith<
    _$PeerConnectionEvent_IceCandidateErrorImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_IceCandidateErrorImplCopyWithImpl<
        _$PeerConnectionEvent_IceCandidateErrorImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceCandidateError(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidateError?.call(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceCandidateError != null) {
      return iceCandidateError(address, port, url, errorCode, errorText);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceCandidateError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceCandidateError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceCandidateError != null) {
      return iceCandidateError(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceCandidateError
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidateError({
    required final String address,
    required final int port,
    required final String url,
    required final int errorCode,
    required final String errorText,
  }) = _$PeerConnectionEvent_IceCandidateErrorImpl;
  const PeerConnectionEvent_IceCandidateError._() : super._();

  /// Local IP address used to communicate with the STUN or TURN server.
  String get address;

  /// Port used to communicate with the STUN or TURN server.
  int get port;

  /// STUN or TURN URL identifying the STUN or TURN server for which the
  /// failure occurred.
  String get url;

  /// Numeric STUN error code returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If no host candidate can reach the server, it will be set to the
  /// value `701` which is outside the STUN error code range.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  int get errorCode;

  /// STUN reason text returned by the STUN or TURN server
  /// [`STUN-PARAMETERS`][1].
  ///
  /// If the server could not be reached, it will be set to an
  /// implementation-specific value providing details about the error.
  ///
  /// [1]: https://tinyurl.com/stun-parameters-6
  String get errorText;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_IceCandidateErrorImplCopyWith<
    _$PeerConnectionEvent_IceCandidateErrorImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_NegotiationNeededImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_NegotiationNeededImplCopyWith(
    _$PeerConnectionEvent_NegotiationNeededImpl value,
    $Res Function(_$PeerConnectionEvent_NegotiationNeededImpl) then,
  ) = __$$PeerConnectionEvent_NegotiationNeededImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PeerConnectionEvent_NegotiationNeededImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_NegotiationNeededImpl
        >
    implements _$$PeerConnectionEvent_NegotiationNeededImplCopyWith<$Res> {
  __$$PeerConnectionEvent_NegotiationNeededImplCopyWithImpl(
    _$PeerConnectionEvent_NegotiationNeededImpl _value,
    $Res Function(_$PeerConnectionEvent_NegotiationNeededImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PeerConnectionEvent_NegotiationNeededImpl
    extends PeerConnectionEvent_NegotiationNeeded {
  const _$PeerConnectionEvent_NegotiationNeededImpl() : super._();

  @override
  String toString() {
    return 'PeerConnectionEvent.negotiationNeeded()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_NegotiationNeededImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return negotiationNeeded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return negotiationNeeded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (negotiationNeeded != null) {
      return negotiationNeeded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return negotiationNeeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return negotiationNeeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (negotiationNeeded != null) {
      return negotiationNeeded(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_NegotiationNeeded
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_NegotiationNeeded() =
      _$PeerConnectionEvent_NegotiationNeededImpl;
  const PeerConnectionEvent_NegotiationNeeded._() : super._();
}

/// @nodoc
abstract class _$$PeerConnectionEvent_SignallingChangeImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_SignallingChangeImplCopyWith(
    _$PeerConnectionEvent_SignallingChangeImpl value,
    $Res Function(_$PeerConnectionEvent_SignallingChangeImpl) then,
  ) = __$$PeerConnectionEvent_SignallingChangeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SignalingState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_SignallingChangeImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_SignallingChangeImpl
        >
    implements _$$PeerConnectionEvent_SignallingChangeImplCopyWith<$Res> {
  __$$PeerConnectionEvent_SignallingChangeImplCopyWithImpl(
    _$PeerConnectionEvent_SignallingChangeImpl _value,
    $Res Function(_$PeerConnectionEvent_SignallingChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PeerConnectionEvent_SignallingChangeImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as SignalingState,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_SignallingChangeImpl
    extends PeerConnectionEvent_SignallingChange {
  const _$PeerConnectionEvent_SignallingChangeImpl(this.field0) : super._();

  @override
  final SignalingState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.signallingChange(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_SignallingChangeImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_SignallingChangeImplCopyWith<
    _$PeerConnectionEvent_SignallingChangeImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_SignallingChangeImplCopyWithImpl<
        _$PeerConnectionEvent_SignallingChangeImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return signallingChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return signallingChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (signallingChange != null) {
      return signallingChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return signallingChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return signallingChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (signallingChange != null) {
      return signallingChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_SignallingChange
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_SignallingChange(
    final SignalingState field0,
  ) = _$PeerConnectionEvent_SignallingChangeImpl;
  const PeerConnectionEvent_SignallingChange._() : super._();

  SignalingState get field0;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_SignallingChangeImplCopyWith<
    _$PeerConnectionEvent_SignallingChangeImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWith<
  $Res
> {
  factory _$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWith(
    _$PeerConnectionEvent_IceConnectionStateChangeImpl value,
    $Res Function(_$PeerConnectionEvent_IceConnectionStateChangeImpl) then,
  ) = __$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({IceConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_IceConnectionStateChangeImpl
        >
    implements
        _$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWith<$Res> {
  __$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWithImpl(
    _$PeerConnectionEvent_IceConnectionStateChangeImpl _value,
    $Res Function(_$PeerConnectionEvent_IceConnectionStateChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PeerConnectionEvent_IceConnectionStateChangeImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as IceConnectionState,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceConnectionStateChangeImpl
    extends PeerConnectionEvent_IceConnectionStateChange {
  const _$PeerConnectionEvent_IceConnectionStateChangeImpl(this.field0)
    : super._();

  @override
  final IceConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceConnectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceConnectionStateChangeImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWith<
    _$PeerConnectionEvent_IceConnectionStateChangeImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWithImpl<
        _$PeerConnectionEvent_IceConnectionStateChangeImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return iceConnectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return iceConnectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (iceConnectionStateChange != null) {
      return iceConnectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return iceConnectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return iceConnectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (iceConnectionStateChange != null) {
      return iceConnectionStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_IceConnectionStateChange
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_IceConnectionStateChange(
    final IceConnectionState field0,
  ) = _$PeerConnectionEvent_IceConnectionStateChangeImpl;
  const PeerConnectionEvent_IceConnectionStateChange._() : super._();

  IceConnectionState get field0;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_IceConnectionStateChangeImplCopyWith<
    _$PeerConnectionEvent_IceConnectionStateChangeImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_ConnectionStateChangeImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_ConnectionStateChangeImplCopyWith(
    _$PeerConnectionEvent_ConnectionStateChangeImpl value,
    $Res Function(_$PeerConnectionEvent_ConnectionStateChangeImpl) then,
  ) = __$$PeerConnectionEvent_ConnectionStateChangeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_ConnectionStateChangeImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<
          $Res,
          _$PeerConnectionEvent_ConnectionStateChangeImpl
        >
    implements _$$PeerConnectionEvent_ConnectionStateChangeImplCopyWith<$Res> {
  __$$PeerConnectionEvent_ConnectionStateChangeImplCopyWithImpl(
    _$PeerConnectionEvent_ConnectionStateChangeImpl _value,
    $Res Function(_$PeerConnectionEvent_ConnectionStateChangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PeerConnectionEvent_ConnectionStateChangeImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as PeerConnectionState,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_ConnectionStateChangeImpl
    extends PeerConnectionEvent_ConnectionStateChange {
  const _$PeerConnectionEvent_ConnectionStateChangeImpl(this.field0)
    : super._();

  @override
  final PeerConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.connectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_ConnectionStateChangeImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_ConnectionStateChangeImplCopyWith<
    _$PeerConnectionEvent_ConnectionStateChangeImpl
  >
  get copyWith =>
      __$$PeerConnectionEvent_ConnectionStateChangeImplCopyWithImpl<
        _$PeerConnectionEvent_ConnectionStateChangeImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return connectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return connectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (connectionStateChange != null) {
      return connectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return connectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return connectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (connectionStateChange != null) {
      return connectionStateChange(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_ConnectionStateChange
    extends PeerConnectionEvent {
  const factory PeerConnectionEvent_ConnectionStateChange(
    final PeerConnectionState field0,
  ) = _$PeerConnectionEvent_ConnectionStateChangeImpl;
  const PeerConnectionEvent_ConnectionStateChange._() : super._();

  PeerConnectionState get field0;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_ConnectionStateChangeImplCopyWith<
    _$PeerConnectionEvent_ConnectionStateChangeImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_TrackImplCopyWith<$Res> {
  factory _$$PeerConnectionEvent_TrackImplCopyWith(
    _$PeerConnectionEvent_TrackImpl value,
    $Res Function(_$PeerConnectionEvent_TrackImpl) then,
  ) = __$$PeerConnectionEvent_TrackImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class __$$PeerConnectionEvent_TrackImplCopyWithImpl<$Res>
    extends
        _$PeerConnectionEventCopyWithImpl<$Res, _$PeerConnectionEvent_TrackImpl>
    implements _$$PeerConnectionEvent_TrackImplCopyWith<$Res> {
  __$$PeerConnectionEvent_TrackImplCopyWithImpl(
    _$PeerConnectionEvent_TrackImpl _value,
    $Res Function(_$PeerConnectionEvent_TrackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PeerConnectionEvent_TrackImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as RtcTrackEvent,
      ),
    );
  }
}

/// @nodoc

class _$PeerConnectionEvent_TrackImpl extends PeerConnectionEvent_Track {
  const _$PeerConnectionEvent_TrackImpl(this.field0) : super._();

  @override
  final RtcTrackEvent field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.track(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_TrackImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeerConnectionEvent_TrackImplCopyWith<_$PeerConnectionEvent_TrackImpl>
  get copyWith =>
      __$$PeerConnectionEvent_TrackImplCopyWithImpl<
        _$PeerConnectionEvent_TrackImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ArcPeerConnection peer) peerCreated,
    required TResult Function(
      String sdpMid,
      int sdpMlineIndex,
      String candidate,
    )
    iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )
    iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
    iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return track(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ArcPeerConnection peer)? peerCreated,
    TResult? Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult? Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult? Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult? Function()? negotiationNeeded,
    TResult? Function(SignalingState field0)? signallingChange,
    TResult? Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult? Function(PeerConnectionState field0)? connectionStateChange,
    TResult? Function(RtcTrackEvent field0)? track,
  }) {
    return track?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ArcPeerConnection peer)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
    iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(
      String address,
      int port,
      String url,
      int errorCode,
      String errorText,
    )?
    iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PeerConnectionEvent_PeerCreated value)
    peerCreated,
    required TResult Function(PeerConnectionEvent_IceCandidate value)
    iceCandidate,
    required TResult Function(PeerConnectionEvent_IceGatheringStateChange value)
    iceGatheringStateChange,
    required TResult Function(PeerConnectionEvent_IceCandidateError value)
    iceCandidateError,
    required TResult Function(PeerConnectionEvent_NegotiationNeeded value)
    negotiationNeeded,
    required TResult Function(PeerConnectionEvent_SignallingChange value)
    signallingChange,
    required TResult Function(
      PeerConnectionEvent_IceConnectionStateChange value,
    )
    iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
    connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) {
    return track(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult? Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult? Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult? Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult? Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult? Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult? Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult? Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult? Function(PeerConnectionEvent_Track value)? track,
  }) {
    return track?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PeerConnectionEvent_PeerCreated value)? peerCreated,
    TResult Function(PeerConnectionEvent_IceCandidate value)? iceCandidate,
    TResult Function(PeerConnectionEvent_IceGatheringStateChange value)?
    iceGatheringStateChange,
    TResult Function(PeerConnectionEvent_IceCandidateError value)?
    iceCandidateError,
    TResult Function(PeerConnectionEvent_NegotiationNeeded value)?
    negotiationNeeded,
    TResult Function(PeerConnectionEvent_SignallingChange value)?
    signallingChange,
    TResult Function(PeerConnectionEvent_IceConnectionStateChange value)?
    iceConnectionStateChange,
    TResult Function(PeerConnectionEvent_ConnectionStateChange value)?
    connectionStateChange,
    TResult Function(PeerConnectionEvent_Track value)? track,
    required TResult orElse(),
  }) {
    if (track != null) {
      return track(this);
    }
    return orElse();
  }
}

abstract class PeerConnectionEvent_Track extends PeerConnectionEvent {
  const factory PeerConnectionEvent_Track(final RtcTrackEvent field0) =
      _$PeerConnectionEvent_TrackImpl;
  const PeerConnectionEvent_Track._() : super._();

  RtcTrackEvent get field0;

  /// Create a copy of PeerConnectionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeerConnectionEvent_TrackImplCopyWith<_$PeerConnectionEvent_TrackImpl>
  get copyWith => throw _privateConstructorUsedError;
}
