import '/src/platform/video_renderer.dart';

export '/src/platform/native/ffi/video_renderer.dart'
    if (dart.library.html) '/src/platform/native/channel/video_renderer.dart';

/// Creates a new [NativeVideoRenderer].
VideoRenderer createPlatformSpecificVideoRenderer() {
  return NativeVideoRenderer();
}
