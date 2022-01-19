#include "flutter_peer_connection.h"
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

namespace callbacks {

template<typename... Args>
class Call {
  public:
  ~Call() {printf("delete");}
  void(*call)(std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>, Args...);
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
  std::shared_ptr<Call<Args...>> lt;
  void operator()(Args... args) {
    (*call)(std::move(result), args...);
    //lt.reset();
  }
};

// Callback type for `CreateOffer/Answer` is success.
typedef void (* callback_success)(std::string, std::string);

// Callback type for `CreateOffer/Answer` or `SetLocal/RemoteDescription` is fail.
typedef void (* callback_fail)(std::string);

// Callback type for `SetLocal/RemoteDescription` is success.
typedef void (* callback_success_desc)();

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
void OnFail(std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
            std::string error) {
  result->Error(error);
}
}

namespace flutter_webrtc_plugin {

using namespace flutter;

// Calls Rust `CreatePeerConnection()` and writes newly created Peer ID to the
// provided `MethodResult`.
void CreateRTCPeerConnection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(error);
  std::string peer_connection_id = std::to_string(id);
  if (error == "") {
    EncodableMap params;
    params[EncodableValue("peerConnectionId")] = peer_connection_id;
    result->Success(EncodableValue(params));
  } else {
    std::string err(error);
    result->Error(err);
  }
}

// Calls Rust `CreateOffer()` and writes the returned session description to the
// provided `MethodResult`.
void CreateOffer(
    Box<Webrtc>& webrtc,
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

  auto bind_success = std::bind(&callbacks::OnSuccessCreate,
                                rs,
                                std::placeholders::_1,
                                std::placeholders::_2);

  auto test = [&] (std::string a, std::string b) { 
    bind_success(a,b);
  };

  callbacks::Call<std::string, std::string> ccc = callbacks::Call<std::string, std::string>();
  auto lt = std::move(std::shared_ptr<callbacks::Call<std::string, std::string>>(&ccc));
  ccc.lt = std::move(lt);
  ccc.result = std::move(result);

  
  ccc.call = &callbacks::OnSuccessCreate;
  ccc("1","2");
  //size_t success = (size_t) ccc;

  //std::function<void(std::string, std::string)>* sss = (std::function<void(std::string, std::string)>*) success;

  //(*sss)("1","2");

  /*auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
  callbacks::callback_fail
      wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
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
  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }*/
};

// Calls Rust `CreateAnswer()`and writes the returned session description to the
// provided `MethodResult`.
void CreateAnswer(
    Box<Webrtc>& webrtc,
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

  auto bind_success = std::bind(&callbacks::OnSuccessCreate,
                                rs,
                                std::placeholders::_1,
                                std::placeholders::_2);
  callbacks::callback_success wrapp_success =
      Wrapper<0, void(std::string, std::string)>::wrap(bind_success);
  size_t success = (size_t) wrapp_success;

  auto bind_fail = std::bind(&callbacks::OnFail, rs, std::placeholders::_1);
  callbacks::callback_fail
      wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
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
  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }
};

// Calls Rust `SetLocalDescription()`.
void SetLocalDescription(
    Box<Webrtc>& webrtc,
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
  callbacks::callback_fail
      wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
  size_t fail = (size_t) wrapp_fail;

  auto bind_success = std::bind(&callbacks::OnSuccessDescription, rs);
  callbacks::callback_success_desc
      wrapp_success = Wrapper<0, void()>::wrap(bind_success);
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

  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }
};

// Calls Rust `SetRemoteDescription()`.
void SetRemoteDescription(
    Box<Webrtc>& webrtc,
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
  callbacks::callback_fail
      wrapp_fail = Wrapper<0, void(std::string)>::wrap(bind_fail);
  size_t fail = (size_t) wrapp_fail;

  auto bind_success = std::bind(&callbacks::OnSuccessDescription, rs);
  callbacks::callback_success_desc
      wrapp_success = Wrapper<0, void()>::wrap(bind_success);
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

  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }
};

}
