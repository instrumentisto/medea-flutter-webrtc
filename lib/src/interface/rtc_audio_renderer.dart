import 'package:flutter_webrtc/src/interface/media_stream_track.dart';

abstract class AudioRenderer {
  AudioRenderer();

  MediaStreamTrack? get srcObject;

  set muted(bool mute);

  set srcObject(MediaStreamTrack? srcObject);

  Future<bool> audioOutput(String deviceId);

  Future<void> dispose();
}
