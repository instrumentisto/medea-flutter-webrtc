// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'bridge.g.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GetMediaError {
  String get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GetMediaErrorCopyWith<GetMediaError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaErrorCopyWith(
          GetMediaError value, $Res Function(GetMediaError) then) =
      _$GetMediaErrorCopyWithImpl<$Res>;
  $Res call({String field0});
}

/// @nodoc
class _$GetMediaErrorCopyWithImpl<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  _$GetMediaErrorCopyWithImpl(this._value, this._then);

  final GetMediaError _value;
  // ignore: unused_field
  final $Res Function(GetMediaError) _then;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_value.copyWith(
      field0: field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$GetMediaError_AudioCopyWith<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  factory _$$GetMediaError_AudioCopyWith(_$GetMediaError_Audio value,
          $Res Function(_$GetMediaError_Audio) then) =
      __$$GetMediaError_AudioCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_AudioCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$GetMediaError_AudioCopyWith<$Res> {
  __$$GetMediaError_AudioCopyWithImpl(
      _$GetMediaError_Audio _value, $Res Function(_$GetMediaError_Audio) _then)
      : super(_value, (v) => _then(v as _$GetMediaError_Audio));

  @override
  _$GetMediaError_Audio get _value => super._value as _$GetMediaError_Audio;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaError_Audio(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMediaError_Audio implements GetMediaError_Audio {
  const _$GetMediaError_Audio(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'GetMediaError.audio(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaError_Audio &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$GetMediaError_AudioCopyWith<_$GetMediaError_Audio> get copyWith =>
      __$$GetMediaError_AudioCopyWithImpl<_$GetMediaError_Audio>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) {
    return audio(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
  }) {
    return audio?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class GetMediaError_Audio implements GetMediaError {
  const factory GetMediaError_Audio(final String field0) =
      _$GetMediaError_Audio;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$GetMediaError_AudioCopyWith<_$GetMediaError_Audio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMediaError_VideoCopyWith<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  factory _$$GetMediaError_VideoCopyWith(_$GetMediaError_Video value,
          $Res Function(_$GetMediaError_Video) then) =
      __$$GetMediaError_VideoCopyWithImpl<$Res>;
  @override
  $Res call({String field0});
}

/// @nodoc
class __$$GetMediaError_VideoCopyWithImpl<$Res>
    extends _$GetMediaErrorCopyWithImpl<$Res>
    implements _$$GetMediaError_VideoCopyWith<$Res> {
  __$$GetMediaError_VideoCopyWithImpl(
      _$GetMediaError_Video _value, $Res Function(_$GetMediaError_Video) _then)
      : super(_value, (v) => _then(v as _$GetMediaError_Video));

  @override
  _$GetMediaError_Video get _value => super._value as _$GetMediaError_Video;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaError_Video(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMediaError_Video implements GetMediaError_Video {
  const _$GetMediaError_Video(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'GetMediaError.video(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaError_Video &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$GetMediaError_VideoCopyWith<_$GetMediaError_Video> get copyWith =>
      __$$GetMediaError_VideoCopyWithImpl<_$GetMediaError_Video>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) audio,
    required TResult Function(String field0) video,
  }) {
    return video(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
  }) {
    return video?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? audio,
    TResult Function(String field0)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaError_Audio value) audio,
    required TResult Function(GetMediaError_Video value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaError_Audio value)? audio,
    TResult Function(GetMediaError_Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class GetMediaError_Video implements GetMediaError {
  const factory GetMediaError_Video(final String field0) =
      _$GetMediaError_Video;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$GetMediaError_VideoCopyWith<_$GetMediaError_Video> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GetMediaResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResultCopyWith(
          GetMediaResult value, $Res Function(GetMediaResult) then) =
      _$GetMediaResultCopyWithImpl<$Res>;
}

/// @nodoc
class _$GetMediaResultCopyWithImpl<$Res>
    implements $GetMediaResultCopyWith<$Res> {
  _$GetMediaResultCopyWithImpl(this._value, this._then);

  final GetMediaResult _value;
  // ignore: unused_field
  final $Res Function(GetMediaResult) _then;
}

/// @nodoc
abstract class _$$GetMediaResult_OkCopyWith<$Res> {
  factory _$$GetMediaResult_OkCopyWith(
          _$GetMediaResult_Ok value, $Res Function(_$GetMediaResult_Ok) then) =
      __$$GetMediaResult_OkCopyWithImpl<$Res>;
  $Res call({List<MediaStreamTrack> field0});
}

/// @nodoc
class __$$GetMediaResult_OkCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$GetMediaResult_OkCopyWith<$Res> {
  __$$GetMediaResult_OkCopyWithImpl(
      _$GetMediaResult_Ok _value, $Res Function(_$GetMediaResult_Ok) _then)
      : super(_value, (v) => _then(v as _$GetMediaResult_Ok));

  @override
  _$GetMediaResult_Ok get _value => super._value as _$GetMediaResult_Ok;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaResult_Ok(
      field0 == freezed
          ? _value._field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as List<MediaStreamTrack>,
    ));
  }
}

/// @nodoc

class _$GetMediaResult_Ok implements GetMediaResult_Ok {
  const _$GetMediaResult_Ok(final List<MediaStreamTrack> field0)
      : _field0 = field0;

  final List<MediaStreamTrack> _field0;
  @override
  List<MediaStreamTrack> get field0 {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field0);
  }

  @override
  String toString() {
    return 'GetMediaResult.ok(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaResult_Ok &&
            const DeepCollectionEquality().equals(other._field0, _field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_field0));

  @JsonKey(ignore: true)
  @override
  _$$GetMediaResult_OkCopyWith<_$GetMediaResult_Ok> get copyWith =>
      __$$GetMediaResult_OkCopyWithImpl<_$GetMediaResult_Ok>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) {
    return ok(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
  }) {
    return ok?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) {
    return ok(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
  }) {
    return ok?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(this);
    }
    return orElse();
  }
}

abstract class GetMediaResult_Ok implements GetMediaResult {
  const factory GetMediaResult_Ok(final List<MediaStreamTrack> field0) =
      _$GetMediaResult_Ok;

  List<MediaStreamTrack> get field0;
  @JsonKey(ignore: true)
  _$$GetMediaResult_OkCopyWith<_$GetMediaResult_Ok> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMediaResult_ErrCopyWith<$Res> {
  factory _$$GetMediaResult_ErrCopyWith(_$GetMediaResult_Err value,
          $Res Function(_$GetMediaResult_Err) then) =
      __$$GetMediaResult_ErrCopyWithImpl<$Res>;
  $Res call({GetMediaError field0});

  $GetMediaErrorCopyWith<$Res> get field0;
}

/// @nodoc
class __$$GetMediaResult_ErrCopyWithImpl<$Res>
    extends _$GetMediaResultCopyWithImpl<$Res>
    implements _$$GetMediaResult_ErrCopyWith<$Res> {
  __$$GetMediaResult_ErrCopyWithImpl(
      _$GetMediaResult_Err _value, $Res Function(_$GetMediaResult_Err) _then)
      : super(_value, (v) => _then(v as _$GetMediaResult_Err));

  @override
  _$GetMediaResult_Err get _value => super._value as _$GetMediaResult_Err;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$GetMediaResult_Err(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as GetMediaError,
    ));
  }

  @override
  $GetMediaErrorCopyWith<$Res> get field0 {
    return $GetMediaErrorCopyWith<$Res>(_value.field0, (value) {
      return _then(_value.copyWith(field0: value));
    });
  }
}

/// @nodoc

class _$GetMediaResult_Err implements GetMediaResult_Err {
  const _$GetMediaResult_Err(this.field0);

  @override
  final GetMediaError field0;

  @override
  String toString() {
    return 'GetMediaResult.err(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMediaResult_Err &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$GetMediaResult_ErrCopyWith<_$GetMediaResult_Err> get copyWith =>
      __$$GetMediaResult_ErrCopyWithImpl<_$GetMediaResult_Err>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MediaStreamTrack> field0) ok,
    required TResult Function(GetMediaError field0) err,
  }) {
    return err(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
  }) {
    return err?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MediaStreamTrack> field0)? ok,
    TResult Function(GetMediaError field0)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GetMediaResult_Ok value) ok,
    required TResult Function(GetMediaResult_Err value) err,
  }) {
    return err(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
  }) {
    return err?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GetMediaResult_Ok value)? ok,
    TResult Function(GetMediaResult_Err value)? err,
    required TResult orElse(),
  }) {
    if (err != null) {
      return err(this);
    }
    return orElse();
  }
}

abstract class GetMediaResult_Err implements GetMediaResult {
  const factory GetMediaResult_Err(final GetMediaError field0) =
      _$GetMediaResult_Err;

  GetMediaError get field0;
  @JsonKey(ignore: true)
  _$$GetMediaResult_ErrCopyWith<_$GetMediaResult_Err> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PeerConnectionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
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
            PeerConnectionEvent_IceConnectionStateChange value)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionEvent_ConnectionStateChange value)
        connectionStateChange,
    required TResult Function(PeerConnectionEvent_Track value) track,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
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
  }) =>
      throw _privateConstructorUsedError;
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
abstract class _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  factory _$$PeerConnectionEvent_PeerCreatedCopyWith(
          _$PeerConnectionEvent_PeerCreated value,
          $Res Function(_$PeerConnectionEvent_PeerCreated) then) =
      __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>;
  $Res call({int id});
}

/// @nodoc
class __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  __$$PeerConnectionEvent_PeerCreatedCopyWithImpl(
      _$PeerConnectionEvent_PeerCreated _value,
      $Res Function(_$PeerConnectionEvent_PeerCreated) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_PeerCreated));

  @override
  _$PeerConnectionEvent_PeerCreated get _value =>
      super._value as _$PeerConnectionEvent_PeerCreated;

  @override
  $Res call({
    Object? id = freezed,
  }) {
    return _then(_$PeerConnectionEvent_PeerCreated(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_PeerCreated
    implements PeerConnectionEvent_PeerCreated {
  const _$PeerConnectionEvent_PeerCreated({required this.id});

  /// ID of the created [`PeerConnection`].
  @override
  final int id;

  @override
  String toString() {
    return 'PeerConnectionEvent.peerCreated(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_PeerCreated &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_PeerCreatedCopyWith<_$PeerConnectionEvent_PeerCreated>
      get copyWith => __$$PeerConnectionEvent_PeerCreatedCopyWithImpl<
          _$PeerConnectionEvent_PeerCreated>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
        iceCandidateError,
    required TResult Function() negotiationNeeded,
    required TResult Function(SignalingState field0) signallingChange,
    required TResult Function(IceConnectionState field0)
        iceConnectionStateChange,
    required TResult Function(PeerConnectionState field0) connectionStateChange,
    required TResult Function(RtcTrackEvent field0) track,
  }) {
    return peerCreated(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return peerCreated?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
    required TResult orElse(),
  }) {
    if (peerCreated != null) {
      return peerCreated(id);
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
            PeerConnectionEvent_IceConnectionStateChange value)
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

abstract class PeerConnectionEvent_PeerCreated implements PeerConnectionEvent {
  const factory PeerConnectionEvent_PeerCreated({required final int id}) =
      _$PeerConnectionEvent_PeerCreated;

  /// ID of the created [`PeerConnection`].
  int get id;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_PeerCreatedCopyWith<_$PeerConnectionEvent_PeerCreated>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateCopyWith(
          _$PeerConnectionEvent_IceCandidate value,
          $Res Function(_$PeerConnectionEvent_IceCandidate) then) =
      __$$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>;
  $Res call({String sdpMid, int sdpMlineIndex, String candidate});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateCopyWithImpl(
      _$PeerConnectionEvent_IceCandidate _value,
      $Res Function(_$PeerConnectionEvent_IceCandidate) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_IceCandidate));

  @override
  _$PeerConnectionEvent_IceCandidate get _value =>
      super._value as _$PeerConnectionEvent_IceCandidate;

  @override
  $Res call({
    Object? sdpMid = freezed,
    Object? sdpMlineIndex = freezed,
    Object? candidate = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidate(
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

class _$PeerConnectionEvent_IceCandidate
    implements PeerConnectionEvent_IceCandidate {
  const _$PeerConnectionEvent_IceCandidate(
      {required this.sdpMid,
      required this.sdpMlineIndex,
      required this.candidate});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidate &&
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
  _$$PeerConnectionEvent_IceCandidateCopyWith<
          _$PeerConnectionEvent_IceCandidate>
      get copyWith => __$$PeerConnectionEvent_IceCandidateCopyWithImpl<
          _$PeerConnectionEvent_IceCandidate>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidate?.call(sdpMid, sdpMlineIndex, candidate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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

abstract class PeerConnectionEvent_IceCandidate implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidate(
      {required final String sdpMid,
      required final int sdpMlineIndex,
      required final String candidate}) = _$PeerConnectionEvent_IceCandidate;

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
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceCandidateCopyWith<
          _$PeerConnectionEvent_IceCandidate>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith(
          _$PeerConnectionEvent_IceGatheringStateChange value,
          $Res Function(_$PeerConnectionEvent_IceGatheringStateChange) then) =
      __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>;
  $Res call({IceGatheringState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceGatheringStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceGatheringStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_IceGatheringStateChange));

  @override
  _$PeerConnectionEvent_IceGatheringStateChange get _value =>
      super._value as _$PeerConnectionEvent_IceGatheringStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceGatheringStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceGatheringState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceGatheringStateChange
    implements PeerConnectionEvent_IceGatheringStateChange {
  const _$PeerConnectionEvent_IceGatheringStateChange(this.field0);

  @override
  final IceGatheringState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceGatheringStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceGatheringStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<
          _$PeerConnectionEvent_IceGatheringStateChange>
      get copyWith =>
          __$$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<
              _$PeerConnectionEvent_IceGatheringStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return iceGatheringStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceGatheringStateChange(
          final IceGatheringState field0) =
      _$PeerConnectionEvent_IceGatheringStateChange;

  IceGatheringState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceGatheringStateChangeCopyWith<
          _$PeerConnectionEvent_IceGatheringStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceCandidateErrorCopyWith(
          _$PeerConnectionEvent_IceCandidateError value,
          $Res Function(_$PeerConnectionEvent_IceCandidateError) then) =
      __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>;
  $Res call(
      {String address, int port, String url, int errorCode, String errorText});
}

/// @nodoc
class __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl(
      _$PeerConnectionEvent_IceCandidateError _value,
      $Res Function(_$PeerConnectionEvent_IceCandidateError) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_IceCandidateError));

  @override
  _$PeerConnectionEvent_IceCandidateError get _value =>
      super._value as _$PeerConnectionEvent_IceCandidateError;

  @override
  $Res call({
    Object? address = freezed,
    Object? port = freezed,
    Object? url = freezed,
    Object? errorCode = freezed,
    Object? errorText = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceCandidateError(
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

class _$PeerConnectionEvent_IceCandidateError
    implements PeerConnectionEvent_IceCandidateError {
  const _$PeerConnectionEvent_IceCandidateError(
      {required this.address,
      required this.port,
      required this.url,
      required this.errorCode,
      required this.errorText});

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceCandidateError &&
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
  _$$PeerConnectionEvent_IceCandidateErrorCopyWith<
          _$PeerConnectionEvent_IceCandidateError>
      get copyWith => __$$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<
          _$PeerConnectionEvent_IceCandidateError>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return iceCandidateError?.call(address, port, url, errorCode, errorText);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceCandidateError(
          {required final String address,
          required final int port,
          required final String url,
          required final int errorCode,
          required final String errorText}) =
      _$PeerConnectionEvent_IceCandidateError;

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
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceCandidateErrorCopyWith<
          _$PeerConnectionEvent_IceCandidateError>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_NegotiationNeededCopyWith<$Res> {
  factory _$$PeerConnectionEvent_NegotiationNeededCopyWith(
          _$PeerConnectionEvent_NegotiationNeeded value,
          $Res Function(_$PeerConnectionEvent_NegotiationNeeded) then) =
      __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_NegotiationNeededCopyWith<$Res> {
  __$$PeerConnectionEvent_NegotiationNeededCopyWithImpl(
      _$PeerConnectionEvent_NegotiationNeeded _value,
      $Res Function(_$PeerConnectionEvent_NegotiationNeeded) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_NegotiationNeeded));

  @override
  _$PeerConnectionEvent_NegotiationNeeded get _value =>
      super._value as _$PeerConnectionEvent_NegotiationNeeded;
}

/// @nodoc

class _$PeerConnectionEvent_NegotiationNeeded
    implements PeerConnectionEvent_NegotiationNeeded {
  const _$PeerConnectionEvent_NegotiationNeeded();

  @override
  String toString() {
    return 'PeerConnectionEvent.negotiationNeeded()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_NegotiationNeeded);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return negotiationNeeded?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_NegotiationNeeded() =
      _$PeerConnectionEvent_NegotiationNeeded;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_SignallingChangeCopyWith(
          _$PeerConnectionEvent_SignallingChange value,
          $Res Function(_$PeerConnectionEvent_SignallingChange) then) =
      __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>;
  $Res call({SignalingState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_SignallingChangeCopyWithImpl(
      _$PeerConnectionEvent_SignallingChange _value,
      $Res Function(_$PeerConnectionEvent_SignallingChange) _then)
      : super(
            _value, (v) => _then(v as _$PeerConnectionEvent_SignallingChange));

  @override
  _$PeerConnectionEvent_SignallingChange get _value =>
      super._value as _$PeerConnectionEvent_SignallingChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_SignallingChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SignalingState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_SignallingChange
    implements PeerConnectionEvent_SignallingChange {
  const _$PeerConnectionEvent_SignallingChange(this.field0);

  @override
  final SignalingState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.signallingChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_SignallingChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_SignallingChangeCopyWith<
          _$PeerConnectionEvent_SignallingChange>
      get copyWith => __$$PeerConnectionEvent_SignallingChangeCopyWithImpl<
          _$PeerConnectionEvent_SignallingChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return signallingChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_SignallingChange(
      final SignalingState field0) = _$PeerConnectionEvent_SignallingChange;

  SignalingState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_SignallingChangeCopyWith<
          _$PeerConnectionEvent_SignallingChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith(
          _$PeerConnectionEvent_IceConnectionStateChange value,
          $Res Function(_$PeerConnectionEvent_IceConnectionStateChange) then) =
      __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({IceConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_IceConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_IceConnectionStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_IceConnectionStateChange));

  @override
  _$PeerConnectionEvent_IceConnectionStateChange get _value =>
      super._value as _$PeerConnectionEvent_IceConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_IceConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as IceConnectionState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_IceConnectionStateChange
    implements PeerConnectionEvent_IceConnectionStateChange {
  const _$PeerConnectionEvent_IceConnectionStateChange(this.field0);

  @override
  final IceConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.iceConnectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_IceConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_IceConnectionStateChange>
      get copyWith =>
          __$$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<
              _$PeerConnectionEvent_IceConnectionStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return iceConnectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_IceConnectionStateChange(
          final IceConnectionState field0) =
      _$PeerConnectionEvent_IceConnectionStateChange;

  IceConnectionState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_IceConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_IceConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  factory _$$PeerConnectionEvent_ConnectionStateChangeCopyWith(
          _$PeerConnectionEvent_ConnectionStateChange value,
          $Res Function(_$PeerConnectionEvent_ConnectionStateChange) then) =
      __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>;
  $Res call({PeerConnectionState field0});
}

/// @nodoc
class __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl(
      _$PeerConnectionEvent_ConnectionStateChange _value,
      $Res Function(_$PeerConnectionEvent_ConnectionStateChange) _then)
      : super(_value,
            (v) => _then(v as _$PeerConnectionEvent_ConnectionStateChange));

  @override
  _$PeerConnectionEvent_ConnectionStateChange get _value =>
      super._value as _$PeerConnectionEvent_ConnectionStateChange;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_ConnectionStateChange(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PeerConnectionState,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_ConnectionStateChange
    implements PeerConnectionEvent_ConnectionStateChange {
  const _$PeerConnectionEvent_ConnectionStateChange(this.field0);

  @override
  final PeerConnectionState field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.connectionStateChange(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_ConnectionStateChange &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_ConnectionStateChange>
      get copyWith => __$$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<
          _$PeerConnectionEvent_ConnectionStateChange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return connectionStateChange?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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
    implements PeerConnectionEvent {
  const factory PeerConnectionEvent_ConnectionStateChange(
          final PeerConnectionState field0) =
      _$PeerConnectionEvent_ConnectionStateChange;

  PeerConnectionState get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_ConnectionStateChangeCopyWith<
          _$PeerConnectionEvent_ConnectionStateChange>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PeerConnectionEvent_TrackCopyWith<$Res> {
  factory _$$PeerConnectionEvent_TrackCopyWith(
          _$PeerConnectionEvent_Track value,
          $Res Function(_$PeerConnectionEvent_Track) then) =
      __$$PeerConnectionEvent_TrackCopyWithImpl<$Res>;
  $Res call({RtcTrackEvent field0});
}

/// @nodoc
class __$$PeerConnectionEvent_TrackCopyWithImpl<$Res>
    extends _$PeerConnectionEventCopyWithImpl<$Res>
    implements _$$PeerConnectionEvent_TrackCopyWith<$Res> {
  __$$PeerConnectionEvent_TrackCopyWithImpl(_$PeerConnectionEvent_Track _value,
      $Res Function(_$PeerConnectionEvent_Track) _then)
      : super(_value, (v) => _then(v as _$PeerConnectionEvent_Track));

  @override
  _$PeerConnectionEvent_Track get _value =>
      super._value as _$PeerConnectionEvent_Track;

  @override
  $Res call({
    Object? field0 = freezed,
  }) {
    return _then(_$PeerConnectionEvent_Track(
      field0 == freezed
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RtcTrackEvent,
    ));
  }
}

/// @nodoc

class _$PeerConnectionEvent_Track implements PeerConnectionEvent_Track {
  const _$PeerConnectionEvent_Track(this.field0);

  @override
  final RtcTrackEvent field0;

  @override
  String toString() {
    return 'PeerConnectionEvent.track(field0: $field0)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeerConnectionEvent_Track &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @JsonKey(ignore: true)
  @override
  _$$PeerConnectionEvent_TrackCopyWith<_$PeerConnectionEvent_Track>
      get copyWith => __$$PeerConnectionEvent_TrackCopyWithImpl<
          _$PeerConnectionEvent_Track>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int id) peerCreated,
    required TResult Function(
            String sdpMid, int sdpMlineIndex, String candidate)
        iceCandidate,
    required TResult Function(IceGatheringState field0) iceGatheringStateChange,
    required TResult Function(String address, int port, String url,
            int errorCode, String errorText)
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
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
        iceCandidateError,
    TResult Function()? negotiationNeeded,
    TResult Function(SignalingState field0)? signallingChange,
    TResult Function(IceConnectionState field0)? iceConnectionStateChange,
    TResult Function(PeerConnectionState field0)? connectionStateChange,
    TResult Function(RtcTrackEvent field0)? track,
  }) {
    return track?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int id)? peerCreated,
    TResult Function(String sdpMid, int sdpMlineIndex, String candidate)?
        iceCandidate,
    TResult Function(IceGatheringState field0)? iceGatheringStateChange,
    TResult Function(String address, int port, String url, int errorCode,
            String errorText)?
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
            PeerConnectionEvent_IceConnectionStateChange value)
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

abstract class PeerConnectionEvent_Track implements PeerConnectionEvent {
  const factory PeerConnectionEvent_Track(final RtcTrackEvent field0) =
      _$PeerConnectionEvent_Track;

  RtcTrackEvent get field0;
  @JsonKey(ignore: true)
  _$$PeerConnectionEvent_TrackCopyWith<_$PeerConnectionEvent_Track>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RTCInboundRtpStreamMediaType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RTCInboundRtpStreamMediaType_Video value) video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RTCInboundRtpStreamMediaTypeCopyWith<$Res> {
  factory $RTCInboundRtpStreamMediaTypeCopyWith(
          RTCInboundRtpStreamMediaType value,
          $Res Function(RTCInboundRtpStreamMediaType) then) =
      _$RTCInboundRtpStreamMediaTypeCopyWithImpl<$Res>;
}

/// @nodoc
class _$RTCInboundRtpStreamMediaTypeCopyWithImpl<$Res>
    implements $RTCInboundRtpStreamMediaTypeCopyWith<$Res> {
  _$RTCInboundRtpStreamMediaTypeCopyWithImpl(this._value, this._then);

  final RTCInboundRtpStreamMediaType _value;
  // ignore: unused_field
  final $Res Function(RTCInboundRtpStreamMediaType) _then;
}

/// @nodoc
abstract class _$$RTCInboundRtpStreamMediaType_AudioCopyWith<$Res> {
  factory _$$RTCInboundRtpStreamMediaType_AudioCopyWith(
          _$RTCInboundRtpStreamMediaType_Audio value,
          $Res Function(_$RTCInboundRtpStreamMediaType_Audio) then) =
      __$$RTCInboundRtpStreamMediaType_AudioCopyWithImpl<$Res>;
  $Res call(
      {int? totalSamplesReceived,
      int? concealedSamples,
      int? silentConcealedSamples,
      double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration});
}

/// @nodoc
class __$$RTCInboundRtpStreamMediaType_AudioCopyWithImpl<$Res>
    extends _$RTCInboundRtpStreamMediaTypeCopyWithImpl<$Res>
    implements _$$RTCInboundRtpStreamMediaType_AudioCopyWith<$Res> {
  __$$RTCInboundRtpStreamMediaType_AudioCopyWithImpl(
      _$RTCInboundRtpStreamMediaType_Audio _value,
      $Res Function(_$RTCInboundRtpStreamMediaType_Audio) _then)
      : super(_value, (v) => _then(v as _$RTCInboundRtpStreamMediaType_Audio));

  @override
  _$RTCInboundRtpStreamMediaType_Audio get _value =>
      super._value as _$RTCInboundRtpStreamMediaType_Audio;

  @override
  $Res call({
    Object? totalSamplesReceived = freezed,
    Object? concealedSamples = freezed,
    Object? silentConcealedSamples = freezed,
    Object? audioLevel = freezed,
    Object? totalAudioEnergy = freezed,
    Object? totalSamplesDuration = freezed,
  }) {
    return _then(_$RTCInboundRtpStreamMediaType_Audio(
      totalSamplesReceived: totalSamplesReceived == freezed
          ? _value.totalSamplesReceived
          : totalSamplesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      concealedSamples: concealedSamples == freezed
          ? _value.concealedSamples
          : concealedSamples // ignore: cast_nullable_to_non_nullable
              as int?,
      silentConcealedSamples: silentConcealedSamples == freezed
          ? _value.silentConcealedSamples
          : silentConcealedSamples // ignore: cast_nullable_to_non_nullable
              as int?,
      audioLevel: audioLevel == freezed
          ? _value.audioLevel
          : audioLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      totalAudioEnergy: totalAudioEnergy == freezed
          ? _value.totalAudioEnergy
          : totalAudioEnergy // ignore: cast_nullable_to_non_nullable
              as double?,
      totalSamplesDuration: totalSamplesDuration == freezed
          ? _value.totalSamplesDuration
          : totalSamplesDuration // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$RTCInboundRtpStreamMediaType_Audio
    implements RTCInboundRtpStreamMediaType_Audio {
  const _$RTCInboundRtpStreamMediaType_Audio(
      {this.totalSamplesReceived,
      this.concealedSamples,
      this.silentConcealedSamples,
      this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration});

  @override
  final int? totalSamplesReceived;
  @override
  final int? concealedSamples;
  @override
  final int? silentConcealedSamples;
  @override
  final double? audioLevel;
  @override
  final double? totalAudioEnergy;
  @override
  final double? totalSamplesDuration;

  @override
  String toString() {
    return 'RTCInboundRtpStreamMediaType.audio(totalSamplesReceived: $totalSamplesReceived, concealedSamples: $concealedSamples, silentConcealedSamples: $silentConcealedSamples, audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCInboundRtpStreamMediaType_Audio &&
            const DeepCollectionEquality()
                .equals(other.totalSamplesReceived, totalSamplesReceived) &&
            const DeepCollectionEquality()
                .equals(other.concealedSamples, concealedSamples) &&
            const DeepCollectionEquality()
                .equals(other.silentConcealedSamples, silentConcealedSamples) &&
            const DeepCollectionEquality()
                .equals(other.audioLevel, audioLevel) &&
            const DeepCollectionEquality()
                .equals(other.totalAudioEnergy, totalAudioEnergy) &&
            const DeepCollectionEquality()
                .equals(other.totalSamplesDuration, totalSamplesDuration));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(totalSamplesReceived),
      const DeepCollectionEquality().hash(concealedSamples),
      const DeepCollectionEquality().hash(silentConcealedSamples),
      const DeepCollectionEquality().hash(audioLevel),
      const DeepCollectionEquality().hash(totalAudioEnergy),
      const DeepCollectionEquality().hash(totalSamplesDuration));

  @JsonKey(ignore: true)
  @override
  _$$RTCInboundRtpStreamMediaType_AudioCopyWith<
          _$RTCInboundRtpStreamMediaType_Audio>
      get copyWith => __$$RTCInboundRtpStreamMediaType_AudioCopyWithImpl<
          _$RTCInboundRtpStreamMediaType_Audio>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) {
    return audio(totalSamplesReceived, concealedSamples, silentConcealedSamples,
        audioLevel, totalAudioEnergy, totalSamplesDuration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) {
    return audio?.call(
        totalSamplesReceived,
        concealedSamples,
        silentConcealedSamples,
        audioLevel,
        totalAudioEnergy,
        totalSamplesDuration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(
          totalSamplesReceived,
          concealedSamples,
          silentConcealedSamples,
          audioLevel,
          totalAudioEnergy,
          totalSamplesDuration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RTCInboundRtpStreamMediaType_Video value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class RTCInboundRtpStreamMediaType_Audio
    implements RTCInboundRtpStreamMediaType {
  const factory RTCInboundRtpStreamMediaType_Audio(
          {final int? totalSamplesReceived,
          final int? concealedSamples,
          final int? silentConcealedSamples,
          final double? audioLevel,
          final double? totalAudioEnergy,
          final double? totalSamplesDuration}) =
      _$RTCInboundRtpStreamMediaType_Audio;

  int? get totalSamplesReceived;
  int? get concealedSamples;
  int? get silentConcealedSamples;
  double? get audioLevel;
  double? get totalAudioEnergy;
  double? get totalSamplesDuration;
  @JsonKey(ignore: true)
  _$$RTCInboundRtpStreamMediaType_AudioCopyWith<
          _$RTCInboundRtpStreamMediaType_Audio>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCInboundRtpStreamMediaType_VideoCopyWith<$Res> {
  factory _$$RTCInboundRtpStreamMediaType_VideoCopyWith(
          _$RTCInboundRtpStreamMediaType_Video value,
          $Res Function(_$RTCInboundRtpStreamMediaType_Video) then) =
      __$$RTCInboundRtpStreamMediaType_VideoCopyWithImpl<$Res>;
  $Res call(
      {int? framesDecoded,
      int? keyFramesDecoded,
      int? frameWidth,
      int? frameHeight,
      double? totalInterFrameDelay,
      double? framesPerSecond,
      int? frameBitDepth,
      int? firCount,
      int? pliCount,
      int? concealmentEvents,
      int? framesReceived});
}

/// @nodoc
class __$$RTCInboundRtpStreamMediaType_VideoCopyWithImpl<$Res>
    extends _$RTCInboundRtpStreamMediaTypeCopyWithImpl<$Res>
    implements _$$RTCInboundRtpStreamMediaType_VideoCopyWith<$Res> {
  __$$RTCInboundRtpStreamMediaType_VideoCopyWithImpl(
      _$RTCInboundRtpStreamMediaType_Video _value,
      $Res Function(_$RTCInboundRtpStreamMediaType_Video) _then)
      : super(_value, (v) => _then(v as _$RTCInboundRtpStreamMediaType_Video));

  @override
  _$RTCInboundRtpStreamMediaType_Video get _value =>
      super._value as _$RTCInboundRtpStreamMediaType_Video;

  @override
  $Res call({
    Object? framesDecoded = freezed,
    Object? keyFramesDecoded = freezed,
    Object? frameWidth = freezed,
    Object? frameHeight = freezed,
    Object? totalInterFrameDelay = freezed,
    Object? framesPerSecond = freezed,
    Object? frameBitDepth = freezed,
    Object? firCount = freezed,
    Object? pliCount = freezed,
    Object? concealmentEvents = freezed,
    Object? framesReceived = freezed,
  }) {
    return _then(_$RTCInboundRtpStreamMediaType_Video(
      framesDecoded: framesDecoded == freezed
          ? _value.framesDecoded
          : framesDecoded // ignore: cast_nullable_to_non_nullable
              as int?,
      keyFramesDecoded: keyFramesDecoded == freezed
          ? _value.keyFramesDecoded
          : keyFramesDecoded // ignore: cast_nullable_to_non_nullable
              as int?,
      frameWidth: frameWidth == freezed
          ? _value.frameWidth
          : frameWidth // ignore: cast_nullable_to_non_nullable
              as int?,
      frameHeight: frameHeight == freezed
          ? _value.frameHeight
          : frameHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      totalInterFrameDelay: totalInterFrameDelay == freezed
          ? _value.totalInterFrameDelay
          : totalInterFrameDelay // ignore: cast_nullable_to_non_nullable
              as double?,
      framesPerSecond: framesPerSecond == freezed
          ? _value.framesPerSecond
          : framesPerSecond // ignore: cast_nullable_to_non_nullable
              as double?,
      frameBitDepth: frameBitDepth == freezed
          ? _value.frameBitDepth
          : frameBitDepth // ignore: cast_nullable_to_non_nullable
              as int?,
      firCount: firCount == freezed
          ? _value.firCount
          : firCount // ignore: cast_nullable_to_non_nullable
              as int?,
      pliCount: pliCount == freezed
          ? _value.pliCount
          : pliCount // ignore: cast_nullable_to_non_nullable
              as int?,
      concealmentEvents: concealmentEvents == freezed
          ? _value.concealmentEvents
          : concealmentEvents // ignore: cast_nullable_to_non_nullable
              as int?,
      framesReceived: framesReceived == freezed
          ? _value.framesReceived
          : framesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RTCInboundRtpStreamMediaType_Video
    implements RTCInboundRtpStreamMediaType_Video {
  const _$RTCInboundRtpStreamMediaType_Video(
      {this.framesDecoded,
      this.keyFramesDecoded,
      this.frameWidth,
      this.frameHeight,
      this.totalInterFrameDelay,
      this.framesPerSecond,
      this.frameBitDepth,
      this.firCount,
      this.pliCount,
      this.concealmentEvents,
      this.framesReceived});

  @override
  final int? framesDecoded;
  @override
  final int? keyFramesDecoded;
  @override
  final int? frameWidth;
  @override
  final int? frameHeight;
  @override
  final double? totalInterFrameDelay;
  @override
  final double? framesPerSecond;
  @override
  final int? frameBitDepth;
  @override
  final int? firCount;
  @override
  final int? pliCount;
  @override
  final int? concealmentEvents;
  @override
  final int? framesReceived;

  @override
  String toString() {
    return 'RTCInboundRtpStreamMediaType.video(framesDecoded: $framesDecoded, keyFramesDecoded: $keyFramesDecoded, frameWidth: $frameWidth, frameHeight: $frameHeight, totalInterFrameDelay: $totalInterFrameDelay, framesPerSecond: $framesPerSecond, frameBitDepth: $frameBitDepth, firCount: $firCount, pliCount: $pliCount, concealmentEvents: $concealmentEvents, framesReceived: $framesReceived)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCInboundRtpStreamMediaType_Video &&
            const DeepCollectionEquality()
                .equals(other.framesDecoded, framesDecoded) &&
            const DeepCollectionEquality()
                .equals(other.keyFramesDecoded, keyFramesDecoded) &&
            const DeepCollectionEquality()
                .equals(other.frameWidth, frameWidth) &&
            const DeepCollectionEquality()
                .equals(other.frameHeight, frameHeight) &&
            const DeepCollectionEquality()
                .equals(other.totalInterFrameDelay, totalInterFrameDelay) &&
            const DeepCollectionEquality()
                .equals(other.framesPerSecond, framesPerSecond) &&
            const DeepCollectionEquality()
                .equals(other.frameBitDepth, frameBitDepth) &&
            const DeepCollectionEquality().equals(other.firCount, firCount) &&
            const DeepCollectionEquality().equals(other.pliCount, pliCount) &&
            const DeepCollectionEquality()
                .equals(other.concealmentEvents, concealmentEvents) &&
            const DeepCollectionEquality()
                .equals(other.framesReceived, framesReceived));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(framesDecoded),
      const DeepCollectionEquality().hash(keyFramesDecoded),
      const DeepCollectionEquality().hash(frameWidth),
      const DeepCollectionEquality().hash(frameHeight),
      const DeepCollectionEquality().hash(totalInterFrameDelay),
      const DeepCollectionEquality().hash(framesPerSecond),
      const DeepCollectionEquality().hash(frameBitDepth),
      const DeepCollectionEquality().hash(firCount),
      const DeepCollectionEquality().hash(pliCount),
      const DeepCollectionEquality().hash(concealmentEvents),
      const DeepCollectionEquality().hash(framesReceived));

  @JsonKey(ignore: true)
  @override
  _$$RTCInboundRtpStreamMediaType_VideoCopyWith<
          _$RTCInboundRtpStreamMediaType_Video>
      get copyWith => __$$RTCInboundRtpStreamMediaType_VideoCopyWithImpl<
          _$RTCInboundRtpStreamMediaType_Video>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)
        audio,
    required TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)
        video,
  }) {
    return video(
        framesDecoded,
        keyFramesDecoded,
        frameWidth,
        frameHeight,
        totalInterFrameDelay,
        framesPerSecond,
        frameBitDepth,
        firCount,
        pliCount,
        concealmentEvents,
        framesReceived);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
  }) {
    return video?.call(
        framesDecoded,
        keyFramesDecoded,
        frameWidth,
        frameHeight,
        totalInterFrameDelay,
        framesPerSecond,
        frameBitDepth,
        firCount,
        pliCount,
        concealmentEvents,
        framesReceived);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? totalSamplesReceived,
            int? concealedSamples,
            int? silentConcealedSamples,
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration)?
        audio,
    TResult Function(
            int? framesDecoded,
            int? keyFramesDecoded,
            int? frameWidth,
            int? frameHeight,
            double? totalInterFrameDelay,
            double? framesPerSecond,
            int? frameBitDepth,
            int? firCount,
            int? pliCount,
            int? concealmentEvents,
            int? framesReceived)?
        video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(
          framesDecoded,
          keyFramesDecoded,
          frameWidth,
          frameHeight,
          totalInterFrameDelay,
          framesPerSecond,
          frameBitDepth,
          firCount,
          pliCount,
          concealmentEvents,
          framesReceived);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCInboundRtpStreamMediaType_Audio value) audio,
    required TResult Function(RTCInboundRtpStreamMediaType_Video value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCInboundRtpStreamMediaType_Audio value)? audio,
    TResult Function(RTCInboundRtpStreamMediaType_Video value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class RTCInboundRtpStreamMediaType_Video
    implements RTCInboundRtpStreamMediaType {
  const factory RTCInboundRtpStreamMediaType_Video(
      {final int? framesDecoded,
      final int? keyFramesDecoded,
      final int? frameWidth,
      final int? frameHeight,
      final double? totalInterFrameDelay,
      final double? framesPerSecond,
      final int? frameBitDepth,
      final int? firCount,
      final int? pliCount,
      final int? concealmentEvents,
      final int? framesReceived}) = _$RTCInboundRtpStreamMediaType_Video;

  int? get framesDecoded;
  int? get keyFramesDecoded;
  int? get frameWidth;
  int? get frameHeight;
  double? get totalInterFrameDelay;
  double? get framesPerSecond;
  int? get frameBitDepth;
  int? get firCount;
  int? get pliCount;
  int? get concealmentEvents;
  int? get framesReceived;
  @JsonKey(ignore: true)
  _$$RTCInboundRtpStreamMediaType_VideoCopyWith<
          _$RTCInboundRtpStreamMediaType_Video>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RTCMediaSourceStatsType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RTCMediaSourceStatsTypeCopyWith<$Res> {
  factory $RTCMediaSourceStatsTypeCopyWith(RTCMediaSourceStatsType value,
          $Res Function(RTCMediaSourceStatsType) then) =
      _$RTCMediaSourceStatsTypeCopyWithImpl<$Res>;
}

/// @nodoc
class _$RTCMediaSourceStatsTypeCopyWithImpl<$Res>
    implements $RTCMediaSourceStatsTypeCopyWith<$Res> {
  _$RTCMediaSourceStatsTypeCopyWithImpl(this._value, this._then);

  final RTCMediaSourceStatsType _value;
  // ignore: unused_field
  final $Res Function(RTCMediaSourceStatsType) _then;
}

/// @nodoc
abstract class _$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWith<$Res> {
  factory _$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWith(
          _$RTCMediaSourceStatsType_RTCVideoSourceStats value,
          $Res Function(_$RTCMediaSourceStatsType_RTCVideoSourceStats) then) =
      __$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWithImpl<$Res>;
  $Res call({int? width, int? height, int? frames, double? framesPerSecond});
}

/// @nodoc
class __$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWithImpl<$Res>
    extends _$RTCMediaSourceStatsTypeCopyWithImpl<$Res>
    implements _$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWith<$Res> {
  __$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWithImpl(
      _$RTCMediaSourceStatsType_RTCVideoSourceStats _value,
      $Res Function(_$RTCMediaSourceStatsType_RTCVideoSourceStats) _then)
      : super(_value,
            (v) => _then(v as _$RTCMediaSourceStatsType_RTCVideoSourceStats));

  @override
  _$RTCMediaSourceStatsType_RTCVideoSourceStats get _value =>
      super._value as _$RTCMediaSourceStatsType_RTCVideoSourceStats;

  @override
  $Res call({
    Object? width = freezed,
    Object? height = freezed,
    Object? frames = freezed,
    Object? framesPerSecond = freezed,
  }) {
    return _then(_$RTCMediaSourceStatsType_RTCVideoSourceStats(
      width: width == freezed
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: height == freezed
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      frames: frames == freezed
          ? _value.frames
          : frames // ignore: cast_nullable_to_non_nullable
              as int?,
      framesPerSecond: framesPerSecond == freezed
          ? _value.framesPerSecond
          : framesPerSecond // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$RTCMediaSourceStatsType_RTCVideoSourceStats
    implements RTCMediaSourceStatsType_RTCVideoSourceStats {
  const _$RTCMediaSourceStatsType_RTCVideoSourceStats(
      {this.width, this.height, this.frames, this.framesPerSecond});

  @override
  final int? width;
  @override
  final int? height;
  @override
  final int? frames;
  @override
  final double? framesPerSecond;

  @override
  String toString() {
    return 'RTCMediaSourceStatsType.rtcVideoSourceStats(width: $width, height: $height, frames: $frames, framesPerSecond: $framesPerSecond)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCMediaSourceStatsType_RTCVideoSourceStats &&
            const DeepCollectionEquality().equals(other.width, width) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.frames, frames) &&
            const DeepCollectionEquality()
                .equals(other.framesPerSecond, framesPerSecond));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(width),
      const DeepCollectionEquality().hash(height),
      const DeepCollectionEquality().hash(frames),
      const DeepCollectionEquality().hash(framesPerSecond));

  @JsonKey(ignore: true)
  @override
  _$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWith<
          _$RTCMediaSourceStatsType_RTCVideoSourceStats>
      get copyWith =>
          __$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWithImpl<
              _$RTCMediaSourceStatsType_RTCVideoSourceStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats?.call(width, height, frames, framesPerSecond);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcVideoSourceStats != null) {
      return rtcVideoSourceStats(width, height, frames, framesPerSecond);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
  }) {
    return rtcVideoSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcVideoSourceStats != null) {
      return rtcVideoSourceStats(this);
    }
    return orElse();
  }
}

abstract class RTCMediaSourceStatsType_RTCVideoSourceStats
    implements RTCMediaSourceStatsType {
  const factory RTCMediaSourceStatsType_RTCVideoSourceStats(
          {final int? width,
          final int? height,
          final int? frames,
          final double? framesPerSecond}) =
      _$RTCMediaSourceStatsType_RTCVideoSourceStats;

  int? get width;
  int? get height;
  int? get frames;
  double? get framesPerSecond;
  @JsonKey(ignore: true)
  _$$RTCMediaSourceStatsType_RTCVideoSourceStatsCopyWith<
          _$RTCMediaSourceStatsType_RTCVideoSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWith<$Res> {
  factory _$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWith(
          _$RTCMediaSourceStatsType_RTCAudioSourceStats value,
          $Res Function(_$RTCMediaSourceStatsType_RTCAudioSourceStats) then) =
      __$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWithImpl<$Res>;
  $Res call(
      {double? audioLevel,
      double? totalAudioEnergy,
      double? totalSamplesDuration,
      double? echoReturnLoss,
      double? echoReturnLossEnhancement});
}

/// @nodoc
class __$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWithImpl<$Res>
    extends _$RTCMediaSourceStatsTypeCopyWithImpl<$Res>
    implements _$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWith<$Res> {
  __$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWithImpl(
      _$RTCMediaSourceStatsType_RTCAudioSourceStats _value,
      $Res Function(_$RTCMediaSourceStatsType_RTCAudioSourceStats) _then)
      : super(_value,
            (v) => _then(v as _$RTCMediaSourceStatsType_RTCAudioSourceStats));

  @override
  _$RTCMediaSourceStatsType_RTCAudioSourceStats get _value =>
      super._value as _$RTCMediaSourceStatsType_RTCAudioSourceStats;

  @override
  $Res call({
    Object? audioLevel = freezed,
    Object? totalAudioEnergy = freezed,
    Object? totalSamplesDuration = freezed,
    Object? echoReturnLoss = freezed,
    Object? echoReturnLossEnhancement = freezed,
  }) {
    return _then(_$RTCMediaSourceStatsType_RTCAudioSourceStats(
      audioLevel: audioLevel == freezed
          ? _value.audioLevel
          : audioLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      totalAudioEnergy: totalAudioEnergy == freezed
          ? _value.totalAudioEnergy
          : totalAudioEnergy // ignore: cast_nullable_to_non_nullable
              as double?,
      totalSamplesDuration: totalSamplesDuration == freezed
          ? _value.totalSamplesDuration
          : totalSamplesDuration // ignore: cast_nullable_to_non_nullable
              as double?,
      echoReturnLoss: echoReturnLoss == freezed
          ? _value.echoReturnLoss
          : echoReturnLoss // ignore: cast_nullable_to_non_nullable
              as double?,
      echoReturnLossEnhancement: echoReturnLossEnhancement == freezed
          ? _value.echoReturnLossEnhancement
          : echoReturnLossEnhancement // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$RTCMediaSourceStatsType_RTCAudioSourceStats
    implements RTCMediaSourceStatsType_RTCAudioSourceStats {
  const _$RTCMediaSourceStatsType_RTCAudioSourceStats(
      {this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration,
      this.echoReturnLoss,
      this.echoReturnLossEnhancement});

  @override
  final double? audioLevel;
  @override
  final double? totalAudioEnergy;
  @override
  final double? totalSamplesDuration;
  @override
  final double? echoReturnLoss;
  @override
  final double? echoReturnLossEnhancement;

  @override
  String toString() {
    return 'RTCMediaSourceStatsType.rtcAudioSourceStats(audioLevel: $audioLevel, totalAudioEnergy: $totalAudioEnergy, totalSamplesDuration: $totalSamplesDuration, echoReturnLoss: $echoReturnLoss, echoReturnLossEnhancement: $echoReturnLossEnhancement)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCMediaSourceStatsType_RTCAudioSourceStats &&
            const DeepCollectionEquality()
                .equals(other.audioLevel, audioLevel) &&
            const DeepCollectionEquality()
                .equals(other.totalAudioEnergy, totalAudioEnergy) &&
            const DeepCollectionEquality()
                .equals(other.totalSamplesDuration, totalSamplesDuration) &&
            const DeepCollectionEquality()
                .equals(other.echoReturnLoss, echoReturnLoss) &&
            const DeepCollectionEquality().equals(
                other.echoReturnLossEnhancement, echoReturnLossEnhancement));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(audioLevel),
      const DeepCollectionEquality().hash(totalAudioEnergy),
      const DeepCollectionEquality().hash(totalSamplesDuration),
      const DeepCollectionEquality().hash(echoReturnLoss),
      const DeepCollectionEquality().hash(echoReturnLossEnhancement));

  @JsonKey(ignore: true)
  @override
  _$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWith<
          _$RTCMediaSourceStatsType_RTCAudioSourceStats>
      get copyWith =>
          __$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWithImpl<
              _$RTCMediaSourceStatsType_RTCAudioSourceStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)
        rtcVideoSourceStats,
    required TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats(audioLevel, totalAudioEnergy,
        totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats?.call(audioLevel, totalAudioEnergy,
        totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            int? width, int? height, int? frames, double? framesPerSecond)?
        rtcVideoSourceStats,
    TResult Function(
            double? audioLevel,
            double? totalAudioEnergy,
            double? totalSamplesDuration,
            double? echoReturnLoss,
            double? echoReturnLossEnhancement)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcAudioSourceStats != null) {
      return rtcAudioSourceStats(audioLevel, totalAudioEnergy,
          totalSamplesDuration, echoReturnLoss, echoReturnLossEnhancement);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)
        rtcVideoSourceStats,
    required TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
  }) {
    return rtcAudioSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCMediaSourceStatsType_RTCVideoSourceStats value)?
        rtcVideoSourceStats,
    TResult Function(RTCMediaSourceStatsType_RTCAudioSourceStats value)?
        rtcAudioSourceStats,
    required TResult orElse(),
  }) {
    if (rtcAudioSourceStats != null) {
      return rtcAudioSourceStats(this);
    }
    return orElse();
  }
}

abstract class RTCMediaSourceStatsType_RTCAudioSourceStats
    implements RTCMediaSourceStatsType {
  const factory RTCMediaSourceStatsType_RTCAudioSourceStats(
          {final double? audioLevel,
          final double? totalAudioEnergy,
          final double? totalSamplesDuration,
          final double? echoReturnLoss,
          final double? echoReturnLossEnhancement}) =
      _$RTCMediaSourceStatsType_RTCAudioSourceStats;

  double? get audioLevel;
  double? get totalAudioEnergy;
  double? get totalSamplesDuration;
  double? get echoReturnLoss;
  double? get echoReturnLossEnhancement;
  @JsonKey(ignore: true)
  _$$RTCMediaSourceStatsType_RTCAudioSourceStatsCopyWith<
          _$RTCMediaSourceStatsType_RTCAudioSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RTCStatsType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RTCStatsTypeCopyWith<$Res> {
  factory $RTCStatsTypeCopyWith(
          RTCStatsType value, $Res Function(RTCStatsType) then) =
      _$RTCStatsTypeCopyWithImpl<$Res>;
}

/// @nodoc
class _$RTCStatsTypeCopyWithImpl<$Res> implements $RTCStatsTypeCopyWith<$Res> {
  _$RTCStatsTypeCopyWithImpl(this._value, this._then);

  final RTCStatsType _value;
  // ignore: unused_field
  final $Res Function(RTCStatsType) _then;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCMediaSourceStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCMediaSourceStatsCopyWith(
          _$RTCStatsType_RTCMediaSourceStats value,
          $Res Function(_$RTCStatsType_RTCMediaSourceStats) then) =
      __$$RTCStatsType_RTCMediaSourceStatsCopyWithImpl<$Res>;
  $Res call({String? trackIdentifier, RTCMediaSourceStatsType kind});

  $RTCMediaSourceStatsTypeCopyWith<$Res> get kind;
}

/// @nodoc
class __$$RTCStatsType_RTCMediaSourceStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCMediaSourceStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCMediaSourceStatsCopyWithImpl(
      _$RTCStatsType_RTCMediaSourceStats _value,
      $Res Function(_$RTCStatsType_RTCMediaSourceStats) _then)
      : super(_value, (v) => _then(v as _$RTCStatsType_RTCMediaSourceStats));

  @override
  _$RTCStatsType_RTCMediaSourceStats get _value =>
      super._value as _$RTCStatsType_RTCMediaSourceStats;

  @override
  $Res call({
    Object? trackIdentifier = freezed,
    Object? kind = freezed,
  }) {
    return _then(_$RTCStatsType_RTCMediaSourceStats(
      trackIdentifier: trackIdentifier == freezed
          ? _value.trackIdentifier
          : trackIdentifier // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as RTCMediaSourceStatsType,
    ));
  }

  @override
  $RTCMediaSourceStatsTypeCopyWith<$Res> get kind {
    return $RTCMediaSourceStatsTypeCopyWith<$Res>(_value.kind, (value) {
      return _then(_value.copyWith(kind: value));
    });
  }
}

/// @nodoc

class _$RTCStatsType_RTCMediaSourceStats
    implements RTCStatsType_RTCMediaSourceStats {
  const _$RTCStatsType_RTCMediaSourceStats(
      {this.trackIdentifier, required this.kind});

  @override
  final String? trackIdentifier;
  @override
  final RTCMediaSourceStatsType kind;

  @override
  String toString() {
    return 'RTCStatsType.rtcMediaSourceStats(trackIdentifier: $trackIdentifier, kind: $kind)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCMediaSourceStats &&
            const DeepCollectionEquality()
                .equals(other.trackIdentifier, trackIdentifier) &&
            const DeepCollectionEquality().equals(other.kind, kind));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(trackIdentifier),
      const DeepCollectionEquality().hash(kind));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCMediaSourceStatsCopyWith<
          _$RTCStatsType_RTCMediaSourceStats>
      get copyWith => __$$RTCStatsType_RTCMediaSourceStatsCopyWithImpl<
          _$RTCStatsType_RTCMediaSourceStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcMediaSourceStats(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcMediaSourceStats?.call(trackIdentifier, kind);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcMediaSourceStats != null) {
      return rtcMediaSourceStats(trackIdentifier, kind);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcMediaSourceStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcMediaSourceStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcMediaSourceStats != null) {
      return rtcMediaSourceStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCMediaSourceStats implements RTCStatsType {
  const factory RTCStatsType_RTCMediaSourceStats(
          {final String? trackIdentifier,
          required final RTCMediaSourceStatsType kind}) =
      _$RTCStatsType_RTCMediaSourceStats;

  String? get trackIdentifier;
  RTCMediaSourceStatsType get kind;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCMediaSourceStatsCopyWith<
          _$RTCStatsType_RTCMediaSourceStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCIceCandidateStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCIceCandidateStatsCopyWith(
          _$RTCStatsType_RTCIceCandidateStats value,
          $Res Function(_$RTCStatsType_RTCIceCandidateStats) then) =
      __$$RTCStatsType_RTCIceCandidateStatsCopyWithImpl<$Res>;
  $Res call(
      {String? transportId,
      String? address,
      int? port,
      String? protocol,
      CandidateType candidateType,
      int? priority,
      String? url,
      bool? isRemote});
}

/// @nodoc
class __$$RTCStatsType_RTCIceCandidateStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCIceCandidateStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCIceCandidateStatsCopyWithImpl(
      _$RTCStatsType_RTCIceCandidateStats _value,
      $Res Function(_$RTCStatsType_RTCIceCandidateStats) _then)
      : super(_value, (v) => _then(v as _$RTCStatsType_RTCIceCandidateStats));

  @override
  _$RTCStatsType_RTCIceCandidateStats get _value =>
      super._value as _$RTCStatsType_RTCIceCandidateStats;

  @override
  $Res call({
    Object? transportId = freezed,
    Object? address = freezed,
    Object? port = freezed,
    Object? protocol = freezed,
    Object? candidateType = freezed,
    Object? priority = freezed,
    Object? url = freezed,
    Object? isRemote = freezed,
  }) {
    return _then(_$RTCStatsType_RTCIceCandidateStats(
      transportId: transportId == freezed
          ? _value.transportId
          : transportId // ignore: cast_nullable_to_non_nullable
              as String?,
      address: address == freezed
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      port: port == freezed
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int?,
      protocol: protocol == freezed
          ? _value.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as String?,
      candidateType: candidateType == freezed
          ? _value.candidateType
          : candidateType // ignore: cast_nullable_to_non_nullable
              as CandidateType,
      priority: priority == freezed
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      isRemote: isRemote == freezed
          ? _value.isRemote
          : isRemote // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCIceCandidateStats
    implements RTCStatsType_RTCIceCandidateStats {
  const _$RTCStatsType_RTCIceCandidateStats(
      {this.transportId,
      this.address,
      this.port,
      this.protocol,
      required this.candidateType,
      this.priority,
      this.url,
      this.isRemote});

  @override
  final String? transportId;
  @override
  final String? address;
  @override
  final int? port;
  @override
  final String? protocol;
  @override
  final CandidateType candidateType;
  @override
  final int? priority;
  @override
  final String? url;
  @override
  final bool? isRemote;

  @override
  String toString() {
    return 'RTCStatsType.rtcIceCandidateStats(transportId: $transportId, address: $address, port: $port, protocol: $protocol, candidateType: $candidateType, priority: $priority, url: $url, isRemote: $isRemote)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCIceCandidateStats &&
            const DeepCollectionEquality()
                .equals(other.transportId, transportId) &&
            const DeepCollectionEquality().equals(other.address, address) &&
            const DeepCollectionEquality().equals(other.port, port) &&
            const DeepCollectionEquality().equals(other.protocol, protocol) &&
            const DeepCollectionEquality()
                .equals(other.candidateType, candidateType) &&
            const DeepCollectionEquality().equals(other.priority, priority) &&
            const DeepCollectionEquality().equals(other.url, url) &&
            const DeepCollectionEquality().equals(other.isRemote, isRemote));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(transportId),
      const DeepCollectionEquality().hash(address),
      const DeepCollectionEquality().hash(port),
      const DeepCollectionEquality().hash(protocol),
      const DeepCollectionEquality().hash(candidateType),
      const DeepCollectionEquality().hash(priority),
      const DeepCollectionEquality().hash(url),
      const DeepCollectionEquality().hash(isRemote));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCIceCandidateStatsCopyWith<
          _$RTCStatsType_RTCIceCandidateStats>
      get copyWith => __$$RTCStatsType_RTCIceCandidateStatsCopyWithImpl<
          _$RTCStatsType_RTCIceCandidateStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcIceCandidateStats(transportId, address, port, protocol,
        candidateType, priority, url, isRemote);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcIceCandidateStats?.call(transportId, address, port, protocol,
        candidateType, priority, url, isRemote);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidateStats != null) {
      return rtcIceCandidateStats(transportId, address, port, protocol,
          candidateType, priority, url, isRemote);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcIceCandidateStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcIceCandidateStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidateStats != null) {
      return rtcIceCandidateStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCIceCandidateStats implements RTCStatsType {
  const factory RTCStatsType_RTCIceCandidateStats(
      {final String? transportId,
      final String? address,
      final int? port,
      final String? protocol,
      required final CandidateType candidateType,
      final int? priority,
      final String? url,
      final bool? isRemote}) = _$RTCStatsType_RTCIceCandidateStats;

  String? get transportId;
  String? get address;
  int? get port;
  String? get protocol;
  CandidateType get candidateType;
  int? get priority;
  String? get url;
  bool? get isRemote;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCIceCandidateStatsCopyWith<
          _$RTCStatsType_RTCIceCandidateStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWith(
          _$RTCStatsType_RTCOutboundRTPStreamStats value,
          $Res Function(_$RTCStatsType_RTCOutboundRTPStreamStats) then) =
      __$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWithImpl<$Res>;
  $Res call(
      {String? trackId,
      TrackKind kind,
      int? frameWidth,
      int? frameHeight,
      double? framesPerSecond,
      int? bytesSent,
      int? packetsSent,
      String? mediaSourceId});
}

/// @nodoc
class __$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWithImpl(
      _$RTCStatsType_RTCOutboundRTPStreamStats _value,
      $Res Function(_$RTCStatsType_RTCOutboundRTPStreamStats) _then)
      : super(_value,
            (v) => _then(v as _$RTCStatsType_RTCOutboundRTPStreamStats));

  @override
  _$RTCStatsType_RTCOutboundRTPStreamStats get _value =>
      super._value as _$RTCStatsType_RTCOutboundRTPStreamStats;

  @override
  $Res call({
    Object? trackId = freezed,
    Object? kind = freezed,
    Object? frameWidth = freezed,
    Object? frameHeight = freezed,
    Object? framesPerSecond = freezed,
    Object? bytesSent = freezed,
    Object? packetsSent = freezed,
    Object? mediaSourceId = freezed,
  }) {
    return _then(_$RTCStatsType_RTCOutboundRTPStreamStats(
      trackId: trackId == freezed
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String?,
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as TrackKind,
      frameWidth: frameWidth == freezed
          ? _value.frameWidth
          : frameWidth // ignore: cast_nullable_to_non_nullable
              as int?,
      frameHeight: frameHeight == freezed
          ? _value.frameHeight
          : frameHeight // ignore: cast_nullable_to_non_nullable
              as int?,
      framesPerSecond: framesPerSecond == freezed
          ? _value.framesPerSecond
          : framesPerSecond // ignore: cast_nullable_to_non_nullable
              as double?,
      bytesSent: bytesSent == freezed
          ? _value.bytesSent
          : bytesSent // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsSent: packetsSent == freezed
          ? _value.packetsSent
          : packetsSent // ignore: cast_nullable_to_non_nullable
              as int?,
      mediaSourceId: mediaSourceId == freezed
          ? _value.mediaSourceId
          : mediaSourceId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCOutboundRTPStreamStats
    implements RTCStatsType_RTCOutboundRTPStreamStats {
  const _$RTCStatsType_RTCOutboundRTPStreamStats(
      {this.trackId,
      required this.kind,
      this.frameWidth,
      this.frameHeight,
      this.framesPerSecond,
      this.bytesSent,
      this.packetsSent,
      this.mediaSourceId});

  @override
  final String? trackId;
  @override
  final TrackKind kind;
  @override
  final int? frameWidth;
  @override
  final int? frameHeight;
  @override
  final double? framesPerSecond;
  @override
  final int? bytesSent;
  @override
  final int? packetsSent;
  @override
  final String? mediaSourceId;

  @override
  String toString() {
    return 'RTCStatsType.rtcOutboundRtpStreamStats(trackId: $trackId, kind: $kind, frameWidth: $frameWidth, frameHeight: $frameHeight, framesPerSecond: $framesPerSecond, bytesSent: $bytesSent, packetsSent: $packetsSent, mediaSourceId: $mediaSourceId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCOutboundRTPStreamStats &&
            const DeepCollectionEquality().equals(other.trackId, trackId) &&
            const DeepCollectionEquality().equals(other.kind, kind) &&
            const DeepCollectionEquality()
                .equals(other.frameWidth, frameWidth) &&
            const DeepCollectionEquality()
                .equals(other.frameHeight, frameHeight) &&
            const DeepCollectionEquality()
                .equals(other.framesPerSecond, framesPerSecond) &&
            const DeepCollectionEquality().equals(other.bytesSent, bytesSent) &&
            const DeepCollectionEquality()
                .equals(other.packetsSent, packetsSent) &&
            const DeepCollectionEquality()
                .equals(other.mediaSourceId, mediaSourceId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(trackId),
      const DeepCollectionEquality().hash(kind),
      const DeepCollectionEquality().hash(frameWidth),
      const DeepCollectionEquality().hash(frameHeight),
      const DeepCollectionEquality().hash(framesPerSecond),
      const DeepCollectionEquality().hash(bytesSent),
      const DeepCollectionEquality().hash(packetsSent),
      const DeepCollectionEquality().hash(mediaSourceId));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWith<
          _$RTCStatsType_RTCOutboundRTPStreamStats>
      get copyWith => __$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWithImpl<
          _$RTCStatsType_RTCOutboundRTPStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcOutboundRtpStreamStats(trackId, kind, frameWidth, frameHeight,
        framesPerSecond, bytesSent, packetsSent, mediaSourceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcOutboundRtpStreamStats?.call(trackId, kind, frameWidth,
        frameHeight, framesPerSecond, bytesSent, packetsSent, mediaSourceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcOutboundRtpStreamStats != null) {
      return rtcOutboundRtpStreamStats(trackId, kind, frameWidth, frameHeight,
          framesPerSecond, bytesSent, packetsSent, mediaSourceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcOutboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcOutboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcOutboundRtpStreamStats != null) {
      return rtcOutboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCOutboundRTPStreamStats implements RTCStatsType {
  const factory RTCStatsType_RTCOutboundRTPStreamStats(
      {final String? trackId,
      required final TrackKind kind,
      final int? frameWidth,
      final int? frameHeight,
      final double? framesPerSecond,
      final int? bytesSent,
      final int? packetsSent,
      final String? mediaSourceId}) = _$RTCStatsType_RTCOutboundRTPStreamStats;

  String? get trackId;
  TrackKind get kind;
  int? get frameWidth;
  int? get frameHeight;
  double? get framesPerSecond;
  int? get bytesSent;
  int? get packetsSent;
  String? get mediaSourceId;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCOutboundRTPStreamStatsCopyWith<
          _$RTCStatsType_RTCOutboundRTPStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCInboundRTPStreamStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCInboundRTPStreamStatsCopyWith(
          _$RTCStatsType_RTCInboundRTPStreamStats value,
          $Res Function(_$RTCStatsType_RTCInboundRTPStreamStats) then) =
      __$$RTCStatsType_RTCInboundRTPStreamStatsCopyWithImpl<$Res>;
  $Res call(
      {String? remoteId,
      int? bytesReceived,
      int? packetsReceived,
      double? totalDecodeTime,
      int? jitterBufferEmittedCount,
      RTCInboundRtpStreamMediaType? mediaType});

  $RTCInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType;
}

/// @nodoc
class __$$RTCStatsType_RTCInboundRTPStreamStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCInboundRTPStreamStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCInboundRTPStreamStatsCopyWithImpl(
      _$RTCStatsType_RTCInboundRTPStreamStats _value,
      $Res Function(_$RTCStatsType_RTCInboundRTPStreamStats) _then)
      : super(
            _value, (v) => _then(v as _$RTCStatsType_RTCInboundRTPStreamStats));

  @override
  _$RTCStatsType_RTCInboundRTPStreamStats get _value =>
      super._value as _$RTCStatsType_RTCInboundRTPStreamStats;

  @override
  $Res call({
    Object? remoteId = freezed,
    Object? bytesReceived = freezed,
    Object? packetsReceived = freezed,
    Object? totalDecodeTime = freezed,
    Object? jitterBufferEmittedCount = freezed,
    Object? mediaType = freezed,
  }) {
    return _then(_$RTCStatsType_RTCInboundRTPStreamStats(
      remoteId: remoteId == freezed
          ? _value.remoteId
          : remoteId // ignore: cast_nullable_to_non_nullable
              as String?,
      bytesReceived: bytesReceived == freezed
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsReceived: packetsReceived == freezed
          ? _value.packetsReceived
          : packetsReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      totalDecodeTime: totalDecodeTime == freezed
          ? _value.totalDecodeTime
          : totalDecodeTime // ignore: cast_nullable_to_non_nullable
              as double?,
      jitterBufferEmittedCount: jitterBufferEmittedCount == freezed
          ? _value.jitterBufferEmittedCount
          : jitterBufferEmittedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      mediaType: mediaType == freezed
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as RTCInboundRtpStreamMediaType?,
    ));
  }

  @override
  $RTCInboundRtpStreamMediaTypeCopyWith<$Res>? get mediaType {
    if (_value.mediaType == null) {
      return null;
    }

    return $RTCInboundRtpStreamMediaTypeCopyWith<$Res>(_value.mediaType!,
        (value) {
      return _then(_value.copyWith(mediaType: value));
    });
  }
}

/// @nodoc

class _$RTCStatsType_RTCInboundRTPStreamStats
    implements RTCStatsType_RTCInboundRTPStreamStats {
  const _$RTCStatsType_RTCInboundRTPStreamStats(
      {this.remoteId,
      this.bytesReceived,
      this.packetsReceived,
      this.totalDecodeTime,
      this.jitterBufferEmittedCount,
      this.mediaType});

  @override
  final String? remoteId;
  @override
  final int? bytesReceived;
  @override
  final int? packetsReceived;
  @override
  final double? totalDecodeTime;
  @override
  final int? jitterBufferEmittedCount;
  @override
  final RTCInboundRtpStreamMediaType? mediaType;

  @override
  String toString() {
    return 'RTCStatsType.rtcInboundRtpStreamStats(remoteId: $remoteId, bytesReceived: $bytesReceived, packetsReceived: $packetsReceived, totalDecodeTime: $totalDecodeTime, jitterBufferEmittedCount: $jitterBufferEmittedCount, mediaType: $mediaType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCInboundRTPStreamStats &&
            const DeepCollectionEquality().equals(other.remoteId, remoteId) &&
            const DeepCollectionEquality()
                .equals(other.bytesReceived, bytesReceived) &&
            const DeepCollectionEquality()
                .equals(other.packetsReceived, packetsReceived) &&
            const DeepCollectionEquality()
                .equals(other.totalDecodeTime, totalDecodeTime) &&
            const DeepCollectionEquality().equals(
                other.jitterBufferEmittedCount, jitterBufferEmittedCount) &&
            const DeepCollectionEquality().equals(other.mediaType, mediaType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(remoteId),
      const DeepCollectionEquality().hash(bytesReceived),
      const DeepCollectionEquality().hash(packetsReceived),
      const DeepCollectionEquality().hash(totalDecodeTime),
      const DeepCollectionEquality().hash(jitterBufferEmittedCount),
      const DeepCollectionEquality().hash(mediaType));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCInboundRTPStreamStatsCopyWith<
          _$RTCStatsType_RTCInboundRTPStreamStats>
      get copyWith => __$$RTCStatsType_RTCInboundRTPStreamStatsCopyWithImpl<
          _$RTCStatsType_RTCInboundRTPStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcInboundRtpStreamStats(remoteId, bytesReceived, packetsReceived,
        totalDecodeTime, jitterBufferEmittedCount, mediaType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcInboundRtpStreamStats?.call(remoteId, bytesReceived,
        packetsReceived, totalDecodeTime, jitterBufferEmittedCount, mediaType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcInboundRtpStreamStats != null) {
      return rtcInboundRtpStreamStats(remoteId, bytesReceived, packetsReceived,
          totalDecodeTime, jitterBufferEmittedCount, mediaType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcInboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcInboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcInboundRtpStreamStats != null) {
      return rtcInboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCInboundRTPStreamStats implements RTCStatsType {
  const factory RTCStatsType_RTCInboundRTPStreamStats(
          {final String? remoteId,
          final int? bytesReceived,
          final int? packetsReceived,
          final double? totalDecodeTime,
          final int? jitterBufferEmittedCount,
          final RTCInboundRtpStreamMediaType? mediaType}) =
      _$RTCStatsType_RTCInboundRTPStreamStats;

  String? get remoteId;
  int? get bytesReceived;
  int? get packetsReceived;
  double? get totalDecodeTime;
  int? get jitterBufferEmittedCount;
  RTCInboundRtpStreamMediaType? get mediaType;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCInboundRTPStreamStatsCopyWith<
          _$RTCStatsType_RTCInboundRTPStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCIceCandidatePairStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCIceCandidatePairStatsCopyWith(
          _$RTCStatsType_RTCIceCandidatePairStats value,
          $Res Function(_$RTCStatsType_RTCIceCandidatePairStats) then) =
      __$$RTCStatsType_RTCIceCandidatePairStatsCopyWithImpl<$Res>;
  $Res call(
      {RTCStatsIceCandidatePairState state,
      bool? nominated,
      int? bytesSent,
      int? bytesReceived,
      double? totalRoundTripTime,
      double? currentRoundTripTime,
      double? availableOutgoingBitrate});
}

/// @nodoc
class __$$RTCStatsType_RTCIceCandidatePairStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCIceCandidatePairStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCIceCandidatePairStatsCopyWithImpl(
      _$RTCStatsType_RTCIceCandidatePairStats _value,
      $Res Function(_$RTCStatsType_RTCIceCandidatePairStats) _then)
      : super(
            _value, (v) => _then(v as _$RTCStatsType_RTCIceCandidatePairStats));

  @override
  _$RTCStatsType_RTCIceCandidatePairStats get _value =>
      super._value as _$RTCStatsType_RTCIceCandidatePairStats;

  @override
  $Res call({
    Object? state = freezed,
    Object? nominated = freezed,
    Object? bytesSent = freezed,
    Object? bytesReceived = freezed,
    Object? totalRoundTripTime = freezed,
    Object? currentRoundTripTime = freezed,
    Object? availableOutgoingBitrate = freezed,
  }) {
    return _then(_$RTCStatsType_RTCIceCandidatePairStats(
      state: state == freezed
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as RTCStatsIceCandidatePairState,
      nominated: nominated == freezed
          ? _value.nominated
          : nominated // ignore: cast_nullable_to_non_nullable
              as bool?,
      bytesSent: bytesSent == freezed
          ? _value.bytesSent
          : bytesSent // ignore: cast_nullable_to_non_nullable
              as int?,
      bytesReceived: bytesReceived == freezed
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRoundTripTime: totalRoundTripTime == freezed
          ? _value.totalRoundTripTime
          : totalRoundTripTime // ignore: cast_nullable_to_non_nullable
              as double?,
      currentRoundTripTime: currentRoundTripTime == freezed
          ? _value.currentRoundTripTime
          : currentRoundTripTime // ignore: cast_nullable_to_non_nullable
              as double?,
      availableOutgoingBitrate: availableOutgoingBitrate == freezed
          ? _value.availableOutgoingBitrate
          : availableOutgoingBitrate // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCIceCandidatePairStats
    implements RTCStatsType_RTCIceCandidatePairStats {
  const _$RTCStatsType_RTCIceCandidatePairStats(
      {required this.state,
      this.nominated,
      this.bytesSent,
      this.bytesReceived,
      this.totalRoundTripTime,
      this.currentRoundTripTime,
      this.availableOutgoingBitrate});

  @override
  final RTCStatsIceCandidatePairState state;
  @override
  final bool? nominated;
  @override
  final int? bytesSent;
  @override
  final int? bytesReceived;
  @override
  final double? totalRoundTripTime;
  @override
  final double? currentRoundTripTime;
  @override
  final double? availableOutgoingBitrate;

  @override
  String toString() {
    return 'RTCStatsType.rtcIceCandidatePairStats(state: $state, nominated: $nominated, bytesSent: $bytesSent, bytesReceived: $bytesReceived, totalRoundTripTime: $totalRoundTripTime, currentRoundTripTime: $currentRoundTripTime, availableOutgoingBitrate: $availableOutgoingBitrate)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCIceCandidatePairStats &&
            const DeepCollectionEquality().equals(other.state, state) &&
            const DeepCollectionEquality().equals(other.nominated, nominated) &&
            const DeepCollectionEquality().equals(other.bytesSent, bytesSent) &&
            const DeepCollectionEquality()
                .equals(other.bytesReceived, bytesReceived) &&
            const DeepCollectionEquality()
                .equals(other.totalRoundTripTime, totalRoundTripTime) &&
            const DeepCollectionEquality()
                .equals(other.currentRoundTripTime, currentRoundTripTime) &&
            const DeepCollectionEquality().equals(
                other.availableOutgoingBitrate, availableOutgoingBitrate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(state),
      const DeepCollectionEquality().hash(nominated),
      const DeepCollectionEquality().hash(bytesSent),
      const DeepCollectionEquality().hash(bytesReceived),
      const DeepCollectionEquality().hash(totalRoundTripTime),
      const DeepCollectionEquality().hash(currentRoundTripTime),
      const DeepCollectionEquality().hash(availableOutgoingBitrate));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCIceCandidatePairStatsCopyWith<
          _$RTCStatsType_RTCIceCandidatePairStats>
      get copyWith => __$$RTCStatsType_RTCIceCandidatePairStatsCopyWithImpl<
          _$RTCStatsType_RTCIceCandidatePairStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcIceCandidatePairStats(state, nominated, bytesSent, bytesReceived,
        totalRoundTripTime, currentRoundTripTime, availableOutgoingBitrate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcIceCandidatePairStats?.call(
        state,
        nominated,
        bytesSent,
        bytesReceived,
        totalRoundTripTime,
        currentRoundTripTime,
        availableOutgoingBitrate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidatePairStats != null) {
      return rtcIceCandidatePairStats(
          state,
          nominated,
          bytesSent,
          bytesReceived,
          totalRoundTripTime,
          currentRoundTripTime,
          availableOutgoingBitrate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcIceCandidatePairStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcIceCandidatePairStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcIceCandidatePairStats != null) {
      return rtcIceCandidatePairStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCIceCandidatePairStats implements RTCStatsType {
  const factory RTCStatsType_RTCIceCandidatePairStats(
          {required final RTCStatsIceCandidatePairState state,
          final bool? nominated,
          final int? bytesSent,
          final int? bytesReceived,
          final double? totalRoundTripTime,
          final double? currentRoundTripTime,
          final double? availableOutgoingBitrate}) =
      _$RTCStatsType_RTCIceCandidatePairStats;

  RTCStatsIceCandidatePairState get state;
  bool? get nominated;
  int? get bytesSent;
  int? get bytesReceived;
  double? get totalRoundTripTime;
  double? get currentRoundTripTime;
  double? get availableOutgoingBitrate;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCIceCandidatePairStatsCopyWith<
          _$RTCStatsType_RTCIceCandidatePairStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCTransportStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCTransportStatsCopyWith(
          _$RTCStatsType_RTCTransportStats value,
          $Res Function(_$RTCStatsType_RTCTransportStats) then) =
      __$$RTCStatsType_RTCTransportStatsCopyWithImpl<$Res>;
  $Res call(
      {int? packetsSent,
      int? packetsReceived,
      int? bytesSent,
      int? bytesReceived});
}

/// @nodoc
class __$$RTCStatsType_RTCTransportStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCTransportStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCTransportStatsCopyWithImpl(
      _$RTCStatsType_RTCTransportStats _value,
      $Res Function(_$RTCStatsType_RTCTransportStats) _then)
      : super(_value, (v) => _then(v as _$RTCStatsType_RTCTransportStats));

  @override
  _$RTCStatsType_RTCTransportStats get _value =>
      super._value as _$RTCStatsType_RTCTransportStats;

  @override
  $Res call({
    Object? packetsSent = freezed,
    Object? packetsReceived = freezed,
    Object? bytesSent = freezed,
    Object? bytesReceived = freezed,
  }) {
    return _then(_$RTCStatsType_RTCTransportStats(
      packetsSent: packetsSent == freezed
          ? _value.packetsSent
          : packetsSent // ignore: cast_nullable_to_non_nullable
              as int?,
      packetsReceived: packetsReceived == freezed
          ? _value.packetsReceived
          : packetsReceived // ignore: cast_nullable_to_non_nullable
              as int?,
      bytesSent: bytesSent == freezed
          ? _value.bytesSent
          : bytesSent // ignore: cast_nullable_to_non_nullable
              as int?,
      bytesReceived: bytesReceived == freezed
          ? _value.bytesReceived
          : bytesReceived // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCTransportStats
    implements RTCStatsType_RTCTransportStats {
  const _$RTCStatsType_RTCTransportStats(
      {this.packetsSent,
      this.packetsReceived,
      this.bytesSent,
      this.bytesReceived});

  @override
  final int? packetsSent;
  @override
  final int? packetsReceived;
  @override
  final int? bytesSent;
  @override
  final int? bytesReceived;

  @override
  String toString() {
    return 'RTCStatsType.rtcTransportStats(packetsSent: $packetsSent, packetsReceived: $packetsReceived, bytesSent: $bytesSent, bytesReceived: $bytesReceived)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCTransportStats &&
            const DeepCollectionEquality()
                .equals(other.packetsSent, packetsSent) &&
            const DeepCollectionEquality()
                .equals(other.packetsReceived, packetsReceived) &&
            const DeepCollectionEquality().equals(other.bytesSent, bytesSent) &&
            const DeepCollectionEquality()
                .equals(other.bytesReceived, bytesReceived));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(packetsSent),
      const DeepCollectionEquality().hash(packetsReceived),
      const DeepCollectionEquality().hash(bytesSent),
      const DeepCollectionEquality().hash(bytesReceived));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCTransportStatsCopyWith<_$RTCStatsType_RTCTransportStats>
      get copyWith => __$$RTCStatsType_RTCTransportStatsCopyWithImpl<
          _$RTCStatsType_RTCTransportStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcTransportStats(
        packetsSent, packetsReceived, bytesSent, bytesReceived);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcTransportStats?.call(
        packetsSent, packetsReceived, bytesSent, bytesReceived);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcTransportStats != null) {
      return rtcTransportStats(
          packetsSent, packetsReceived, bytesSent, bytesReceived);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcTransportStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcTransportStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcTransportStats != null) {
      return rtcTransportStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCTransportStats implements RTCStatsType {
  const factory RTCStatsType_RTCTransportStats(
      {final int? packetsSent,
      final int? packetsReceived,
      final int? bytesSent,
      final int? bytesReceived}) = _$RTCStatsType_RTCTransportStats;

  int? get packetsSent;
  int? get packetsReceived;
  int? get bytesSent;
  int? get bytesReceived;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCTransportStatsCopyWith<_$RTCStatsType_RTCTransportStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWith(
          _$RTCStatsType_RTCRemoteInboundRtpStreamStats value,
          $Res Function(_$RTCStatsType_RTCRemoteInboundRtpStreamStats) then) =
      __$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWithImpl<$Res>;
  $Res call(
      {String? localId,
      double? roundTripTime,
      double? fractionLost,
      int? roundTripTimeMeasurements});
}

/// @nodoc
class __$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWithImpl(
      _$RTCStatsType_RTCRemoteInboundRtpStreamStats _value,
      $Res Function(_$RTCStatsType_RTCRemoteInboundRtpStreamStats) _then)
      : super(_value,
            (v) => _then(v as _$RTCStatsType_RTCRemoteInboundRtpStreamStats));

  @override
  _$RTCStatsType_RTCRemoteInboundRtpStreamStats get _value =>
      super._value as _$RTCStatsType_RTCRemoteInboundRtpStreamStats;

  @override
  $Res call({
    Object? localId = freezed,
    Object? roundTripTime = freezed,
    Object? fractionLost = freezed,
    Object? roundTripTimeMeasurements = freezed,
  }) {
    return _then(_$RTCStatsType_RTCRemoteInboundRtpStreamStats(
      localId: localId == freezed
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as String?,
      roundTripTime: roundTripTime == freezed
          ? _value.roundTripTime
          : roundTripTime // ignore: cast_nullable_to_non_nullable
              as double?,
      fractionLost: fractionLost == freezed
          ? _value.fractionLost
          : fractionLost // ignore: cast_nullable_to_non_nullable
              as double?,
      roundTripTimeMeasurements: roundTripTimeMeasurements == freezed
          ? _value.roundTripTimeMeasurements
          : roundTripTimeMeasurements // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCRemoteInboundRtpStreamStats
    implements RTCStatsType_RTCRemoteInboundRtpStreamStats {
  const _$RTCStatsType_RTCRemoteInboundRtpStreamStats(
      {this.localId,
      this.roundTripTime,
      this.fractionLost,
      this.roundTripTimeMeasurements});

  @override
  final String? localId;
  @override
  final double? roundTripTime;
  @override
  final double? fractionLost;
  @override
  final int? roundTripTimeMeasurements;

  @override
  String toString() {
    return 'RTCStatsType.rtcRemoteInboundRtpStreamStats(localId: $localId, roundTripTime: $roundTripTime, fractionLost: $fractionLost, roundTripTimeMeasurements: $roundTripTimeMeasurements)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCRemoteInboundRtpStreamStats &&
            const DeepCollectionEquality().equals(other.localId, localId) &&
            const DeepCollectionEquality()
                .equals(other.roundTripTime, roundTripTime) &&
            const DeepCollectionEquality()
                .equals(other.fractionLost, fractionLost) &&
            const DeepCollectionEquality().equals(
                other.roundTripTimeMeasurements, roundTripTimeMeasurements));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(localId),
      const DeepCollectionEquality().hash(roundTripTime),
      const DeepCollectionEquality().hash(fractionLost),
      const DeepCollectionEquality().hash(roundTripTimeMeasurements));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWith<
          _$RTCStatsType_RTCRemoteInboundRtpStreamStats>
      get copyWith =>
          __$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWithImpl<
              _$RTCStatsType_RTCRemoteInboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcRemoteInboundRtpStreamStats(
        localId, roundTripTime, fractionLost, roundTripTimeMeasurements);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcRemoteInboundRtpStreamStats?.call(
        localId, roundTripTime, fractionLost, roundTripTimeMeasurements);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcRemoteInboundRtpStreamStats != null) {
      return rtcRemoteInboundRtpStreamStats(
          localId, roundTripTime, fractionLost, roundTripTimeMeasurements);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcRemoteInboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcRemoteInboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcRemoteInboundRtpStreamStats != null) {
      return rtcRemoteInboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCRemoteInboundRtpStreamStats
    implements RTCStatsType {
  const factory RTCStatsType_RTCRemoteInboundRtpStreamStats(
          {final String? localId,
          final double? roundTripTime,
          final double? fractionLost,
          final int? roundTripTimeMeasurements}) =
      _$RTCStatsType_RTCRemoteInboundRtpStreamStats;

  String? get localId;
  double? get roundTripTime;
  double? get fractionLost;
  int? get roundTripTimeMeasurements;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCRemoteInboundRtpStreamStatsCopyWith<
          _$RTCStatsType_RTCRemoteInboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWith<$Res> {
  factory _$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWith(
          _$RTCStatsType_RTCRemoteOutboundRtpStreamStats value,
          $Res Function(_$RTCStatsType_RTCRemoteOutboundRtpStreamStats) then) =
      __$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWithImpl<$Res>;
  $Res call({String? localId, double? remoteTimestamp, int? reportsSent});
}

/// @nodoc
class __$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWith<$Res> {
  __$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWithImpl(
      _$RTCStatsType_RTCRemoteOutboundRtpStreamStats _value,
      $Res Function(_$RTCStatsType_RTCRemoteOutboundRtpStreamStats) _then)
      : super(_value,
            (v) => _then(v as _$RTCStatsType_RTCRemoteOutboundRtpStreamStats));

  @override
  _$RTCStatsType_RTCRemoteOutboundRtpStreamStats get _value =>
      super._value as _$RTCStatsType_RTCRemoteOutboundRtpStreamStats;

  @override
  $Res call({
    Object? localId = freezed,
    Object? remoteTimestamp = freezed,
    Object? reportsSent = freezed,
  }) {
    return _then(_$RTCStatsType_RTCRemoteOutboundRtpStreamStats(
      localId: localId == freezed
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as String?,
      remoteTimestamp: remoteTimestamp == freezed
          ? _value.remoteTimestamp
          : remoteTimestamp // ignore: cast_nullable_to_non_nullable
              as double?,
      reportsSent: reportsSent == freezed
          ? _value.reportsSent
          : reportsSent // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RTCStatsType_RTCRemoteOutboundRtpStreamStats
    implements RTCStatsType_RTCRemoteOutboundRtpStreamStats {
  const _$RTCStatsType_RTCRemoteOutboundRtpStreamStats(
      {this.localId, this.remoteTimestamp, this.reportsSent});

  @override
  final String? localId;
  @override
  final double? remoteTimestamp;
  @override
  final int? reportsSent;

  @override
  String toString() {
    return 'RTCStatsType.rtcRemoteOutboundRtpStreamStats(localId: $localId, remoteTimestamp: $remoteTimestamp, reportsSent: $reportsSent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_RTCRemoteOutboundRtpStreamStats &&
            const DeepCollectionEquality().equals(other.localId, localId) &&
            const DeepCollectionEquality()
                .equals(other.remoteTimestamp, remoteTimestamp) &&
            const DeepCollectionEquality()
                .equals(other.reportsSent, reportsSent));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(localId),
      const DeepCollectionEquality().hash(remoteTimestamp),
      const DeepCollectionEquality().hash(reportsSent));

  @JsonKey(ignore: true)
  @override
  _$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWith<
          _$RTCStatsType_RTCRemoteOutboundRtpStreamStats>
      get copyWith =>
          __$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWithImpl<
              _$RTCStatsType_RTCRemoteOutboundRtpStreamStats>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return rtcRemoteOutboundRtpStreamStats(
        localId, remoteTimestamp, reportsSent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return rtcRemoteOutboundRtpStreamStats?.call(
        localId, remoteTimestamp, reportsSent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcRemoteOutboundRtpStreamStats != null) {
      return rtcRemoteOutboundRtpStreamStats(
          localId, remoteTimestamp, reportsSent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return rtcRemoteOutboundRtpStreamStats(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return rtcRemoteOutboundRtpStreamStats?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (rtcRemoteOutboundRtpStreamStats != null) {
      return rtcRemoteOutboundRtpStreamStats(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_RTCRemoteOutboundRtpStreamStats
    implements RTCStatsType {
  const factory RTCStatsType_RTCRemoteOutboundRtpStreamStats(
      {final String? localId,
      final double? remoteTimestamp,
      final int? reportsSent}) = _$RTCStatsType_RTCRemoteOutboundRtpStreamStats;

  String? get localId;
  double? get remoteTimestamp;
  int? get reportsSent;
  @JsonKey(ignore: true)
  _$$RTCStatsType_RTCRemoteOutboundRtpStreamStatsCopyWith<
          _$RTCStatsType_RTCRemoteOutboundRtpStreamStats>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RTCStatsType_UnimplenentedCopyWith<$Res> {
  factory _$$RTCStatsType_UnimplenentedCopyWith(
          _$RTCStatsType_Unimplenented value,
          $Res Function(_$RTCStatsType_Unimplenented) then) =
      __$$RTCStatsType_UnimplenentedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RTCStatsType_UnimplenentedCopyWithImpl<$Res>
    extends _$RTCStatsTypeCopyWithImpl<$Res>
    implements _$$RTCStatsType_UnimplenentedCopyWith<$Res> {
  __$$RTCStatsType_UnimplenentedCopyWithImpl(
      _$RTCStatsType_Unimplenented _value,
      $Res Function(_$RTCStatsType_Unimplenented) _then)
      : super(_value, (v) => _then(v as _$RTCStatsType_Unimplenented));

  @override
  _$RTCStatsType_Unimplenented get _value =>
      super._value as _$RTCStatsType_Unimplenented;
}

/// @nodoc

class _$RTCStatsType_Unimplenented implements RTCStatsType_Unimplenented {
  const _$RTCStatsType_Unimplenented();

  @override
  String toString() {
    return 'RTCStatsType.unimplenented()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RTCStatsType_Unimplenented);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? trackIdentifier, RTCMediaSourceStatsType kind)
        rtcMediaSourceStats,
    required TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)
        rtcIceCandidateStats,
    required TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)
        rtcOutboundRtpStreamStats,
    required TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)
        rtcInboundRtpStreamStats,
    required TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)
        rtcIceCandidatePairStats,
    required TResult Function(int? packetsSent, int? packetsReceived,
            int? bytesSent, int? bytesReceived)
        rtcTransportStats,
    required TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function() unimplenented,
  }) {
    return unimplenented();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
  }) {
    return unimplenented?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? trackIdentifier, RTCMediaSourceStatsType kind)?
        rtcMediaSourceStats,
    TResult Function(
            String? transportId,
            String? address,
            int? port,
            String? protocol,
            CandidateType candidateType,
            int? priority,
            String? url,
            bool? isRemote)?
        rtcIceCandidateStats,
    TResult Function(
            String? trackId,
            TrackKind kind,
            int? frameWidth,
            int? frameHeight,
            double? framesPerSecond,
            int? bytesSent,
            int? packetsSent,
            String? mediaSourceId)?
        rtcOutboundRtpStreamStats,
    TResult Function(
            String? remoteId,
            int? bytesReceived,
            int? packetsReceived,
            double? totalDecodeTime,
            int? jitterBufferEmittedCount,
            RTCInboundRtpStreamMediaType? mediaType)?
        rtcInboundRtpStreamStats,
    TResult Function(
            RTCStatsIceCandidatePairState state,
            bool? nominated,
            int? bytesSent,
            int? bytesReceived,
            double? totalRoundTripTime,
            double? currentRoundTripTime,
            double? availableOutgoingBitrate)?
        rtcIceCandidatePairStats,
    TResult Function(int? packetsSent, int? packetsReceived, int? bytesSent,
            int? bytesReceived)?
        rtcTransportStats,
    TResult Function(String? localId, double? roundTripTime,
            double? fractionLost, int? roundTripTimeMeasurements)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(
            String? localId, double? remoteTimestamp, int? reportsSent)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function()? unimplenented,
    required TResult orElse(),
  }) {
    if (unimplenented != null) {
      return unimplenented();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RTCStatsType_RTCMediaSourceStats value)
        rtcMediaSourceStats,
    required TResult Function(RTCStatsType_RTCIceCandidateStats value)
        rtcIceCandidateStats,
    required TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)
        rtcOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)
        rtcInboundRtpStreamStats,
    required TResult Function(RTCStatsType_RTCIceCandidatePairStats value)
        rtcIceCandidatePairStats,
    required TResult Function(RTCStatsType_RTCTransportStats value)
        rtcTransportStats,
    required TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)
        rtcRemoteInboundRtpStreamStats,
    required TResult Function(
            RTCStatsType_RTCRemoteOutboundRtpStreamStats value)
        rtcRemoteOutboundRtpStreamStats,
    required TResult Function(RTCStatsType_Unimplenented value) unimplenented,
  }) {
    return unimplenented(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
  }) {
    return unimplenented?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RTCStatsType_RTCMediaSourceStats value)?
        rtcMediaSourceStats,
    TResult Function(RTCStatsType_RTCIceCandidateStats value)?
        rtcIceCandidateStats,
    TResult Function(RTCStatsType_RTCOutboundRTPStreamStats value)?
        rtcOutboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCInboundRTPStreamStats value)?
        rtcInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCIceCandidatePairStats value)?
        rtcIceCandidatePairStats,
    TResult Function(RTCStatsType_RTCTransportStats value)? rtcTransportStats,
    TResult Function(RTCStatsType_RTCRemoteInboundRtpStreamStats value)?
        rtcRemoteInboundRtpStreamStats,
    TResult Function(RTCStatsType_RTCRemoteOutboundRtpStreamStats value)?
        rtcRemoteOutboundRtpStreamStats,
    TResult Function(RTCStatsType_Unimplenented value)? unimplenented,
    required TResult orElse(),
  }) {
    if (unimplenented != null) {
      return unimplenented(this);
    }
    return orElse();
  }
}

abstract class RTCStatsType_Unimplenented implements RTCStatsType {
  const factory RTCStatsType_Unimplenented() = _$RTCStatsType_Unimplenented;
}
