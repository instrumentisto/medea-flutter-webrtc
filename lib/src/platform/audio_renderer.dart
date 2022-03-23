import '/src/platform/track.dart';

import 'native/audio_renderer.dart'
    if (dart.library.html) 'web/audio_renderer.dart';

/// Renderer for the audio [MediaStreamTrack]s.
abstract class AudioRenderer {
  /// Returns [MediaStreamTrack] which this [AudioRenderer] currently plays.
  MediaStreamTrack? get srcObject;

  /// Sets [MediaStreamTrack] which will be played by this [AudioRenderer].
  set srcObject(MediaStreamTrack? srcObject);

  /// Disposes this [AudioRenderer].
  Future<void> dispose();
}

/// Creates new platform specific [AudioRenderer].
AudioRenderer createAudioRenderer() {
  return createPlatformSpecificAudioRenderer();
}
