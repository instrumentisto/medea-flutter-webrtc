import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';

AudioRenderer createPlatformSpecificAudioRenderer() {
  return AudioRendererNative();
}

class AudioRendererNative extends AudioRenderer {
  MediaStreamTrack? _srcObject;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set srcObject(MediaStreamTrack? track) {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}
