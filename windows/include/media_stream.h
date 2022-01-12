#include <memory>
#include <optional>

#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "flutter_webrtc/flutter_webrtc_plugin.h"
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && std::holds_alternative<EncodableMap>(it->second))
    return std::get<EncodableMap>(it->second);
  return EncodableMap();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && std::holds_alternative<std::string>(it->second))
    return std::get<std::string>(it->second);
  return std::string();
}

/// Calls Rust `EnumerateDevices()` and converts the recieved
/// Rust vector of `MediaDeviceInfo` info for Dart.
void enumerate_device(rust::Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result);

/// Parses the recieved constraints from Dart and passes them
/// to Rust `GetUserMedia()`, then converts the backed `MediaStream`
/// info for Dart.
void get_user_media(EncodableMap constraints_arg, Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result);

/// Parses video constraints recieved from Dart to Rust `VideoConstraints`.
std::optional<VideoConstraints> parse_video_constraints(const EncodableValue video_arg, MethodResult<EncodableValue>& result);

/// Parses audio constraints recieved from Dart to Rust `AudioConstraints`.
AudioConstraints parse_audio_constraints(const EncodableValue audio_arg);

/// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList` for passing to Dart according to `TrackKind`.
EncodableList get_params(TrackKind type, MediaStream& user_media);

/// Disposes some media stream calling Rust `DisposeStream`.
void dispose_stream(std::string stream_id, Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result);
