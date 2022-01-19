
#include "flutter_peer_connection.h"
#include "media_stream.h"

#include <thread>
#include <mutex>
#include <condition_variable>

namespace callbacks {

// Callback type for `CreateOffer/Answer` is success.
typedef void (*callback_success)(std::string, std::string);

// Callback type for `CreateOffer/Answer` or `SetLocal/RemoteDescription` is fail.
typedef void (*callback_fail)(std::string);

// Callback type for `SetLocal/RemoteDescription` is success.
typedef void (*callback_success_desc)();

// Event State chng #todo(DOC).
typedef void (*event)(std::string);

// Callback for write `CreateOffer/Answer` success result in flutter.
void OnSuccessCreate(
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
  std::string sdp,
  std::string type) {
    flutter::EncodableMap params;
    params[flutter::EncodableValue("sdp")] = sdp;
    params[flutter::EncodableValue("type")] = type;
    result->Success(flutter::EncodableValue(params));
}

// Callback for write `SetLocalDescription` success result in flutter.
void OnSuccessDescription(
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    result->Success(nullptr);
}

// Callback for write error in flutter.
void OnFail(std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result, std::string error) {
  result->Error(error);
}

// Event #todo(DOC).
void OnEvent(
    EventChannel<EncodableValue>* channel,
    EventSink<EncodableValue>* result, 
    std::string event) {
    if (result != nullptr) {
        printf("OK\n");
        //EncodableMap params;
        //params[EncodableValue("event")] = "signalingState";
        //params[EncodableValue("state")] = event;
        //result->Success("EncodableValue(params)");
    }
    else {
        printf("NULL\n");
    }

}
}


namespace flutter_webrtc_plugin {

using namespace flutter;

// Calls Rust `create_default_peer_connection()` and write `PeerConnectionId` in result.
void CreateRTCPeerConnection(
    flutter::BinaryMessenger* messenger,
    rust::cxxbridge1::Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result)
    {
        if (!method_call.arguments()) {
            result->Error("Bad Arguments", "Null constraints arguments received");
            return;
        }

        std::shared_ptr<EventChannel<EncodableValue>> event_channel_ 
            = std::make_shared<EventChannel<EncodableValue>>(EventChannel<EncodableValue>(
                messenger,
                "test",
                &StandardMethodCodec::GetInstance()));
        std::shared_ptr<EventSink<EncodableValue>> event_sink_ = nullptr;

        auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
            [&](const flutter::EncodableValue* arguments,
                std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
                -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
                    event_sink_ = std::make_shared<EventChannel<EncodableValue>>(events);
                    return nullptr;
            },
            [&](const flutter::EncodableValue* arguments)
                -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
                    event_sink_ = nullptr;
                    return nullptr;
            }
        );

        event_channel_->SetStreamHandler(std::move(handler));

        auto bind_event 
            = std::bind(
                &callbacks::OnEvent, 
                event_channel_, 
                event_sink_, 
                std::placeholders::_1
            );

        callbacks::event wrapp_event = Wrapper<0, void(std::string)>::wrap(bind_event);
        size_t event = (size_t) wrapp_event;
        
        //std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events
        rust::String error;
        uint64_t id = webrtc->CreatePeerConnection(event, error);
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

// Calls Rust `create_offer()`. 
// success or fail will be write in result in `CreateSessionDescriptionObserver` callbacks.
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

    std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

    auto bind_success = std::bind(&callbacks::OnSuccessCreate, rs, std::placeholders::_1, std::placeholders::_2);
    callbacks::callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    rust::String error;
    webrtc->CreateOffer(
        error,
        std::stoi(peerConnectionId),
        receive_video,
        receive_audio,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        success,
        fail
    );
    if (error != "")
    {
        std::string err(error);
        rs->Error("createAnswerOffer", err);
    }
};

// Calls Rust `create_answer()`. 
// success or fail will be write in result in `CreateSessionDescriptionObserver` callbacks.
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

    std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

    auto bind_success = std::bind(&callbacks::OnSuccessCreate, rs, std::placeholders::_1, std::placeholders::_2);
    callbacks::callback_success wrapp_success = Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

    auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    rust::String error;
    webrtc->CreateAnswer(
        error,
        std::stoi(peerConnectionId),
        receive_video,
        receive_audio,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        success,
        fail
    );
    if (error != "")
    {
        std::string err(error);
        rs->Error("createAnswerOffer", err);
    }
};

// Calls Rust `set_local_description()`. 
// success or fail will be write in result in `SetLocalDescriptionObserverInterface` callbacks.
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

    std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

    auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    auto bind_success = std::bind(&callbacks::OnSuccessDescription, rs);
    callbacks::callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

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
        rs->Error("createAnswerOffer", err);
    }
};

// Calls Rust `set_remote_description()`. 
// success or fail will be write in result in `SetRemoteDescriptionObserverInterface` callbacks.
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

    std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

    auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
    callbacks::callback_fail wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
    size_t fail = (size_t) wrapp_fail;

    auto bind_success = std::bind(&callbacks::OnSuccessDescription, rs);
    callbacks::callback_success_desc wrapp_success = Wrapper<0, void()>::wrap(bind_success);
    size_t success = (size_t) wrapp_success;

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
        rs->Error("createAnswerOffer", err);
    }
};

}
