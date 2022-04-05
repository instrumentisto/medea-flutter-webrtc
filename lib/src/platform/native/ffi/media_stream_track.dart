import 'dart:async';

import '../../../../flutter_webrtc.dart';
import '/src/api/ffi/bridge.g.dart' as ffi;

/// Representation of a single media unit.
class NativeMediaStreamTrack extends MediaStreamTrack {
  /// Creates a [NativeMediaStreamTrack] basing on the provided
  /// [ffi.MediaStreamTrack].
  NativeMediaStreamTrack.from(ffi.MediaStreamTrack track) {
    _id = track.id.toString();
    _deviceId = track.deviceId;
    _kind = MediaKind.values[track.kind.index];
    _eventSub = api.registerTrackObserver(trackId: track.id).listen((event) {
      if (_onEnded != null) {
        _onEnded!();
      }
    });
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

  /// [ended][1] event subscriber.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
  OnEndedCallback? _onEnded;

  /// [_eventChan] subscription to the [PeerConnection] events.
  // ignore: unused_field
  late StreamSubscription<dynamic>? _eventSub;

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

  /// Indicates whether this [NativeMediaStreamTrack] has been stopped.
  bool _stopped = false;

  @override
  Future<MediaStreamTrack> clone() async {
    if (!_stopped) {
      return NativeMediaStreamTrack.from(
          await api.cloneTrack(trackId: int.parse(_id)));
    } else {
      return NativeMediaStreamTrack.from(ffi.MediaStreamTrack(
          deviceId: _deviceId,
          enabled: _enabled,
          id: int.parse(_id),
          kind: ffi.MediaType.values[_kind.index]));
    }
  }

  @override
  Future<void> dispose() async {
    // TODO(logist322): Stucks on canceling StreamSubscription.
    // await _eventSub?.cancel();

    if (!_stopped) {
      await api.disposeTrack(trackId: int.parse(_id));
    }
    _stopped = true;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (!_stopped) {
      api.setTrackEnabled(trackId: int.parse(_id), enabled: enabled);
    }

    _enabled = enabled;
  }

  @override
  Future<void> stop() async {
    if (!_stopped) {
      await api.disposeTrack(trackId: int.parse(_id));
    }
    _stopped = true;
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
