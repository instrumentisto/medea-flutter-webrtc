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

  void CreateRTCPeerConnection(
        rust::cxxbridge1::Box<Webrtc>& webrtc, 
        const flutter::MethodCall<EncodableValue>& method_call, 
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  void CreateOffer(
        rust::cxxbridge1::Box<Webrtc>& webrtc, 
        const flutter::MethodCall<EncodableValue>& method_call, 
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  void CreateAnswer(
        rust::cxxbridge1::Box<Webrtc>& webrtc, 
        const flutter::MethodCall<EncodableValue>& method_call, 
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  void SetLocalDescription(
        rust::cxxbridge1::Box<Webrtc>& webrtc, 
        const flutter::MethodCall<EncodableValue>& method_call, 
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);
        
  void SetRemoteDescription(
        rust::cxxbridge1::Box<Webrtc>& webrtc, 
        const flutter::MethodCall<EncodableValue>& method_call, 
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

}