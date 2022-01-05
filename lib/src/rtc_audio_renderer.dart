import 'package:flutter_webrtc/src/interface/rtc_audio_renderer.dart';

import '../flutter_webrtc.dart';

class RTCAudioRenderer {
  RTCAudioRenderer() : _delegate = audioRenderer();

  final AudioRenderer _delegate;

  AudioRenderer get delegate => _delegate;

  MediaStreamTrack? get srcObject => _delegate.srcObject;

  set srcObject(MediaStreamTrack? track) => _delegate.srcObject = track;

  set muted(bool muted) => _delegate.muted = muted;

  Future<bool> audioOutput(String deviceId) {
    return _delegate.audioOutput(deviceId);
  }

  Future<void> dispose() async {
    return _delegate.dispose();
  }
}
