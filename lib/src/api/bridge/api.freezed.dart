// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetMediaError {

 String get field0;
/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaErrorCopyWith<GetMediaError> get copyWith => _$GetMediaErrorCopyWithImpl<GetMediaError>(this as GetMediaError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaErrorCopyWith<$Res>  {
  factory $GetMediaErrorCopyWith(GetMediaError value, $Res Function(GetMediaError) _then) = _$GetMediaErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaErrorCopyWithImpl<$Res>
    implements $GetMediaErrorCopyWith<$Res> {
  _$GetMediaErrorCopyWithImpl(this._self, this._then);

  final GetMediaError _self;
  final $Res Function(GetMediaError) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field0 = null,}) {
  return _then(_self.copyWith(
field0: null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GetMediaError].
extension GetMediaErrorPatterns on GetMediaError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetMediaError_Audio value)?  audio,TResult Function( GetMediaError_Video value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that);case GetMediaError_Video() when video != null:
return video(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetMediaError_Audio value)  audio,required TResult Function( GetMediaError_Video value)  video,}){
final _that = this;
switch (_that) {
case GetMediaError_Audio():
return audio(_that);case GetMediaError_Video():
return video(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetMediaError_Audio value)?  audio,TResult? Function( GetMediaError_Video value)?  video,}){
final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that);case GetMediaError_Video() when video != null:
return video(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String field0)?  audio,TResult Function( String field0)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that.field0);case GetMediaError_Video() when video != null:
return video(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String field0)  audio,required TResult Function( String field0)  video,}) {final _that = this;
switch (_that) {
case GetMediaError_Audio():
return audio(_that.field0);case GetMediaError_Video():
return video(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String field0)?  audio,TResult? Function( String field0)?  video,}) {final _that = this;
switch (_that) {
case GetMediaError_Audio() when audio != null:
return audio(_that.field0);case GetMediaError_Video() when video != null:
return video(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class GetMediaError_Audio extends GetMediaError {
  const GetMediaError_Audio(this.field0): super._();
  

@override final  String field0;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaError_AudioCopyWith<GetMediaError_Audio> get copyWith => _$GetMediaError_AudioCopyWithImpl<GetMediaError_Audio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError_Audio&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError.audio(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaError_AudioCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaError_AudioCopyWith(GetMediaError_Audio value, $Res Function(GetMediaError_Audio) _then) = _$GetMediaError_AudioCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaError_AudioCopyWithImpl<$Res>
    implements $GetMediaError_AudioCopyWith<$Res> {
  _$GetMediaError_AudioCopyWithImpl(this._self, this._then);

  final GetMediaError_Audio _self;
  final $Res Function(GetMediaError_Audio) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaError_Audio(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GetMediaError_Video extends GetMediaError {
  const GetMediaError_Video(this.field0): super._();
  

@override final  String field0;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaError_VideoCopyWith<GetMediaError_Video> get copyWith => _$GetMediaError_VideoCopyWithImpl<GetMediaError_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaError_Video&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaError.video(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaError_VideoCopyWith<$Res> implements $GetMediaErrorCopyWith<$Res> {
  factory $GetMediaError_VideoCopyWith(GetMediaError_Video value, $Res Function(GetMediaError_Video) _then) = _$GetMediaError_VideoCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$GetMediaError_VideoCopyWithImpl<$Res>
    implements $GetMediaError_VideoCopyWith<$Res> {
  _$GetMediaError_VideoCopyWithImpl(this._self, this._then);

  final GetMediaError_Video _self;
  final $Res Function(GetMediaError_Video) _then;

/// Create a copy of GetMediaError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaError_Video(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GetMediaResult {

 Object get field0;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult&&const DeepCollectionEquality().equals(other.field0, field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(field0));

@override
String toString() {
  return 'GetMediaResult(field0: $field0)';
}


}

/// @nodoc
class $GetMediaResultCopyWith<$Res>  {
$GetMediaResultCopyWith(GetMediaResult _, $Res Function(GetMediaResult) __);
}


/// Adds pattern-matching-related methods to [GetMediaResult].
extension GetMediaResultPatterns on GetMediaResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetMediaResult_Ok value)?  ok,TResult Function( GetMediaResult_Err value)?  err,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that);case GetMediaResult_Err() when err != null:
return err(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetMediaResult_Ok value)  ok,required TResult Function( GetMediaResult_Err value)  err,}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok():
return ok(_that);case GetMediaResult_Err():
return err(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetMediaResult_Ok value)?  ok,TResult? Function( GetMediaResult_Err value)?  err,}){
final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that);case GetMediaResult_Err() when err != null:
return err(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<MediaStreamTrack> field0)?  ok,TResult Function( GetMediaError field0)?  err,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that.field0);case GetMediaResult_Err() when err != null:
return err(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<MediaStreamTrack> field0)  ok,required TResult Function( GetMediaError field0)  err,}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok():
return ok(_that.field0);case GetMediaResult_Err():
return err(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<MediaStreamTrack> field0)?  ok,TResult? Function( GetMediaError field0)?  err,}) {final _that = this;
switch (_that) {
case GetMediaResult_Ok() when ok != null:
return ok(_that.field0);case GetMediaResult_Err() when err != null:
return err(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class GetMediaResult_Ok extends GetMediaResult {
  const GetMediaResult_Ok(final  List<MediaStreamTrack> field0): _field0 = field0,super._();
  

 final  List<MediaStreamTrack> _field0;
@override List<MediaStreamTrack> get field0 {
  if (_field0 is EqualUnmodifiableListView) return _field0;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_field0);
}


/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaResult_OkCopyWith<GetMediaResult_Ok> get copyWith => _$GetMediaResult_OkCopyWithImpl<GetMediaResult_Ok>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult_Ok&&const DeepCollectionEquality().equals(other._field0, _field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_field0));

@override
String toString() {
  return 'GetMediaResult.ok(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaResult_OkCopyWith<$Res> implements $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResult_OkCopyWith(GetMediaResult_Ok value, $Res Function(GetMediaResult_Ok) _then) = _$GetMediaResult_OkCopyWithImpl;
@useResult
$Res call({
 List<MediaStreamTrack> field0
});




}
/// @nodoc
class _$GetMediaResult_OkCopyWithImpl<$Res>
    implements $GetMediaResult_OkCopyWith<$Res> {
  _$GetMediaResult_OkCopyWithImpl(this._self, this._then);

  final GetMediaResult_Ok _self;
  final $Res Function(GetMediaResult_Ok) _then;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaResult_Ok(
null == field0 ? _self._field0 : field0 // ignore: cast_nullable_to_non_nullable
as List<MediaStreamTrack>,
  ));
}


}

/// @nodoc


class GetMediaResult_Err extends GetMediaResult {
  const GetMediaResult_Err(this.field0): super._();
  

@override final  GetMediaError field0;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetMediaResult_ErrCopyWith<GetMediaResult_Err> get copyWith => _$GetMediaResult_ErrCopyWithImpl<GetMediaResult_Err>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetMediaResult_Err&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'GetMediaResult.err(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $GetMediaResult_ErrCopyWith<$Res> implements $GetMediaResultCopyWith<$Res> {
  factory $GetMediaResult_ErrCopyWith(GetMediaResult_Err value, $Res Function(GetMediaResult_Err) _then) = _$GetMediaResult_ErrCopyWithImpl;
@useResult
$Res call({
 GetMediaError field0
});


$GetMediaErrorCopyWith<$Res> get field0;

}
/// @nodoc
class _$GetMediaResult_ErrCopyWithImpl<$Res>
    implements $GetMediaResult_ErrCopyWith<$Res> {
  _$GetMediaResult_ErrCopyWithImpl(this._self, this._then);

  final GetMediaResult_Err _self;
  final $Res Function(GetMediaResult_Err) _then;

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(GetMediaResult_Err(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as GetMediaError,
  ));
}

/// Create a copy of GetMediaResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GetMediaErrorCopyWith<$Res> get field0 {
  
  return $GetMediaErrorCopyWith<$Res>(_self.field0, (value) {
    return _then(_self.copyWith(field0: value));
  });
}
}

/// @nodoc
mixin _$PeerConnectionEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PeerConnectionEvent()';
}


}

/// @nodoc
class $PeerConnectionEventCopyWith<$Res>  {
$PeerConnectionEventCopyWith(PeerConnectionEvent _, $Res Function(PeerConnectionEvent) __);
}


/// Adds pattern-matching-related methods to [PeerConnectionEvent].
extension PeerConnectionEventPatterns on PeerConnectionEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PeerConnectionEvent_PeerCreated value)?  peerCreated,TResult Function( PeerConnectionEvent_IceCandidate value)?  iceCandidate,TResult Function( PeerConnectionEvent_IceGatheringStateChange value)?  iceGatheringStateChange,TResult Function( PeerConnectionEvent_IceCandidateError value)?  iceCandidateError,TResult Function( PeerConnectionEvent_NegotiationNeeded value)?  negotiationNeeded,TResult Function( PeerConnectionEvent_SignallingChange value)?  signallingChange,TResult Function( PeerConnectionEvent_IceConnectionStateChange value)?  iceConnectionStateChange,TResult Function( PeerConnectionEvent_ConnectionStateChange value)?  connectionStateChange,TResult Function( PeerConnectionEvent_Track value)?  track,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated() when peerCreated != null:
return peerCreated(_that);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that);case PeerConnectionEvent_IceGatheringStateChange() when iceGatheringStateChange != null:
return iceGatheringStateChange(_that);case PeerConnectionEvent_IceCandidateError() when iceCandidateError != null:
return iceCandidateError(_that);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded(_that);case PeerConnectionEvent_SignallingChange() when signallingChange != null:
return signallingChange(_that);case PeerConnectionEvent_IceConnectionStateChange() when iceConnectionStateChange != null:
return iceConnectionStateChange(_that);case PeerConnectionEvent_ConnectionStateChange() when connectionStateChange != null:
return connectionStateChange(_that);case PeerConnectionEvent_Track() when track != null:
return track(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PeerConnectionEvent_PeerCreated value)  peerCreated,required TResult Function( PeerConnectionEvent_IceCandidate value)  iceCandidate,required TResult Function( PeerConnectionEvent_IceGatheringStateChange value)  iceGatheringStateChange,required TResult Function( PeerConnectionEvent_IceCandidateError value)  iceCandidateError,required TResult Function( PeerConnectionEvent_NegotiationNeeded value)  negotiationNeeded,required TResult Function( PeerConnectionEvent_SignallingChange value)  signallingChange,required TResult Function( PeerConnectionEvent_IceConnectionStateChange value)  iceConnectionStateChange,required TResult Function( PeerConnectionEvent_ConnectionStateChange value)  connectionStateChange,required TResult Function( PeerConnectionEvent_Track value)  track,}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated():
return peerCreated(_that);case PeerConnectionEvent_IceCandidate():
return iceCandidate(_that);case PeerConnectionEvent_IceGatheringStateChange():
return iceGatheringStateChange(_that);case PeerConnectionEvent_IceCandidateError():
return iceCandidateError(_that);case PeerConnectionEvent_NegotiationNeeded():
return negotiationNeeded(_that);case PeerConnectionEvent_SignallingChange():
return signallingChange(_that);case PeerConnectionEvent_IceConnectionStateChange():
return iceConnectionStateChange(_that);case PeerConnectionEvent_ConnectionStateChange():
return connectionStateChange(_that);case PeerConnectionEvent_Track():
return track(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PeerConnectionEvent_PeerCreated value)?  peerCreated,TResult? Function( PeerConnectionEvent_IceCandidate value)?  iceCandidate,TResult? Function( PeerConnectionEvent_IceGatheringStateChange value)?  iceGatheringStateChange,TResult? Function( PeerConnectionEvent_IceCandidateError value)?  iceCandidateError,TResult? Function( PeerConnectionEvent_NegotiationNeeded value)?  negotiationNeeded,TResult? Function( PeerConnectionEvent_SignallingChange value)?  signallingChange,TResult? Function( PeerConnectionEvent_IceConnectionStateChange value)?  iceConnectionStateChange,TResult? Function( PeerConnectionEvent_ConnectionStateChange value)?  connectionStateChange,TResult? Function( PeerConnectionEvent_Track value)?  track,}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated() when peerCreated != null:
return peerCreated(_that);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that);case PeerConnectionEvent_IceGatheringStateChange() when iceGatheringStateChange != null:
return iceGatheringStateChange(_that);case PeerConnectionEvent_IceCandidateError() when iceCandidateError != null:
return iceCandidateError(_that);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded(_that);case PeerConnectionEvent_SignallingChange() when signallingChange != null:
return signallingChange(_that);case PeerConnectionEvent_IceConnectionStateChange() when iceConnectionStateChange != null:
return iceConnectionStateChange(_that);case PeerConnectionEvent_ConnectionStateChange() when connectionStateChange != null:
return connectionStateChange(_that);case PeerConnectionEvent_Track() when track != null:
return track(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ArcPeerConnection peer)?  peerCreated,TResult Function( String sdpMid,  int sdpMlineIndex,  String candidate)?  iceCandidate,TResult Function( IceGatheringState field0)?  iceGatheringStateChange,TResult Function( String address,  int port,  String url,  int errorCode,  String errorText)?  iceCandidateError,TResult Function()?  negotiationNeeded,TResult Function( SignalingState field0)?  signallingChange,TResult Function( IceConnectionState field0)?  iceConnectionStateChange,TResult Function( PeerConnectionState field0)?  connectionStateChange,TResult Function( RtcTrackEvent field0)?  track,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated() when peerCreated != null:
return peerCreated(_that.peer);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that.sdpMid,_that.sdpMlineIndex,_that.candidate);case PeerConnectionEvent_IceGatheringStateChange() when iceGatheringStateChange != null:
return iceGatheringStateChange(_that.field0);case PeerConnectionEvent_IceCandidateError() when iceCandidateError != null:
return iceCandidateError(_that.address,_that.port,_that.url,_that.errorCode,_that.errorText);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded();case PeerConnectionEvent_SignallingChange() when signallingChange != null:
return signallingChange(_that.field0);case PeerConnectionEvent_IceConnectionStateChange() when iceConnectionStateChange != null:
return iceConnectionStateChange(_that.field0);case PeerConnectionEvent_ConnectionStateChange() when connectionStateChange != null:
return connectionStateChange(_that.field0);case PeerConnectionEvent_Track() when track != null:
return track(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ArcPeerConnection peer)  peerCreated,required TResult Function( String sdpMid,  int sdpMlineIndex,  String candidate)  iceCandidate,required TResult Function( IceGatheringState field0)  iceGatheringStateChange,required TResult Function( String address,  int port,  String url,  int errorCode,  String errorText)  iceCandidateError,required TResult Function()  negotiationNeeded,required TResult Function( SignalingState field0)  signallingChange,required TResult Function( IceConnectionState field0)  iceConnectionStateChange,required TResult Function( PeerConnectionState field0)  connectionStateChange,required TResult Function( RtcTrackEvent field0)  track,}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated():
return peerCreated(_that.peer);case PeerConnectionEvent_IceCandidate():
return iceCandidate(_that.sdpMid,_that.sdpMlineIndex,_that.candidate);case PeerConnectionEvent_IceGatheringStateChange():
return iceGatheringStateChange(_that.field0);case PeerConnectionEvent_IceCandidateError():
return iceCandidateError(_that.address,_that.port,_that.url,_that.errorCode,_that.errorText);case PeerConnectionEvent_NegotiationNeeded():
return negotiationNeeded();case PeerConnectionEvent_SignallingChange():
return signallingChange(_that.field0);case PeerConnectionEvent_IceConnectionStateChange():
return iceConnectionStateChange(_that.field0);case PeerConnectionEvent_ConnectionStateChange():
return connectionStateChange(_that.field0);case PeerConnectionEvent_Track():
return track(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ArcPeerConnection peer)?  peerCreated,TResult? Function( String sdpMid,  int sdpMlineIndex,  String candidate)?  iceCandidate,TResult? Function( IceGatheringState field0)?  iceGatheringStateChange,TResult? Function( String address,  int port,  String url,  int errorCode,  String errorText)?  iceCandidateError,TResult? Function()?  negotiationNeeded,TResult? Function( SignalingState field0)?  signallingChange,TResult? Function( IceConnectionState field0)?  iceConnectionStateChange,TResult? Function( PeerConnectionState field0)?  connectionStateChange,TResult? Function( RtcTrackEvent field0)?  track,}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_PeerCreated() when peerCreated != null:
return peerCreated(_that.peer);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that.sdpMid,_that.sdpMlineIndex,_that.candidate);case PeerConnectionEvent_IceGatheringStateChange() when iceGatheringStateChange != null:
return iceGatheringStateChange(_that.field0);case PeerConnectionEvent_IceCandidateError() when iceCandidateError != null:
return iceCandidateError(_that.address,_that.port,_that.url,_that.errorCode,_that.errorText);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded();case PeerConnectionEvent_SignallingChange() when signallingChange != null:
return signallingChange(_that.field0);case PeerConnectionEvent_IceConnectionStateChange() when iceConnectionStateChange != null:
return iceConnectionStateChange(_that.field0);case PeerConnectionEvent_ConnectionStateChange() when connectionStateChange != null:
return connectionStateChange(_that.field0);case PeerConnectionEvent_Track() when track != null:
return track(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class PeerConnectionEvent_PeerCreated extends PeerConnectionEvent {
  const PeerConnectionEvent_PeerCreated({required this.peer}): super._();
  

/// Rust side [`PeerConnection`].
 final  ArcPeerConnection peer;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_PeerCreatedCopyWith<PeerConnectionEvent_PeerCreated> get copyWith => _$PeerConnectionEvent_PeerCreatedCopyWithImpl<PeerConnectionEvent_PeerCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_PeerCreated&&(identical(other.peer, peer) || other.peer == peer));
}


@override
int get hashCode => Object.hash(runtimeType,peer);

@override
String toString() {
  return 'PeerConnectionEvent.peerCreated(peer: $peer)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_PeerCreatedCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_PeerCreatedCopyWith(PeerConnectionEvent_PeerCreated value, $Res Function(PeerConnectionEvent_PeerCreated) _then) = _$PeerConnectionEvent_PeerCreatedCopyWithImpl;
@useResult
$Res call({
 ArcPeerConnection peer
});




}
/// @nodoc
class _$PeerConnectionEvent_PeerCreatedCopyWithImpl<$Res>
    implements $PeerConnectionEvent_PeerCreatedCopyWith<$Res> {
  _$PeerConnectionEvent_PeerCreatedCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_PeerCreated _self;
  final $Res Function(PeerConnectionEvent_PeerCreated) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? peer = null,}) {
  return _then(PeerConnectionEvent_PeerCreated(
peer: null == peer ? _self.peer : peer // ignore: cast_nullable_to_non_nullable
as ArcPeerConnection,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceCandidate extends PeerConnectionEvent {
  const PeerConnectionEvent_IceCandidate({required this.sdpMid, required this.sdpMlineIndex, required this.candidate}): super._();
  

/// Media stream "identification-tag" defined in [RFC 5888] for the
/// media component the discovered [RTCIceCandidate][1] is associated
/// with.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
/// [RFC 5888]: https://tools.ietf.org/html/rfc5888
 final  String sdpMid;
/// Index (starting at zero) of the media description in the SDP this
/// [RTCIceCandidate][1] is associated with.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
 final  int sdpMlineIndex;
/// Candidate-attribute as defined in Section 15.1 of [RFC 5245].
///
/// If this [RTCIceCandidate][1] represents an end-of-candidates
/// indication or a peer reflexive remote candidate, candidate is an
/// empty string.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
 final  String candidate;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceCandidateCopyWith<PeerConnectionEvent_IceCandidate> get copyWith => _$PeerConnectionEvent_IceCandidateCopyWithImpl<PeerConnectionEvent_IceCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceCandidate&&(identical(other.sdpMid, sdpMid) || other.sdpMid == sdpMid)&&(identical(other.sdpMlineIndex, sdpMlineIndex) || other.sdpMlineIndex == sdpMlineIndex)&&(identical(other.candidate, candidate) || other.candidate == candidate));
}


@override
int get hashCode => Object.hash(runtimeType,sdpMid,sdpMlineIndex,candidate);

@override
String toString() {
  return 'PeerConnectionEvent.iceCandidate(sdpMid: $sdpMid, sdpMlineIndex: $sdpMlineIndex, candidate: $candidate)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceCandidateCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceCandidateCopyWith(PeerConnectionEvent_IceCandidate value, $Res Function(PeerConnectionEvent_IceCandidate) _then) = _$PeerConnectionEvent_IceCandidateCopyWithImpl;
@useResult
$Res call({
 String sdpMid, int sdpMlineIndex, String candidate
});




}
/// @nodoc
class _$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  _$PeerConnectionEvent_IceCandidateCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceCandidate _self;
  final $Res Function(PeerConnectionEvent_IceCandidate) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sdpMid = null,Object? sdpMlineIndex = null,Object? candidate = null,}) {
  return _then(PeerConnectionEvent_IceCandidate(
sdpMid: null == sdpMid ? _self.sdpMid : sdpMid // ignore: cast_nullable_to_non_nullable
as String,sdpMlineIndex: null == sdpMlineIndex ? _self.sdpMlineIndex : sdpMlineIndex // ignore: cast_nullable_to_non_nullable
as int,candidate: null == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceGatheringStateChange extends PeerConnectionEvent {
  const PeerConnectionEvent_IceGatheringStateChange(this.field0): super._();
  

 final  IceGatheringState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceGatheringStateChangeCopyWith<PeerConnectionEvent_IceGatheringStateChange> get copyWith => _$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<PeerConnectionEvent_IceGatheringStateChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceGatheringStateChange&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PeerConnectionEvent.iceGatheringStateChange(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceGatheringStateChangeCopyWith(PeerConnectionEvent_IceGatheringStateChange value, $Res Function(PeerConnectionEvent_IceGatheringStateChange) _then) = _$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl;
@useResult
$Res call({
 IceGatheringState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceGatheringStateChangeCopyWith<$Res> {
  _$PeerConnectionEvent_IceGatheringStateChangeCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceGatheringStateChange _self;
  final $Res Function(PeerConnectionEvent_IceGatheringStateChange) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_IceGatheringStateChange(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceGatheringState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceCandidateError extends PeerConnectionEvent {
  const PeerConnectionEvent_IceCandidateError({required this.address, required this.port, required this.url, required this.errorCode, required this.errorText}): super._();
  

/// Local IP address used to communicate with the STUN or TURN server.
 final  String address;
/// Port used to communicate with the STUN or TURN server.
 final  int port;
/// STUN or TURN URL identifying the STUN or TURN server for which the
/// failure occurred.
 final  String url;
/// Numeric STUN error code returned by the STUN or TURN server
/// [`STUN-PARAMETERS`][1].
///
/// If no host candidate can reach the server, it will be set to the
/// value `701` which is outside the STUN error code range.
///
/// [1]: https://tinyurl.com/stun-parameters-6
 final  int errorCode;
/// STUN reason text returned by the STUN or TURN server
/// [`STUN-PARAMETERS`][1].
///
/// If the server could not be reached, it will be set to an
/// implementation-specific value providing details about the error.
///
/// [1]: https://tinyurl.com/stun-parameters-6
 final  String errorText;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceCandidateErrorCopyWith<PeerConnectionEvent_IceCandidateError> get copyWith => _$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<PeerConnectionEvent_IceCandidateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceCandidateError&&(identical(other.address, address) || other.address == address)&&(identical(other.port, port) || other.port == port)&&(identical(other.url, url) || other.url == url)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorText, errorText) || other.errorText == errorText));
}


@override
int get hashCode => Object.hash(runtimeType,address,port,url,errorCode,errorText);

@override
String toString() {
  return 'PeerConnectionEvent.iceCandidateError(address: $address, port: $port, url: $url, errorCode: $errorCode, errorText: $errorText)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceCandidateErrorCopyWith(PeerConnectionEvent_IceCandidateError value, $Res Function(PeerConnectionEvent_IceCandidateError) _then) = _$PeerConnectionEvent_IceCandidateErrorCopyWithImpl;
@useResult
$Res call({
 String address, int port, String url, int errorCode, String errorText
});




}
/// @nodoc
class _$PeerConnectionEvent_IceCandidateErrorCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceCandidateErrorCopyWith<$Res> {
  _$PeerConnectionEvent_IceCandidateErrorCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceCandidateError _self;
  final $Res Function(PeerConnectionEvent_IceCandidateError) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? address = null,Object? port = null,Object? url = null,Object? errorCode = null,Object? errorText = null,}) {
  return _then(PeerConnectionEvent_IceCandidateError(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as int,errorText: null == errorText ? _self.errorText : errorText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_NegotiationNeeded extends PeerConnectionEvent {
  const PeerConnectionEvent_NegotiationNeeded(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_NegotiationNeeded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PeerConnectionEvent.negotiationNeeded()';
}


}




/// @nodoc


class PeerConnectionEvent_SignallingChange extends PeerConnectionEvent {
  const PeerConnectionEvent_SignallingChange(this.field0): super._();
  

 final  SignalingState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_SignallingChangeCopyWith<PeerConnectionEvent_SignallingChange> get copyWith => _$PeerConnectionEvent_SignallingChangeCopyWithImpl<PeerConnectionEvent_SignallingChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_SignallingChange&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PeerConnectionEvent.signallingChange(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_SignallingChangeCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_SignallingChangeCopyWith(PeerConnectionEvent_SignallingChange value, $Res Function(PeerConnectionEvent_SignallingChange) _then) = _$PeerConnectionEvent_SignallingChangeCopyWithImpl;
@useResult
$Res call({
 SignalingState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_SignallingChangeCopyWithImpl<$Res>
    implements $PeerConnectionEvent_SignallingChangeCopyWith<$Res> {
  _$PeerConnectionEvent_SignallingChangeCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_SignallingChange _self;
  final $Res Function(PeerConnectionEvent_SignallingChange) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_SignallingChange(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as SignalingState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceConnectionStateChange extends PeerConnectionEvent {
  const PeerConnectionEvent_IceConnectionStateChange(this.field0): super._();
  

 final  IceConnectionState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceConnectionStateChangeCopyWith<PeerConnectionEvent_IceConnectionStateChange> get copyWith => _$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<PeerConnectionEvent_IceConnectionStateChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceConnectionStateChange&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PeerConnectionEvent.iceConnectionStateChange(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceConnectionStateChangeCopyWith(PeerConnectionEvent_IceConnectionStateChange value, $Res Function(PeerConnectionEvent_IceConnectionStateChange) _then) = _$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl;
@useResult
$Res call({
 IceConnectionState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceConnectionStateChangeCopyWith<$Res> {
  _$PeerConnectionEvent_IceConnectionStateChangeCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceConnectionStateChange _self;
  final $Res Function(PeerConnectionEvent_IceConnectionStateChange) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_IceConnectionStateChange(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceConnectionState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_ConnectionStateChange extends PeerConnectionEvent {
  const PeerConnectionEvent_ConnectionStateChange(this.field0): super._();
  

 final  PeerConnectionState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_ConnectionStateChangeCopyWith<PeerConnectionEvent_ConnectionStateChange> get copyWith => _$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<PeerConnectionEvent_ConnectionStateChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_ConnectionStateChange&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PeerConnectionEvent.connectionStateChange(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_ConnectionStateChangeCopyWith(PeerConnectionEvent_ConnectionStateChange value, $Res Function(PeerConnectionEvent_ConnectionStateChange) _then) = _$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl;
@useResult
$Res call({
 PeerConnectionState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl<$Res>
    implements $PeerConnectionEvent_ConnectionStateChangeCopyWith<$Res> {
  _$PeerConnectionEvent_ConnectionStateChangeCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_ConnectionStateChange _self;
  final $Res Function(PeerConnectionEvent_ConnectionStateChange) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_ConnectionStateChange(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as PeerConnectionState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_Track extends PeerConnectionEvent {
  const PeerConnectionEvent_Track(this.field0): super._();
  

 final  RtcTrackEvent field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_TrackCopyWith<PeerConnectionEvent_Track> get copyWith => _$PeerConnectionEvent_TrackCopyWithImpl<PeerConnectionEvent_Track>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_Track&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PeerConnectionEvent.track(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_TrackCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_TrackCopyWith(PeerConnectionEvent_Track value, $Res Function(PeerConnectionEvent_Track) _then) = _$PeerConnectionEvent_TrackCopyWithImpl;
@useResult
$Res call({
 RtcTrackEvent field0
});




}
/// @nodoc
class _$PeerConnectionEvent_TrackCopyWithImpl<$Res>
    implements $PeerConnectionEvent_TrackCopyWith<$Res> {
  _$PeerConnectionEvent_TrackCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_Track _self;
  final $Res Function(PeerConnectionEvent_Track) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_Track(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as RtcTrackEvent,
  ));
}


}

/// @nodoc
mixin _$TrackEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent()';
}


}

/// @nodoc
class $TrackEventCopyWith<$Res>  {
$TrackEventCopyWith(TrackEvent _, $Res Function(TrackEvent) __);
}


/// Adds pattern-matching-related methods to [TrackEvent].
extension TrackEventPatterns on TrackEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TrackEvent_Ended value)?  ended,TResult Function( TrackEvent_AudioLevelUpdated value)?  audioLevelUpdated,TResult Function( TrackEvent_TrackCreated value)?  trackCreated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended(_that);case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TrackEvent_Ended value)  ended,required TResult Function( TrackEvent_AudioLevelUpdated value)  audioLevelUpdated,required TResult Function( TrackEvent_TrackCreated value)  trackCreated,}){
final _that = this;
switch (_that) {
case TrackEvent_Ended():
return ended(_that);case TrackEvent_AudioLevelUpdated():
return audioLevelUpdated(_that);case TrackEvent_TrackCreated():
return trackCreated(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TrackEvent_Ended value)?  ended,TResult? Function( TrackEvent_AudioLevelUpdated value)?  audioLevelUpdated,TResult? Function( TrackEvent_TrackCreated value)?  trackCreated,}){
final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended(_that);case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ended,TResult Function( int field0)?  audioLevelUpdated,TResult Function()?  trackCreated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended();case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ended,required TResult Function( int field0)  audioLevelUpdated,required TResult Function()  trackCreated,}) {final _that = this;
switch (_that) {
case TrackEvent_Ended():
return ended();case TrackEvent_AudioLevelUpdated():
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated():
return trackCreated();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ended,TResult? Function( int field0)?  audioLevelUpdated,TResult? Function()?  trackCreated,}) {final _that = this;
switch (_that) {
case TrackEvent_Ended() when ended != null:
return ended();case TrackEvent_AudioLevelUpdated() when audioLevelUpdated != null:
return audioLevelUpdated(_that.field0);case TrackEvent_TrackCreated() when trackCreated != null:
return trackCreated();case _:
  return null;

}
}

}

/// @nodoc


class TrackEvent_Ended extends TrackEvent {
  const TrackEvent_Ended(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_Ended);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent.ended()';
}


}




/// @nodoc


class TrackEvent_AudioLevelUpdated extends TrackEvent {
  const TrackEvent_AudioLevelUpdated(this.field0): super._();
  

 final  int field0;

/// Create a copy of TrackEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackEvent_AudioLevelUpdatedCopyWith<TrackEvent_AudioLevelUpdated> get copyWith => _$TrackEvent_AudioLevelUpdatedCopyWithImpl<TrackEvent_AudioLevelUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_AudioLevelUpdated&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'TrackEvent.audioLevelUpdated(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $TrackEvent_AudioLevelUpdatedCopyWith<$Res> implements $TrackEventCopyWith<$Res> {
  factory $TrackEvent_AudioLevelUpdatedCopyWith(TrackEvent_AudioLevelUpdated value, $Res Function(TrackEvent_AudioLevelUpdated) _then) = _$TrackEvent_AudioLevelUpdatedCopyWithImpl;
@useResult
$Res call({
 int field0
});




}
/// @nodoc
class _$TrackEvent_AudioLevelUpdatedCopyWithImpl<$Res>
    implements $TrackEvent_AudioLevelUpdatedCopyWith<$Res> {
  _$TrackEvent_AudioLevelUpdatedCopyWithImpl(this._self, this._then);

  final TrackEvent_AudioLevelUpdated _self;
  final $Res Function(TrackEvent_AudioLevelUpdated) _then;

/// Create a copy of TrackEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(TrackEvent_AudioLevelUpdated(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TrackEvent_TrackCreated extends TrackEvent {
  const TrackEvent_TrackCreated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackEvent_TrackCreated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TrackEvent.trackCreated()';
}


}




// dart format on
