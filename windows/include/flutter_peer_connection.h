#include "flutter_webrtc.h"
#include "wrapper.h"

namespace flutter_webrtc_plugin {

template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
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

inline bool findBool(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<bool>(it->second))
    return GetValue<bool>(it->second);
  return bool();
}

inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}

using namespace flutter;

typedef void (*callback_success)(std::string, std::string);
typedef void (*callback_fail)(std::string);

typedef void (*callback_success_desc)();

struct RTCConf {
    bool voice_activity_detection = true;
    bool ice_restart = false;
    bool use_rtp_mux = true;
    bool receive_audio = true;
    bool receive_video = true;
    RTCConf(const flutter::MethodCall<EncodableValue>& method_call);
};

class FlutterPeerConnection {
    private:
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result;
    const flutter::MethodCall<EncodableValue>& method_call;
    rust::cxxbridge1::Box<Webrtc>& webrtc;
    
    public:
    FlutterPeerConnection(
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result,
        const flutter::MethodCall<EncodableValue>& method_call,
        rust::cxxbridge1::Box<Webrtc>& webrtc);

    void CreateOffer();
    void CreateAnswer();
    void SetLocalDescription();
    void SetRemoteDescription();
};

}