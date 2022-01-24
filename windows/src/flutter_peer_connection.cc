#include "flutter_peer_connection.h"
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

namespace callbacks {


// Callback for write `CreateOffer/Answer` success result in flutter.
extern "C" void  OnSuccessCreate(
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
extern "C" void OnSuccessDescription(
    size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  result->Success(nullptr);
}

// Callback for write error in flutter.
extern "C" void OnFail(
  std::string error,
  size_t context) {
  auto result = (flutter::MethodResult<flutter::EncodableValue>*) context;
  result->Error(error);
}

extern "C" void drop(size_t context) {
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

  auto res = result.release();
  size_t context = (size_t) res;
  size_t success = (size_t) &callbacks::OnSuccessCreate;
  size_t fail = (size_t) &callbacks::OnFail;
  size_t drop = (size_t) &callbacks::drop;

  auto sdp_callback = create_sdp_callback(
      success,
      fail,
      drop,
      context);

  rust::String error;
  webrtc->CreateOffer(
      error,
      std::stoi(peerConnectionId),
      receive_video,
      receive_audio,
      voice_activity_detection,
      ice_restart,
      use_rtp_mux,
      std::move(sdp_callback)
  );
  if (error != "") {
    std::string err(error);
    res->Error("createAnswerOffer", err);
    delete res;
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
  // TODO: Option<true>
  //        None => -1
  //        true => 1
  //        false => 0
  //        we are passing None
  receive_audio = findBool(mandatory, "OfferToReceiveAudio");
  receive_video = findBool(mandatory, "OfferToReceiveVideo");

  auto res = result.release();

  auto sdp_callback = create_sdp_callback(
      (size_t) callbacks::OnSuccessCreate,
      (size_t) callbacks::OnFail,
      (size_t) callbacks::drop,
      (size_t) res);

  rust::String error;
  webrtc->CreateAnswer(
      error,
      std::stoi(peerConnectionId),
      receive_video,
      receive_audio,
      voice_activity_detection,
      ice_restart,
      use_rtp_mux,
      std::move(sdp_callback)
  );
  if (error != "") {
    std::string err(error);
    res->Error("createAnswerOffer", err);
    delete res;
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

  auto res = result.release();
  size_t context = (size_t) res;
  size_t success = (size_t) &callbacks::OnSuccessDescription;
  size_t fail = (size_t) &callbacks::OnFail;
  size_t drop = (size_t) &callbacks::drop;

  rust::String error;
  webrtc->SetLocalDescription(
      error,
      std::stoi(peerConnectionId),
      type,
      sdp,
      success,
      fail,
      drop,
      context
  );

  if (error != "") {
    std::string err(error);
    res->Error("SetLocalDescription", err);
    delete res;
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

  auto res = result.release();
  size_t context = (size_t) res;
  size_t success = (size_t) &callbacks::OnSuccessDescription;
  size_t fail = (size_t) &callbacks::OnFail;
  size_t drop = (size_t) &callbacks::drop;

  rust::String error;
  webrtc->SetRemoteDescription(
      error,
      std::stoi(peerConnectionId),
      type,
      sdp,
      success,
      fail,
      drop,
      context
  );

  if (error != "") {
    std::string err(error);
    res->Error("SetLocalDescription", err);
    delete res;
  }
};

}
