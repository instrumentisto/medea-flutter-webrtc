#ifndef MEDIA_STREAM_METHODS
#define MEDIA_STREAM_METHODS

#include <memory>

#include <flutter_webrtc_native.h>
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "flutter_webrtc/flutter_webrtc_plugin.h"
#include "flutter_webrtc_base.h"

using namespace rust::cxxbridge1;

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

namespace flutter_webrtc_plugin {

// Class with the methods related to `MediaStream`.
class MediaStreamMethods {
 public:
  // Calls Rust `EnumerateDevices()` and converts the received Rust vector of
  // `MediaDeviceInfo` info for Dart.
  static void EnumerateDevice(
      rust::Box<Webrtc>& webrtc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Parses the received constraints from Dart and passes them to Rust
  // `GetUserMedia()`, then converts the backed `MediaStream` info for Dart.
  static void GetUserMedia(
      const flutter::MethodCall<EncodableValue>& method_call,
      Box<Webrtc>& webrtc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  // Disposes some media stream calling Rust `DisposeStream`.
  static void DisposeStream(
      const flutter::MethodCall<EncodableValue>& method_call,
      Box<Webrtc>& webrtc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  // Parses video constraints received from Dart to Rust `VideoConstraints`.
  static VideoConstraints ParseVideoConstraints(const EncodableValue video_arg);

  // Parses audio constraints received from Dart to Rust `AudioConstraints`.
  static AudioConstraints ParseAudioConstraints(const EncodableValue audio_arg);

  // Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
  // for passing to Dart according to `TrackKind`.
  static EncodableList GetParams(TrackKind type, MediaStream& user_media);
};
}  // namespace flutter_webrtc_plugin

#endif
