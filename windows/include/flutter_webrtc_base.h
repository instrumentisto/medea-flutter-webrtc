#ifndef FLUTTER_WEBRTC_BASE_HXX
#define FLUTTER_WEBRTC_BASE_HXX

#include <flutter/encodable_value.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>

#include <string.h>
#include <list>
#include <map>
#include <memory>
#include <mutex>

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterVideoRenderer;
class FlutterRTCDataChannelObserver;
class FlutterPeerConnectionObserver;

// foo.StringValue() becomes std::get<std::string>(foo)
// foo.IsString() becomes std::holds_alternative<std::string>(foo)

template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

inline EncodableValue findEncodableValue(const EncodableMap& map,
                                         const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end())
    return it->second;
  return EncodableValue();
}

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

inline int findInt(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<int>(it->second))
    return GetValue<int>(it->second);
  return -1;
}

inline int64_t findLongInt(const EncodableMap& map, const std::string& key) {
  for (auto it : map) {
    if (key == GetValue<std::string>(it.first) &&
        (TypeIs<int64_t>(it.second) || TypeIs<int32_t>(it.second)))
      return GetValue<int64_t>(it.second);
  }

  return -1;
}

inline int toInt(EncodableValue inputVal, int defaultVal) {
  int intValue = defaultVal;
  if (TypeIs<int>(inputVal)) {
    intValue = GetValue<int>(inputVal);
  } else if (TypeIs<int32_t>(inputVal)) {
    intValue = GetValue<int32_t>(inputVal);
  } else if (TypeIs<std::string>(inputVal)) {
    intValue = atoi(GetValue<std::string>(inputVal).c_str());
  }
  return intValue;
}

class FlutterWebRTCBase {
 public:
  friend class FlutterMediaStream;
  friend class FlutterPeerConnection;
  friend class FlutterVideoRendererManager;
  friend class FlutterDataChannel;
  friend class FlutterPeerConnectionObserver;
  enum ParseConstraintType { kMandatory, kOptional };

 public:
  FlutterWebRTCBase(BinaryMessenger* messenger, TextureRegistrar* textures);
  ~FlutterWebRTCBase();

  std::map<int64_t, std::shared_ptr<FlutterVideoRenderer>> renders_;
  std::map<int, std::shared_ptr<FlutterRTCDataChannelObserver>>
      data_channel_observers_;
  std::map<std::string, std::shared_ptr<FlutterPeerConnectionObserver>>
      peerconnection_observers_;
  mutable std::mutex mutex_;

  void lock() { mutex_.lock(); }
  void unlock() { mutex_.unlock(); }

 protected:
  BinaryMessenger* messenger_;
  TextureRegistrar* textures_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_BASE_HXX
