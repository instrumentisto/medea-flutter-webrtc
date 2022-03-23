import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';

/// Creates new [AudioRenderer] for native platform.
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
  Future<void> dispose() async {}
}
