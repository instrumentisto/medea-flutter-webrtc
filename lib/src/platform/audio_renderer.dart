import '/src/platform/track.dart';

import 'native/audio_renderer.dart'
    if (dart.library.html) 'web/audio_renderer.dart';

abstract class AudioRenderer {
  AudioRenderer();

  Future<void> initialize();

  MediaStreamTrack? get srcObject;

  set srcObject(MediaStreamTrack? srcObject);

  Future<void> dispose();
}

AudioRenderer createAudioRenderer() {
  return createPlatformSpecificAudioRenderer();
}
