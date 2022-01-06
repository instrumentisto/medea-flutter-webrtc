import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaStreamTrackNative extends MediaStreamTrack {
  MediaStreamTrackNative(this._trackId, this._label, this._kind, this._enabled,
      this._settings, this._deviceId);

  factory MediaStreamTrackNative.fromMap(Map<dynamic, dynamic> map) {
    return MediaStreamTrackNative(map['id'], map['label'], map['kind'],
        map['enabled'], map['settings'], map['deviceId']);
  }
  final String _trackId;
  final String _label;
  final String _kind;
  final Map<dynamic, dynamic> _settings;
  final String _deviceId;
  bool _enabled;

  bool _muted = false;

  @override
  set enabled(bool enabled) {
    WebRTC.invokeMethod('mediaStreamTrackSetEnable',
        <String, dynamic>{'trackId': _trackId, 'enabled': enabled});
    _enabled = enabled;

    if (kind == 'audio') {
      _muted = !enabled;
      muted ? onMute?.call() : onUnMute?.call();
    }
  }

  @override
  bool get enabled => _enabled;

  @override
  String get label => _label;

  @override
  String get kind => _kind;

  @override
  String get id => _trackId;

  @override
  bool get muted => _muted;

  @override
  String deviceId() {
    return _deviceId;
  }

  @override
  Map<dynamic, dynamic> getSettings() {
    return _settings;
  }

  @override
  Future<MediaStreamTrackReadyState> readyState() async {
    final response = await WebRTC.invokeMethod(
      'mediaStreamTrackReadyState',
      <String, dynamic>{'trackId': _trackId},
    );

    return typeStringToMediaStreamTrackState[response['result']]!;
  }

  @override
  Future<void> dispose() async {
    return stop();
  }

  @override
  Future<void> stop() async {
    try {
      await WebRTC.invokeMethod(
        'trackDispose',
        <String, dynamic>{'trackId': _trackId},
      );
    } catch (e) {
      print('Tried to stop already stopped MediaStreamTrack');
    }
  }
}
