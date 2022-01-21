#include "flutter_peer_connection.h"
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

class MyObs : public MyObserver {
  public:
    void success(const std::string& sdp, const std::string& type) {
      flutter::EncodableMap params;
      params[flutter::EncodableValue("sdp")] = sdp;
      params[flutter::EncodableValue("type")] = type;
      result->Success(flutter::EncodableValue(params));
    };

    void fail(const std::string& error) {
      result->Error(error);
    };
    MyObs(std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res) : result(res) {}
  private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
};

namespace callbacks {


// Callback for write `CreateOffer/Answer` success result in flutter.
void OnSuccessCreate(
    std::string sdp,
    std::string type,
    size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  flutter::EncodableMap params;
  params[flutter::EncodableValue("sdp")] = sdp;
  params[flutter::EncodableValue("type")] = type;
  result->Success(flutter::EncodableValue(params));
}

// Callback for write `SetLocalDescription` success result in flutter.
void OnSuccessDescription(
    size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  result->Success(nullptr);
}

// Callback for write error in flutter.
void OnFail(
  std::string error,
  size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  result->Error(error);
}

void drop(size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  delete result;
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

  auto res = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(result.release());

  std::unique_ptr<MyObserver> obs = std::unique_ptr<MyObserver>(new MyObs(res));

  rust::String error;
  webrtc->CreateOffer(
      error,
      std::stoi(peerConnectionId),
      receive_video,
      receive_audio,
      voice_activity_detection,
      ice_restart,
      use_rtp_mux,
      std::move(obs)
  );
  if (error != "") {
  }
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

  /*std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

  callbacks::Call<std::string, std::string>* success_functor 
    = new callbacks::Call<std::string, std::string>(rs);
  success_functor->call = &callbacks::OnSuccessCreate;

  size_t success_funct = (size_t) success_functor;
  size_t success_fn = (size_t) callbacks::export_OnSuccessCreate;

  callbacks::Call<std::string>* fail_functor 
    = new callbacks::Call<std::string>(rs);
  fail_functor->call = callbacks::OnFail;

  size_t fail_funct = (size_t) fail_functor;
  size_t fail_fn = (size_t) callbacks::export_OnFail;

  size_t df = (size_t) callbacks::export_drop;

  rust::String error;
  webrtc->CreateAnswer(
      error,
      std::stoi(peerConnectionId),
      receive_video,
      receive_audio,
      voice_activity_detection,
      ice_restart,
      use_rtp_mux,
      success_fn,
      success_funct,
      fail_fn,
      fail_funct,
      df
  );
  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }*/
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

  /*std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

  callbacks::Call<>* success_functor 
    = new callbacks::Call<>(rs);
  success_functor->call = &callbacks::OnSuccessDescription;

  size_t success_funct = (size_t) success_functor;
  size_t success_fn = (size_t) callbacks::export_OnSuccessDescription;

  callbacks::Call<std::string>* fail_functor 
    = new callbacks::Call<std::string>(rs);
  fail_functor->call = callbacks::OnFail;

  size_t fail_funct = (size_t) fail_functor;
  size_t fail_fn = (size_t) callbacks::export_OnFail;

  rust::String error;
  webrtc->SetLocalDescription(
      error,
      std::stoi(peerConnectionId),
      type,
      sdp,
      success_fn,
      success_funct,
      fail_fn,
      fail_funct
  );

  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }*/
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

  /*std::shared_ptr<flutter::MethodResult<EncodableValue>> rs(result.release());

  callbacks::Call<>* success_functor 
    = new callbacks::Call<>(rs);
  success_functor->call = &callbacks::OnSuccessDescription;

  size_t success_funct = (size_t) success_functor;
  size_t success_fn = (size_t) callbacks::export_OnSuccessDescription;

  callbacks::Call<std::string>* fail_functor 
    = new callbacks::Call<std::string>(rs);
  fail_functor->call = callbacks::OnFail;

  size_t fail_funct = (size_t) fail_functor;
  size_t fail_fn = (size_t) callbacks::export_OnFail;

  rust::String error;
  webrtc->SetRemoteDescription(
      error,
      std::stoi(peerConnectionId),
      type,
      sdp,
      success_fn,
      success_funct,
      fail_fn,
      fail_funct
  );

  if (error != "") {
    std::string err(error);
    rs->Error("createAnswerOffer", err);
  }*/
};

}
