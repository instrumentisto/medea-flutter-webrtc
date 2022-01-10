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

template<typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template<typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

void enumerate_device(rust::Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result);

void get_user_media(EncodableMap constraints_arg, Box<Webrtc>& webrtc, std::unique_ptr<MethodResult<EncodableValue>> result);

std::optional<VideoConstraints> parse_video_constraints(const EncodableValue video_arg, MethodResult<EncodableValue>* result);

AudioConstraints parse_audio_constraints(const EncodableValue audio_arg);
