import '/src/platform/audio_renderer.dart';
import '/src/platform/track.dart';

/// Creates new [AudioRenderer] for native platform.
AudioRenderer createPlatformSpecificAudioRenderer() {
  return NativeAudioRenderer();
}

class NativeAudioRenderer extends AudioRenderer {
  /// Audio [MediaStreamTrack] currently played by this [NativeAudioRenderer].
  MediaStreamTrack? _srcObject;

  @override
  MediaStreamTrack? get srcObject => _srcObject;

  @override
  set srcObject(MediaStreamTrack? track) => _srcObject = track;

  @override
  Future<void> dispose() async {}
}
