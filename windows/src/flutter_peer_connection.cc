
#include "flutter_peer_connection.h"

namespace callbacks {
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

void OnFail(flutter::MethodResult<flutter::EncodableValue> *result, std::string error) {
  result->Error(error);
}
}


namespace flutter_webrtc_plugin {

using namespace flutter;

void CreateRTCPeerConnection(
    rust::cxxbridge1::Box<Webrtc>& webrtc, 
    const flutter::MethodCall<EncodableValue>& method_call, 
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result)
    {
        rust::String error;
        uint64_t id = webrtc->CreatePeerConnection(error);
        std::string peer_connection_id = std::to_string(id);
        if(error == ""){
            EncodableMap params;
            params[EncodableValue("peerConnectionId")] = peer_connection_id;
            result->Success(EncodableValue(params));
        } else {
            std::string err(error);
            result->Error(err);
        }
    }

void CreateOffer(
    rust::cxxbridge1::Box<Webrtc>& webrtc, 
    const flutter::MethodCall<EncodableValue>& method_call, 
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

    if (!method_call.arguments()) {
        result->Error("Bad Arguments", "Null constraints arguments received");
        return;
    }
    
    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "constraints");
    const EncodableMap mandatory = findMap(constraints, "mandatory");
    const EncodableList list = findList(constraints, "optional");

    bool receive_video = true;
    bool receive_audio = true; 
    bool voice_activity_detection = true; 
    bool ice_restart = false; 
    bool use_rtp_mux = true;

    auto iter = list.begin();
    if (iter != list.end()) {
        voice_activity_detection = GetValue<bool>((*iter));
        ++iter;
    }
    if (iter != list.end()) {
        ice_restart = GetValue<bool>((*iter));
        ++iter;
    }
    if (iter != list.end()) {
        use_rtp_mux = GetValue<bool>((*iter));
        ++iter;
    }
    receive_audio = findBool(mandatory, "OfferToReceiveAudio");
    receive_video = findBool(mandatory, "OfferToReceiveVideo");

    auto res = result.release();

    auto bind_success = std::bind(&callbacks::OnSuccessOffer, res, std::placeholders::_1, std::placeholders::_2);
    callbacks::callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    auto bind_fail = std::bind(&callbacks::OnFail, res, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    rust::String error;
    webrtc->InitCreateObs(error, std::stoi(peerConnectionId), success, fail);
    if (error != "")
    {
        std::string err(error);
        res->Error("createAnswerOffer", err);
    }
    
    webrtc->CreateOffer(
        error,
        std::stoi(peerConnectionId),
        receive_video, 
        receive_audio, 
        voice_activity_detection, 
        ice_restart, 
        use_rtp_mux
    );
};
void CreateAnswer(
    rust::cxxbridge1::Box<Webrtc>& webrtc, 
    const flutter::MethodCall<EncodableValue>& method_call, 
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

    if (!method_call.arguments()) {
        result->Error("Bad Arguments", "Null constraints arguments received");
        return;
    }
    
    const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
    const std::string peerConnectionId = findString(params, "peerConnectionId");
    const EncodableMap constraints = findMap(params, "constraints");
    const EncodableMap mandatory = findMap(constraints, "mandatory");
    const EncodableList list = findList(constraints, "optional");

    bool receive_video = true;
    bool receive_audio = true; 
    bool voice_activity_detection = true; 
    bool ice_restart = false; 
    bool use_rtp_mux = true;

    auto iter = list.begin();
    if (iter != list.end()) {
        voice_activity_detection = GetValue<bool>((*iter));
        ++iter;
    }
    if (iter != list.end()) {
        ice_restart = GetValue<bool>((*iter));
        ++iter;
    }
    if (iter != list.end()) {
        use_rtp_mux = GetValue<bool>((*iter));
        ++iter;
    }
    receive_audio = findBool(mandatory, "OfferToReceiveAudio");
    receive_video = findBool(mandatory, "OfferToReceiveVideo");

    auto res = result.release();

    auto bind_success = std::bind(&callbacks::OnSuccessOffer, res, std::placeholders::_1, std::placeholders::_2);
    callbacks::callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    auto bind_fail = std::bind(&callbacks::OnFail, res, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    rust::String error;
    webrtc->InitCreateObs(error, std::stoi(peerConnectionId), success, fail);
    if (error != "")
    {
        std::string err(error);
        res->Error("createAnswerOffer", err);
    }

    webrtc->CreateAnswer(
        error,
        std::stoi(peerConnectionId),
        receive_video, 
        receive_audio, 
        voice_activity_detection, 
        ice_restart, 
        use_rtp_mux
    );
};
void SetLocalDescription(
    rust::cxxbridge1::Box<Webrtc>& webrtc, 
    const flutter::MethodCall<EncodableValue>& method_call, 
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

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
    auto bind_fail = std::bind(&callbacks::OnFail, result_ptr, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    auto bind_success = std::bind(&callbacks::OnSuccessDescription, result_ptr);
    callbacks::callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;


    rust::String error;
    webrtc->InitSetObs(error, std::stoi(peerConnectionId), success, fail);
    if (error != "")
    {
        std::string err(error);
        result_ptr->Error("createAnswerOffer", err);
    }

    webrtc->SetLocalDescription(
        error,
        std::stoi(peerConnectionId),
        type, 
        sdp
    );
};

void SetRemoteDescription(
    rust::cxxbridge1::Box<Webrtc>& webrtc, 
    const flutter::MethodCall<EncodableValue>& method_call, 
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
    
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
    auto bind_fail = std::bind(&callbacks::OnFail, result_ptr, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;
    fail;
    
    auto bind_success = std::bind(&callbacks::OnSuccessDescription, result_ptr);
    callbacks::callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    rust::String error;
    webrtc->InitSetObs(error, std::stoi(peerConnectionId), success, fail);
    if (error != "")
    {
        std::string err(error);
        result_ptr->Error("createAnswerOffer", err);
    }

    webrtc->SetRemoteDescription(
        error,
        std::stoi(peerConnectionId),
        type, 
        sdp
    );
};

}