#include <sstream>
#include <string> 

#include "flutter_webrtc.h"
#include "wrapper2.h"
#include <flutter_webrtc_native.h>
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"

namespace flutter_webrtc_plugin {

typedef void (*callback_success)(std::string, std::string);
typedef void (*callback_fail)(std::string);

typedef void (*callback_success_desc)();

void OnSuccessOffer(
  flutter::MethodResult<flutter::EncodableValue>* result, 
  std::string sdp, 
  std::string type) {
    flutter::EncodableMap params;
    params[flutter::EncodableValue("sdp")] = sdp;
    params[flutter::EncodableValue("type")] = type;
    result->Success(flutter::EncodableValue(params));
}

void OnSuccessDescription(
  flutter::MethodResult<flutter::EncodableValue>* result) {
    result->Success(nullptr);
}

void Fail(flutter::MethodResult<flutter::EncodableValue> *result, std::string error) {
  result->Error("42", error);
}

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

FlutterWebRTC::FlutterWebRTC(FlutterWebRTCPlugin* plugin) {}

FlutterWebRTC::~FlutterWebRTC() {}

void FlutterWebRTC::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (method_call.method_name().compare("createPeerConnection") == 0) {

    try {
      std::string id = std::to_string(webrtc->CreatePeerConnection());
      EncodableMap params;
      params[EncodableValue("peerConnectionId")] = id;
      result->Success(EncodableValue(params));
    }
    catch (const std::exception &e)
    {
      result->Error(e.what());
    }

  } else if (method_call.method_name().compare("getSources") == 0) {
    rust::Vec<MediaDeviceInfo> devices = EnumerateDevices();

    EncodableList sources;

    for (size_t i = 0; i < devices.size(); ++i) {
      std::string kind;
      switch (devices[i].kind) {
        case MediaDeviceKind::kAudioInput:
          kind = "audioinput";
          break;

        case MediaDeviceKind::kAudioOutput:
          kind = "audiooutput";
          break;

        case MediaDeviceKind::kVideoInput:
          kind = "videoinput";
          break;

        default:
          throw std::exception("Invalid MediaDeviceKind");
      }

      EncodableMap info;
      info[EncodableValue("label")] =
          EncodableValue(std::string(devices[i].label));
      info[EncodableValue("deviceId")] =
          EncodableValue(std::string(devices[i].device_id));
      info[EncodableValue("kind")] = EncodableValue(kind);
      info[EncodableValue("groupId")] = EncodableValue(std::string(""));

      sources.push_back(EncodableValue(info));
    }

    EncodableMap params;
    params[EncodableValue("sources")] = EncodableValue(sources);
    result->Success(EncodableValue(params));
  } else if (method_call.method_name().compare("getUserMedia") == 0) {
  } else if (method_call.method_name().compare("getDisplayMedia") == 0) {
  } else if (method_call.method_name().compare("mediaStreamGetTracks") == 0) {
  } else if (method_call.method_name().compare("createOffer") == 0) {

    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }
    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "constraints");
    const EncodableMap mandatory = findMap(constraints, "mandatory");
    const bool f1 = findBool(mandatory, "OfferToReceiveAudio");
    const bool f2 = findBool(mandatory, "OfferToReceiveVideo");

    try {
      rust::cxxbridge1::Box<PeerConnection_> peerconnection = 
        webrtc->GetPeerConnectionFromId(std::stoi(peerConnectionId));

      auto result_ptr = result.get(); // must free?

      auto bind_success = std::bind(&OnSuccessOffer, result_ptr, std::placeholders::_1, std::placeholders::_2);
      callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
      size_t success = (size_t) wrapp_success;

      auto bind_fail = std::bind(&Fail, result_ptr, std::placeholders::_1);
      callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
      size_t fail = (size_t) wrapp_fail;

      peerconnection->CreateOffer(f2, f1, true, false, true, success, fail);
    }
    catch (const std::exception &e)
    {
      flutter::EncodableMap rparams;
      rparams[flutter::EncodableValue("sdp")] = "TESTTESTTEST";
      rparams[flutter::EncodableValue("type")] = "TYPE";
      result->Success(flutter::EncodableValue(rparams));
      e;
      //std::string str = e.what();
    }


  } else if (method_call.method_name().compare("createAnswer") == 0) {

    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }

    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "constraints");
    const EncodableMap mandatory = findMap(constraints, "mandatory");
    const bool f1 = findBool(mandatory, "OfferToReceiveAudio");
    const bool f2 = findBool(mandatory, "OfferToReceiveVideo");

    rust::cxxbridge1::Box<PeerConnection_> peerconnection = 
      webrtc->GetPeerConnectionFromId(std::stoi(peerConnectionId));

    auto result_ptr = result.release(); // must free?

    auto bind_success = std::bind(&OnSuccessOffer, result_ptr, std::placeholders::_1, std::placeholders::_2);
    callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    auto bind_fail = std::bind(&Fail, result_ptr, std::placeholders::_1);
    callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    peerconnection->CreateAnswer(f2, f1, true, false, true, success, fail);

  } else if (method_call.method_name().compare("addStream") == 0) {
  } else if (method_call.method_name().compare("removeStream") == 0) {
  } else if (method_call.method_name().compare("setLocalDescription") == 0) {
    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }
    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "description"); 
    rust::String type = findString(constraints, "type");
    rust::String sdp = findString(constraints, "sdp");

    auto result_ptr = result.release();

    auto bind_fail = std::bind(&Fail, result_ptr, std::placeholders::_1);
    callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;
    
    auto bind_success = std::bind(&OnSuccessDescription, result_ptr);
    callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;
    
    rust::cxxbridge1::Box<PeerConnection_> peerconnection = webrtc->GetPeerConnectionFromId(std::stoi(peerConnectionId));
    peerconnection->SetLocalDescription(type, sdp, success, fail);

  } else if (method_call.method_name().compare("setRemoteDescription") == 0) {

    if (!method_call.arguments()) {
      result->Error("Bad Arguments", "Null constraints arguments received");
      return;
    }
    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "description"); 
    rust::String type = findString(constraints, "type");
    rust::String sdp = findString(constraints, "sdp");

    auto result_ptr = result.release();

    auto bind_fail = std::bind(&Fail, result_ptr, std::placeholders::_1);
    callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;
    
    auto bind_success = std::bind(&OnSuccessDescription, result_ptr);
    callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;
    
    rust::cxxbridge1::Box<PeerConnection_> peerconnection = webrtc->GetPeerConnectionFromId(std::stoi(peerConnectionId));
    peerconnection->SetRemoteDescription(type, sdp, success, fail);

  } else if (method_call.method_name().compare("addCandidate") == 0) {
  } else if (method_call.method_name().compare("getStats") == 0) {
  } else if (method_call.method_name().compare("createDataChannel") == 0) {
  } else if (method_call.method_name().compare("dataChannelSend") == 0) {
  } else if (method_call.method_name().compare("dataChannelClose") == 0) {
  } else if (method_call.method_name().compare("streamDispose") == 0) {
  } else if (method_call.method_name().compare("mediaStreamTrackSetEnable") ==
             0) {
  } else if (method_call.method_name().compare("trackDispose") == 0) {
  } else if (method_call.method_name().compare("peerConnectionClose") == 0) {
  } else if (method_call.method_name().compare("createVideoRenderer") == 0) {
  } else if (method_call.method_name().compare("videoRendererDispose") == 0) {
  } else if (method_call.method_name().compare("videoRendererSetSrcObject") ==
             0) {
  } else if (method_call.method_name().compare(
                 "mediaStreamTrackSwitchCamera") == 0) {
  } else if (method_call.method_name().compare("setVolume") == 0) {
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_webrtc_plugin
