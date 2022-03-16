// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'bridge_generated.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$PeerConnectionEventTearOff {
  const _$PeerConnectionEventTearOff();

  OnIceCandidate onIceCandidate(
      {required String sdpMid,
      required int sdpMlineIndex,
      required String candidate}) {
    return OnIceCandidate(
      sdpMid: sdpMid,
      sdpMlineIndex: sdpMlineIndex,
      candidate: candidate,
    );
  }

  OnIceGatheringStateChange onIceGatheringStateChange(
      IceGatheringStateFFI field0) {
    return OnIceGatheringStateChange(
      field0,
    );
  }

  OnIceCandidateError onIceCandidateError(
      {required String address,
      required int port,
      required String url,
      required int errorCode,
      required String errorText}) {
    return OnIceCandidateError(
      address: address,
      port: port,
      url: url,
      errorCode: errorCode,
      errorText: errorText,
    );
  }

  OnNegotiationNeeded onNegotiationNeeded() {
    return const OnNegotiationNeeded();
  }

  OnSignallingChange onSignallingChange(SignalingStateFFI field0) {
    return OnSignallingChange(
      field0,
    );
  }

  OnIceConnectionStateChange onIceConnectionStateChange(
      IceConnectionStateFFI field0) {
    return OnIceConnectionStateChange(
      field0,
    );
  }

  OnConnectionStateChange onConnectionStateChange(
      PeerConnectionStateFFI field0) {
    return OnConnectionStateChange(
      field0,
    );
  }

  OnTrack onTrack() {
    return const OnTrack();
  }
}

/// @nodoc
const $PeerConnectionEvent = _$PeerConnectionEventTearOff();

/// @nodoc
mixin _$PeerConnectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEventCopyWith(
          PeerConnectionEvent value, $Res Function(PeerConnectionEvent) then) =
      _$PeerConnectionEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$PeerConnectionEventCopyWithImpl<$Res>
    implements $PeerConnectionEventCopyWith<$Res> {
  _$PeerConnectionEventCopyWithImpl(this._value, this._then);

  final PeerConnectionEvent _value;
  // ignore: unused_field
  final $Res Function(PeerConnectionEvent) _then;
}

/// @nodoc
abstract class $OnIceCandidateCopyWith<$Res> {
  factory $OnIceCandidateCopyWith(
          OnIceCandidate value, $Res Function(OnIceCandidate) then) =
      _$OnIceCandidateCopyWithImpl<$Res>;
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class _$OnIceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnIceCandidateCopyWith<$Res> {
  _$OnIceCandidateCopyWithImpl(
      OnIceCandidate _value, $Res Function(OnIceCandidate) _then)
      : super(_value, (v) => _then(v as OnIceCandidate));

  @override
  OnIceCandidate get _value => super._value as OnIceCandidate;

  @override
  $Res call({
    Object? sdpMid = freezed,
    Object? sdpMlineIndex = freezed,
    Object? candidate = freezed,
  }) {
    return _then(OnIceCandidate(
      sdpMid: sdpMid == freezed
          ? _value.sdpMid
          : sdpMid // ignore: cast_nullable_to_non_nullable
              as String,
      sdpMlineIndex: sdpMlineIndex == freezed
          ? _value.sdpMlineIndex
          : sdpMlineIndex // ignore: cast_nullable_to_non_nullable
              as int,
      candidate: candidate == freezed
          ? _value.candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$OnIceCandidate implements OnIceCandidate {
  const _$OnIceCandidate(
      {required this.sdpMid,
      required this.sdpMlineIndex,
      required this.candidate});

  @override
  final String sdpMid;
  @override
  final int sdpMlineIndex;
  @override
  final String candidate;

  @override
  String toString() {
    return 'PeerConnectionEvent.onIceCandidate(sdpMid: $sdpMid, sdpMlineIndex: $sdpMlineIndex, candidate: $candidate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnIceCandidate &&
            const DeepCollectionEquality().equals(other.sdpMid, sdpMid) &&
            const DeepCollectionEquality()
                .equals(other.sdpMlineIndex, sdpMlineIndex) &&
            const DeepCollectionEquality().equals(other.candidate, candidate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(sdpMid),
      const DeepCollectionEquality().hash(sdpMlineIndex),
      const DeepCollectionEquality().hash(candidate));

  @JsonKey(ignore: true)
  @override
  $OnIceCandidateCopyWith<OnIceCandidate> get copyWith =>
      _$OnIceCandidateCopyWithImpl<OnIceCandidate>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onIceCandidate(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onIceCandidate?.call(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onIceCandidate != null) {
      return onIceCandidate(sdpMid, sdpMlineIndex, candidate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onIceCandidate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onIceCandidate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onIceCandidate != null) {
      return onIceCandidate(this);
    }
    return orElse();
  }
}

abstract class OnIceCandidate implements PeerConnectionEvent {
  const factory OnIceCandidate(
      {required String sdpMid,
      required int sdpMlineIndex,
      required String candidate}) = _$OnIceCandidate;

  String get sdpMid;
  int get sdpMlineIndex;
  String get candidate;
  @JsonKey(ignore: true)
  $OnIceCandidateCopyWith<OnIceCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnIceGatheringStateChangeCopyWith<$Res> {
  factory $OnIceGatheringStateChangeCopyWith(OnIceGatheringStateChange value,
          $Res Function(OnIceGatheringStateChange) then) =
      _$OnIceGatheringStateChangeCopyWithImpl<$Res>;
  $Res call({IceGatheringStateFFI field0});
}

/// @nodoc
class _$OnIceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnIceGatheringStateChangeCopyWith<$Res> {
  _$OnIceGatheringStateChangeCopyWithImpl(OnIceGatheringStateChange _value,
      $Res Function(OnIceGatheringStateChange) _then)
      : super(_value, (v) => _then(v as OnIceGatheringStateChange));

  @override
  OnIceGatheringStateChange get _value =>
      super._value as OnIceGatheringStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(OnIceGatheringStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceGatheringStateFFI,
    ));
  }
}

/// @nodoc

class _$OnIceGatheringStateChange implements OnIceGatheringStateChange {
  const _$OnIceGatheringStateChange(this.field0);

  @override
  final IceGatheringStateFFI field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.onIceGatheringStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnIceGatheringStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $OnIceGatheringStateChangeCopyWith<OnIceGatheringStateChange> get copyWith =>
      _$OnIceGatheringStateChangeCopyWithImpl<OnIceGatheringStateChange>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onIceGatheringStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onIceGatheringStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onIceGatheringStateChange != null) {
      return onIceGatheringStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onIceGatheringStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onIceGatheringStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onIceGatheringStateChange != null) {
      return onIceGatheringStateChange(this);
    }
    return orElse();
  }
}

abstract class OnIceGatheringStateChange implements PeerConnectionEvent {
  const factory OnIceGatheringStateChange(IceGatheringStateFFI field0) =
      _$OnIceGatheringStateChange;

  IceGatheringStateFFI get field0;
  @JsonKey(ignore: true)
  $OnIceGatheringStateChangeCopyWith<OnIceGatheringStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnIceCandidateErrorCopyWith<$Res> {
  factory $OnIceCandidateErrorCopyWith(
          OnIceCandidateError value, $Res Function(OnIceCandidateError) then) =
      _$OnIceCandidateErrorCopyWithImpl<$Res>;
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class _$OnIceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnIceCandidateErrorCopyWith<$Res> {
  _$OnIceCandidateErrorCopyWithImpl(
      OnIceCandidateError _value, $Res Function(OnIceCandidateError) _then)
      : super(_value, (v) => _then(v as OnIceCandidateError));

  @override
  OnIceCandidateError get _value => super._value as OnIceCandidateError;

  @override
  $Res call({
    Object? address = freezed,
    Object? port = freezed,
    Object? url = freezed,
    Object? errorCode = freezed,
    Object? errorText = freezed,
  }) {
    return _then(OnIceCandidateError(
      address: address == freezed
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      port: port == freezed
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: errorCode == freezed
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as int,
      errorText: errorText == freezed
          ? _value.errorText
          : errorText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$OnIceCandidateError implements OnIceCandidateError {
  const _$OnIceCandidateError(
      {required this.address,
      required this.port,
      required this.url,
      required this.errorCode,
      required this.errorText});

  @override
  final String address;
  @override
  final int port;
  @override
  final String url;
  @override
  final int errorCode;
  @override
  final String errorText;

  @override
  String toString() {
    return 'PeerConnectionEvent.onIceCandidateError(address: $address, port: $port, url: $url, errorCode: $errorCode, errorText: $errorText)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnIceCandidateError &&
            const DeepCollectionEquality().equals(other.address, address) &&
            const DeepCollectionEquality().equals(other.port, port) &&
            const DeepCollectionEquality().equals(other.url, url) &&
            const DeepCollectionEquality().equals(other.errorCode, errorCode) &&
            const DeepCollectionEquality().equals(other.errorText, errorText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(address),
      const DeepCollectionEquality().hash(port),
      const DeepCollectionEquality().hash(url),
      const DeepCollectionEquality().hash(errorCode),
      const DeepCollectionEquality().hash(errorText));

  @JsonKey(ignore: true)
  @override
  $OnIceCandidateErrorCopyWith<OnIceCandidateError> get copyWith =>
      _$OnIceCandidateErrorCopyWithImpl<OnIceCandidateError>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onIceCandidateError(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onIceCandidateError?.call(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onIceCandidateError != null) {
      return onIceCandidateError(address, port, url, errorCode, errorText);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onIceCandidateError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onIceCandidateError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onIceCandidateError != null) {
      return onIceCandidateError(this);
    }
    return orElse();
  }
}

abstract class OnIceCandidateError implements PeerConnectionEvent {
  const factory OnIceCandidateError(
      {required String address,
      required int port,
      required String url,
      required int errorCode,
      required String errorText}) = _$OnIceCandidateError;

  String get address;
  int get port;
  String get url;
  int get errorCode;
  String get errorText;
  @JsonKey(ignore: true)
  $OnIceCandidateErrorCopyWith<OnIceCandidateError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnNegotiationNeededCopyWith<$Res> {
  factory $OnNegotiationNeededCopyWith(
          OnNegotiationNeeded value, $Res Function(OnNegotiationNeeded) then) =
      _$OnNegotiationNeededCopyWithImpl<$Res>;
}

/// @nodoc
class _$OnNegotiationNeededCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnNegotiationNeededCopyWith<$Res> {
  _$OnNegotiationNeededCopyWithImpl(
      OnNegotiationNeeded _value, $Res Function(OnNegotiationNeeded) _then)
      : super(_value, (v) => _then(v as OnNegotiationNeeded));

  @override
  OnNegotiationNeeded get _value => super._value as OnNegotiationNeeded;
}

/// @nodoc

class _$OnNegotiationNeeded implements OnNegotiationNeeded {
  const _$OnNegotiationNeeded();

  @override
  String toString() {
    return 'PeerConnectionEvent.onNegotiationNeeded()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OnNegotiationNeeded);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onNegotiationNeeded();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onNegotiationNeeded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onNegotiationNeeded != null) {
      return onNegotiationNeeded();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onNegotiationNeeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onNegotiationNeeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onNegotiationNeeded != null) {
      return onNegotiationNeeded(this);
    }
    return orElse();
  }
}

abstract class OnNegotiationNeeded implements PeerConnectionEvent {
  const factory OnNegotiationNeeded() = _$OnNegotiationNeeded;
}

/// @nodoc
abstract class $OnSignallingChangeCopyWith<$Res> {
  factory $OnSignallingChangeCopyWith(
          OnSignallingChange value, $Res Function(OnSignallingChange) then) =
      _$OnSignallingChangeCopyWithImpl<$Res>;
  $Res call({SignalingStateFFI field0});
}

/// @nodoc
class _$OnSignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnSignallingChangeCopyWith<$Res> {
  _$OnSignallingChangeCopyWithImpl(
      OnSignallingChange _value, $Res Function(OnSignallingChange) _then)
      : super(_value, (v) => _then(v as OnSignallingChange));

  @override
  OnSignallingChange get _value => super._value as OnSignallingChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(OnSignallingChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SignalingStateFFI,
    ));
  }
}

/// @nodoc

class _$OnSignallingChange implements OnSignallingChange {
  const _$OnSignallingChange(this.field0);

  @override
  final SignalingStateFFI field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.onSignallingChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnSignallingChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $OnSignallingChangeCopyWith<OnSignallingChange> get copyWith =>
      _$OnSignallingChangeCopyWithImpl<OnSignallingChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onSignallingChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onSignallingChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onSignallingChange != null) {
      return onSignallingChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onSignallingChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onSignallingChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onSignallingChange != null) {
      return onSignallingChange(this);
    }
    return orElse();
  }
}

abstract class OnSignallingChange implements PeerConnectionEvent {
  const factory OnSignallingChange(SignalingStateFFI field0) =
      _$OnSignallingChange;

  SignalingStateFFI get field0;
  @JsonKey(ignore: true)
  $OnSignallingChangeCopyWith<OnSignallingChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnIceConnectionStateChangeCopyWith<$Res> {
  factory $OnIceConnectionStateChangeCopyWith(OnIceConnectionStateChange value,
          $Res Function(OnIceConnectionStateChange) then) =
      _$OnIceConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({IceConnectionStateFFI field0});
}

/// @nodoc
class _$OnIceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnIceConnectionStateChangeCopyWith<$Res> {
  _$OnIceConnectionStateChangeCopyWithImpl(OnIceConnectionStateChange _value,
      $Res Function(OnIceConnectionStateChange) _then)
      : super(_value, (v) => _then(v as OnIceConnectionStateChange));

  @override
  OnIceConnectionStateChange get _value =>
      super._value as OnIceConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(OnIceConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceConnectionStateFFI,
    ));
  }
}

/// @nodoc

class _$OnIceConnectionStateChange implements OnIceConnectionStateChange {
  const _$OnIceConnectionStateChange(this.field0);

  @override
  final IceConnectionStateFFI field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.onIceConnectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnIceConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $OnIceConnectionStateChangeCopyWith<OnIceConnectionStateChange>
      get copyWith =>
          _$OnIceConnectionStateChangeCopyWithImpl<OnIceConnectionStateChange>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onIceConnectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onIceConnectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onIceConnectionStateChange != null) {
      return onIceConnectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onIceConnectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onIceConnectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onIceConnectionStateChange != null) {
      return onIceConnectionStateChange(this);
    }
    return orElse();
  }
}

abstract class OnIceConnectionStateChange implements PeerConnectionEvent {
  const factory OnIceConnectionStateChange(IceConnectionStateFFI field0) =
      _$OnIceConnectionStateChange;

  IceConnectionStateFFI get field0;
  @JsonKey(ignore: true)
  $OnIceConnectionStateChangeCopyWith<OnIceConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnConnectionStateChangeCopyWith<$Res> {
  factory $OnConnectionStateChangeCopyWith(OnConnectionStateChange value,
          $Res Function(OnConnectionStateChange) then) =
      _$OnConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({PeerConnectionStateFFI field0});
}

/// @nodoc
class _$OnConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnConnectionStateChangeCopyWith<$Res> {
  _$OnConnectionStateChangeCopyWithImpl(OnConnectionStateChange _value,
      $Res Function(OnConnectionStateChange) _then)
      : super(_value, (v) => _then(v as OnConnectionStateChange));

  @override
  OnConnectionStateChange get _value => super._value as OnConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(OnConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PeerConnectionStateFFI,
    ));
  }
}

/// @nodoc

class _$OnConnectionStateChange implements OnConnectionStateChange {
  const _$OnConnectionStateChange(this.field0);

  @override
  final PeerConnectionStateFFI field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.onConnectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  $OnConnectionStateChangeCopyWith<OnConnectionStateChange> get copyWith =>
      _$OnConnectionStateChangeCopyWithImpl<OnConnectionStateChange>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onConnectionStateChange(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onConnectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onConnectionStateChange != null) {
      return onConnectionStateChange(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onConnectionStateChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onConnectionStateChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onConnectionStateChange != null) {
      return onConnectionStateChange(this);
    }
    return orElse();
  }
}

abstract class OnConnectionStateChange implements PeerConnectionEvent {
  const factory OnConnectionStateChange(PeerConnectionStateFFI field0) =
      _$OnConnectionStateChange;

  PeerConnectionStateFFI get field0;
  @JsonKey(ignore: true)
  $OnConnectionStateChangeCopyWith<OnConnectionStateChange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnTrackCopyWith<$Res> {
  factory $OnTrackCopyWith(OnTrack value, $Res Function(OnTrack) then) =
      _$OnTrackCopyWithImpl<$Res>;
}

/// @nodoc
class _$OnTrackCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements $OnTrackCopyWith<$Res> {
  _$OnTrackCopyWithImpl(OnTrack _value, $Res Function(OnTrack) _then)
      : super(_value, (v) => _then(v as OnTrack));

  @override
  OnTrack get _value => super._value as OnTrack;
}

/// @nodoc

class _$OnTrack implements OnTrack {
  const _$OnTrack();

  @override
  String toString() {
    return 'PeerConnectionEvent.onTrack()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OnTrack);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        onIceCandidate,
    required TResult Function(IceGatheringStateFFI field0)
        onIceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        onIceCandidateError,
    required TResult Function() onNegotiationNeeded,
    required TResult Function(SignalingStateFFI field0) onSignallingChange,
    required TResult Function(IceConnectionStateFFI field0)
        onIceConnectionStateChange,
    required TResult Function(PeerConnectionStateFFI field0)
        onConnectionStateChange,
    required TResult Function() onTrack,
  }) {
    return onTrack();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
  }) {
    return onTrack?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        onIceCandidate,
    TResult Function(IceGatheringStateFFI field0)? onIceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        onIceCandidateError,
    TResult Function()? onNegotiationNeeded,
    TResult Function(SignalingStateFFI field0)? onSignallingChange,
    TResult Function(IceConnectionStateFFI field0)? onIceConnectionStateChange,
    TResult Function(PeerConnectionStateFFI field0)? onConnectionStateChange,
    TResult Function()? onTrack,
    required TResult orElse(),
  }) {
    if (onTrack != null) {
      return onTrack();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OnIceCandidate value) onIceCandidate,
    required TResult Function(OnIceGatheringStateChange value)
        onIceGatheringStateChange,
    required TResult Function(OnIceCandidateError value) onIceCandidateError,
    required TResult Function(OnNegotiationNeeded value) onNegotiationNeeded,
    required TResult Function(OnSignallingChange value) onSignallingChange,
    required TResult Function(OnIceConnectionStateChange value)
        onIceConnectionStateChange,
    required TResult Function(OnConnectionStateChange value)
        onConnectionStateChange,
    required TResult Function(OnTrack value) onTrack,
  }) {
    return onTrack(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
  }) {
    return onTrack?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OnIceCandidate value)? onIceCandidate,
    TResult Function(OnIceGatheringStateChange value)?
        onIceGatheringStateChange,
    TResult Function(OnIceCandidateError value)? onIceCandidateError,
    TResult Function(OnNegotiationNeeded value)? onNegotiationNeeded,
    TResult Function(OnSignallingChange value)? onSignallingChange,
    TResult Function(OnIceConnectionStateChange value)?
        onIceConnectionStateChange,
    TResult Function(OnConnectionStateChange value)? onConnectionStateChange,
    TResult Function(OnTrack value)? onTrack,
    required TResult orElse(),
  }) {
    if (onTrack != null) {
      return onTrack(this);
    }
    return orElse();
  }
}

abstract class OnTrack implements PeerConnectionEvent {
  const factory OnTrack() = _$OnTrack;
}
