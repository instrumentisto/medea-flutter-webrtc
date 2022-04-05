// TODO(alexlapa):
//    i assume that this won't work on android
//    and we need none of this for web build
export '/src/model/ffi/device.dart'
    if (dart.library.html) '/src/model/channel/device.dart';

/// Media device kind.
enum MediaDeviceKind {
  /// Represents an audio input device (for example, a microphone).
  audioinput,

  /// Represents an audio output device (for example, a pair of headphones).
  audiooutput,

  /// Represents a video input device (for example, a webcam).
  videoinput,
}
