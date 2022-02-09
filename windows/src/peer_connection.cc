#include "peer_connection.h"
#include "flutter-webrtc-native/include/api.h"
#include "flutter_webrtc.h"
#include "parsing.h"

using namespace rust::cxxbridge1;

// `CreateSdpCallbackInterface` implementation forwarding completion result to
// the Flutter side via inner `flutter::MethodResult`.
class CreateSdpCallback : public CreateSdpCallbackInterface {
 public:
  // Creates a new `CreateSdpCallback`.
  CreateSdpCallback(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result_(std::move(res)) {}

  // Forwards the provided SDP to the `flutter::MethodResult` success.
  void OnSuccess(const std::string& sdp, const std::string& type_) {
    flutter::EncodableMap params;
    params[flutter::EncodableValue("sdp")] = sdp;
    params[flutter::EncodableValue("type")] = type_;
    result_->Success(flutter::EncodableValue(params));
  }

  // Forwards the provided `error` to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

// `SetDescriptionCallbackInterface` implementation forwarding completion result
// to the Flutter side via inner `flutter::MethodResult`.
class SetDescriptionCallBack : public SetDescriptionCallbackInterface {
 public:
  SetDescriptionCallBack(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result_(std::move(res)) {}

  // Successfully completes an inner `flutter::MethodResult`.
  void OnSuccess() { result_->Success(nullptr); }

  // Forwards the provided `error` to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

namespace flutter_webrtc_plugin {

using namespace flutter;

// Calls Rust `CreatePeerConnection()` and writes newly created peer ID to the
// provided `MethodResult`.
void CreateRTCPeerConnection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(error);

  if (error == "") {
    EncodableMap params;
    params[EncodableValue("peerConnectionId")] = std::to_string(id);
    result->Success(EncodableValue(params));
  } else {
    result->Error(std::string(error));
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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error =
      webrtc->CreateOffer(std::stoi(peerConnectionId), voice_activity_detection,
                          ice_restart, use_rtp_mux, std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
  }
}

// Calls Rust `CreateAnswer()` and writes the returned session description to
// the provided `MethodResult`.
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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error = webrtc->CreateAnswer(
      std::stoi(peerConnectionId), voice_activity_detection, ice_restart,
      use_rtp_mux, std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
  }
}

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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetLocalDescription(
      std::stoi(peerConnectionId), type, sdp, std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
}

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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetRemoteDescription(
      std::stoi(peerConnectionId), type, sdp, std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
}

// Converts Rust `TransceiverInfo` to Dart `EncodableMap`.
EncodableMap TransceiverToMap(TransceiverInfo transceiver) {
  EncodableMap info;

  info[EncodableValue("transceiverId")] =
      EncodableValue(std::to_string(transceiver.id));
  info[EncodableValue("mid")] = EncodableValue(std::string(transceiver.mid));
  info[EncodableValue("direction")] =
      EncodableValue(std::string(transceiver.direction));
  info[EncodableValue("sender")] = EncodableValue(EncodableMap());
  info[EncodableValue("receiver")] = EncodableValue(EncodableMap());

  return info;
};

// Calls Rust `AddTransceiver()`.
void AddTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto transceiver = webrtc->AddTransceiver(
      std::stoi(findString(params, "peerConnectionId")),
      findString(params, "mediaType"),
      findString(findMap(params, "transceiverInit"), "direction"));

  result->Success(EncodableValue(TransceiverToMap(transceiver)));
}

// Calls Rust `GetTransceivers()`.
void GetTransceivers(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto transceivers = webrtc->GetTransceivers(
      std::stoi(findString(params, "peerConnectionId")));

  EncodableMap map;
  EncodableList infos;

  for (auto transceiver : transceivers) {
    infos.push_back(TransceiverToMap(transceiver));
  }

  map[EncodableValue("transceivers")] = EncodableValue(infos);

  result->Success(EncodableValue(map));
}

void StopTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  webrtc->StopTransceiver(std::stoi(findString(params, "peerConnectionId")),
                          std::stoi(findString(params, "transceiverId")));

  result->Success();
}

void DisposeTransceiver(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  webrtc->DisposeTransceiver(std::stoi(findString(params, "peerConnectionId")),
                             std::stoi(findString(params, "transceiverId")));

  result->Success();
}

void SetTransceiverDirection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  webrtc->SetTransceiverDirection(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")),
      findString(params, "direction"));

  result->Success();
}

void GetTransceiverDirection(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto direction = (std::string)webrtc->GetTransceiverDirection(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")));

  EncodableMap map;
  map[EncodableValue("result")] = EncodableValue(direction);

  result->Success(map);
}

void GetTransceiverMid(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (!method_call.arguments()) {
    result->Error("Bad Arguments", "Null constraints arguments received");
    return;
  }

  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());

  auto mid = (std::string)webrtc->GetTransceiverMid(
      std::stoi(findString(params, "peerConnectionId")),
      std::stoi(findString(params, "transceiverId")));

  EncodableMap map;
  map[EncodableValue("mid")] = EncodableValue(mid);

  result->Success(map);
}

}  // namespace flutter_webrtc_plugin
