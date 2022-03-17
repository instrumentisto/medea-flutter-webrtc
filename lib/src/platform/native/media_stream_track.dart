import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '/src/api/channel.dart';
import '/src/model/track.dart';
import '/src/platform/track.dart';
import '../../../flutter_webrtc.dart';

/// Representation of a single media unit.
abstract class NativeMediaStreamTrack extends MediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  static NativeMediaStreamTrack from(dynamic map) {
    NativeMediaStreamTrack? track;

    if (Platform.isAndroid || Platform.isIOS) {
      track = _NativeMediaStreamTrackChannel.fromMap(map);
    } else {
      track = _NativeMediaStreamTrackFFI.FromFFI(map);
    }

    return track;
  }

  /// Indicates whether this [NativeMediaStreamTrack] transmits media.
  ///
  /// If it's `false` then blank (black screen for video and `0dB` for audio)
  /// media will be transmitted.
  bool _enabled = true;

  /// Unique ID of this [NativeMediaStreamTrack].
  late String _id;

  /// [MediaKind] of this [NativeMediaStreamTrack].
  late MediaKind _kind;

  /// Unique ID of the device from which this [NativeMediaStreamTrack] was
  /// created.
  ///
  /// "remote" - for the remove tracks.
  late String _deviceId;

  /// `on_ended` event subscriber.
  OnEndedCallback? _onEnded;

  /// Listener for all the [MediaStreamTrack] events received from the native
  /// side.
  void eventListener(dynamic event) {
    final dynamic e = event;
    switch (e['event']) {
      case 'onEnded':
        _onEnded?.call();
        break;
    }
  }

  @override
  void onEnded(OnEndedCallback cb) {
    _onEnded = cb;
  }

  @override
  String id() {
    return _id;
  }

  @override
  MediaKind kind() {
    return _kind;
  }

  @override
  String deviceId() {
    return _deviceId;
  }

  @override
  bool isEnabled() {
    return _enabled;
  }
}

class _NativeMediaStreamTrackChannel extends NativeMediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  _NativeMediaStreamTrackChannel.fromMap(dynamic map) {
    var channelId = map['channelId'];
    _chan = methodChannel('MediaStreamTrack', channelId);
    _eventChan = eventChannel('MediaStreamTrackEvent', channelId);
    _eventSub = _eventChan.receiveBroadcastStream().listen(eventListener);
    _id = map['id'];
    _deviceId = map['deviceId'];
    _kind = MediaKind.values[map['kind']];
  }

  /// [MethodChannel] used for the messaging with a native side.
  late MethodChannel _chan;

  /// [EventChannel] to receive all the [PeerConnection] events from.
  late EventChannel _eventChan;

  /// [_eventChan] subscription to the [PeerConnection] events.
  late StreamSubscription<dynamic>? _eventSub;

  @override
  Future<void> setEnabled(bool enabled) async {
    await _chan.invokeMethod('setEnabled', {'enabled': enabled});
    _enabled = enabled;
  }

  @override
  Future<void> stop() async {
    await _chan.invokeMethod('stop');
  }

  @override
  Future<void> dispose() async {
    await _eventSub?.cancel();
  }

  @override
  Future<MediaStreamTrack> clone() async {
    return NativeMediaStreamTrack.from(await _chan.invokeMethod('clone'));
  }
}

class _NativeMediaStreamTrackFFI extends NativeMediaStreamTrack {

  /// Creates a [NativeMediaStreamTrack] basing on the [Map] received from the
  /// native side.
  
  //todo
  _NativeMediaStreamTrackFFI.FromFFI(MediaStreamTrackFFI track) {
    _id = track.id.toString();
    _deviceId = track.label.toString();
    _kind = MediaKind.values[track.kind.index];
  }

  @override
  Future<MediaStreamTrack> clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    // await api.disposeStream(id: 1);
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    api.setTrackEnabled(trackId: 1, enabled: enabled);
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }
}
