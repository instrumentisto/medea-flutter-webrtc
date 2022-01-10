
#include "flutter_peer_connection.h"

namespace my_stuff {
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
  result->Error(error);
}
}


namespace flutter_webrtc_plugin {

using namespace flutter;

    RTCConf::RTCConf(const flutter::MethodCall<EncodableValue>& method_call) {

        const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
        const EncodableMap constraints = findMap(params, "constraints");
        const EncodableMap mandatory = findMap(constraints, "mandatory");

        const EncodableList list = findList(constraints, "optional");

        auto iter = list.begin();
        if (iter != list.end()) {
            this->voice_activity_detection = GetValue<bool>((*iter));
            ++iter;
        }
        if (iter != list.end()) {
            this->ice_restart = GetValue<bool>((*iter));
            ++iter;
        }
        if (iter != list.end()) {
            this->use_rtp_mux = GetValue<bool>((*iter));
            ++iter;
        }

        this->receive_audio = findBool(mandatory, "OfferToReceiveAudio");
        this->receive_video = findBool(mandatory, "OfferToReceiveVideo");
    };

    FlutterPeerConnection::FlutterPeerConnection(
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result,
        const flutter::MethodCall<EncodableValue>& method_call,
        rust::cxxbridge1::Box<Webrtc>& webrtc
        ) 
        : 
            result(std::move(result)), 
            method_call(method_call),
            webrtc(webrtc) {};

    void FlutterPeerConnection::CreateOffer() {
        const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
        const std::string peerConnectionId = findString(params, "peerConnectionId");

        auto res = result.release();
        auto bind_success = std::bind(&my_stuff::OnSuccessOffer, res, std::placeholders::_1, std::placeholders::_2);
        callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
        size_t success = (size_t) wrapp_success;

        auto bind_fail = std::bind(&my_stuff::Fail, res, std::placeholders::_1);
        callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
        size_t fail = (size_t) wrapp_fail;

        RTCConf conf = RTCConf(method_call);
        rust::String error;
        webrtc->CreateOffer(
            error,
            std::stoi(peerConnectionId),
            conf.receive_video, 
            conf.receive_audio, 
            conf.voice_activity_detection, 
            conf.ice_restart, 
            conf.use_rtp_mux, 
            success, 
            fail
        );
        if (error != "")
        {
            std::string err(error);
            res->Error("createAnswerOffer", err);
        }
    };
    void FlutterPeerConnection::CreateAnswer() {
        const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
        const std::string peerConnectionId = findString(params, "peerConnectionId");

        auto res = result.release();
        auto bind_success = std::bind(&my_stuff::OnSuccessOffer, res, std::placeholders::_1, std::placeholders::_2);
        callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
        size_t success = (size_t) wrapp_success;

        auto bind_fail = std::bind(&my_stuff::Fail, res, std::placeholders::_1);
        callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
        size_t fail = (size_t) wrapp_fail;

        RTCConf conf = RTCConf(method_call);
        rust::String error;
        webrtc->CreateAnswer(
            error,
            std::stoi(peerConnectionId),
            conf.receive_video, 
            conf.receive_audio, 
            conf.voice_activity_detection, 
            conf.ice_restart, 
            conf.use_rtp_mux, 
            success, 
            fail
        );
        if (error != "")
        {
            std::string err(error);
            res->Error("createAnswerOffer", err);
        }
    };

    void FlutterPeerConnection::SetLocalDescription() {

        const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
        const std::string peerConnectionId = findString(params, "peerConnectionId");
        const EncodableMap constraints = findMap(params, "description"); 
        rust::String type = findString(constraints, "type");
        rust::String sdp = findString(constraints, "sdp");

        auto result_ptr = result.release();

        auto bind_fail = std::bind(&my_stuff::Fail, result_ptr, std::placeholders::_1);
        callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
        size_t fail = (size_t) wrapp_fail;
        fail;
        
        auto bind_success = std::bind(&my_stuff::OnSuccessDescription, result_ptr);
        callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
        size_t success = (size_t) wrapp_success;
        success;

        rust::String error;
        webrtc->SetLocalDescription(
            error,
            std::stoi(peerConnectionId),
            type, 
            sdp, 
            success, 
            fail
        );
        if (error != "")
        {
            std::string err(error);
            result_ptr->Error("SetLocalDescriptionFailed", err);
        }
    };

    void FlutterPeerConnection::SetRemoteDescription() {

const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
        const std::string peerConnectionId = findString(params, "peerConnectionId");
        const EncodableMap constraints = findMap(params, "description"); 
        rust::String type = findString(constraints, "type");
        rust::String sdp = findString(constraints, "sdp");

        auto result_ptr = result.release();

        auto bind_fail = std::bind(&my_stuff::Fail, result_ptr, std::placeholders::_1);
        callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
        size_t fail = (size_t) wrapp_fail;
        fail;
        
        auto bind_success = std::bind(&my_stuff::OnSuccessDescription, result_ptr);
        callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
        size_t success = (size_t) wrapp_success;
        success;

        rust::String error;
        webrtc->SetRemoteDescription(
            error,
            std::stoi(peerConnectionId),
            type, 
            sdp, 
            success, 
            fail
        );
        if (error != "")
        {
            std::string err(error);
            result_ptr->Error("SetLocalDescriptionFailed", err);
        }
    };

}