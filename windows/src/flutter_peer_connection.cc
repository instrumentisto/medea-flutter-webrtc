#include "flutter_peer_connection.h"
#include "media_stream.h"

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

// todo.
struct EventContext {
 public:
  std::unique_ptr<std::mutex> channel_m = std::make_unique<std::mutex>();
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> lt_channel;
};

#include "flutter_webrtc.h"
#include "flutter-webrtc-native/include/api.h"

using namespace rust::cxxbridge1;

// `CreateSdpCallbackInterface` implementation that forwards completion result
// to the Flutter side via inner `flutter::MethodResult`.
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

  // Forwards the provided error to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

// `SetDescriptionCallbackInterface` implementation that forwards completion
// result to the Flutter side via inner `flutter::MethodResult`.
class SetDescriptionCallBack : public SetDescriptionCallbackInterface {
 public:
  SetDescriptionCallBack(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result_(std::move(res)) {}

  // Successfully completes an inner `flutter::MethodResult`.
  void OnSuccess() { result_->Success(nullptr); }

  // Forwards the provided error to the `flutter::MethodResult` error.
  void OnFail(const std::string& error) { result_->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result_;
};

class PeerConnectionOnEvent : public PeerConnectionOnEventInterface {
 public:
  PeerConnectionOnEvent(std::shared_ptr<EventContext> context)
      : context(std::move(context)){};
  void OnSignalingChange(const SignalingStateWrapper& new_state) {
    const std::lock_guard<std::mutex> lock(*context->channel_m);
    if(context->event_sink.get() != nullptr) {
      context->event_sink.get()->Success(EncodableValue(new_state.ToString().c_str())); 
    }
  }

  void OnStandardizedIceConnectionChange(const IceConnectionStateWrapper& new_state) {
        const std::lock_guard<std::mutex> lock(*context->channel_m);
    if(context->event_sink.get() != nullptr) {
      context->event_sink.get()->Success(EncodableValue(new_state.ToString().c_str())); 
    }
  };
  void OnConnectionChange(const PeerConnectionStateWrapper& new_state) {
        const std::lock_guard<std::mutex> lock(*context->channel_m);
    if(context->event_sink.get() != nullptr) {
      context->event_sink.get()->Success(EncodableValue(new_state.ToString().c_str())); 
    }
  };
  void OnIceGatheringChange(const IceGatheringStateWrapper& new_state) {
        const std::lock_guard<std::mutex> lock(*context->channel_m);
    if(context->event_sink.get() != nullptr) {
      context->event_sink.get()->Success(EncodableValue(new_state.ToString().c_str())); 
    }
  };

  ~PeerConnectionOnEvent() {
    const std::lock_guard<std::mutex> lock(*context->channel_m);
    if(context->event_sink.get() != nullptr) {
      context->event_sink.get()->EndOfStream();
    }
  }

 private:
  std::shared_ptr<EventContext> context;
};

namespace flutter_webrtc_plugin {

using namespace flutter;
// Calls Rust `CreatePeerConnection()` and writes newly created Peer ID to the
// provided `MethodResult`.
void CreateRTCPeerConnection(
    flutter::BinaryMessenger* messenger,
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  std::shared_ptr<EventContext> event_context =
      std::make_shared<EventContext>(std::move(EventContext()));
  std::unique_ptr<PeerConnectionOnEventInterface> event_callback =
      std::unique_ptr<PeerConnectionOnEventInterface>(
          new PeerConnectionOnEvent(event_context));

  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [=](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        const std::lock_guard<std::mutex> lock(*event_context->channel_m);
        event_context->event_sink = std::move(events);
        return nullptr;
      },

      [=](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        const std::lock_guard<std::mutex> lock(*event_context->channel_m);
        event_context->event_sink.reset();
        return nullptr;
      });

  // create id
  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(std::move(event_callback), error);

  if (error == "") {
    std::string peer_connection_id = std::to_string(id);
    auto event_channel = std::unique_ptr<EventChannel<EncodableValue>>(
        new EventChannel<EncodableValue>(
            messenger, "PeerConnection/Event/channel/id/" + peer_connection_id,
            &StandardMethodCodec::GetInstance()));
    event_channel->SetStreamHandler(std::move(handler));
    event_context->lt_channel = std::move(event_channel);

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

  rust::String error = webrtc->CreateOffer(std::stoi(peerConnectionId),
                                           voice_activity_detection,
                                           ice_restart,
                                           use_rtp_mux,
                                           std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
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

  rust::String error = webrtc->CreateAnswer(std::stoi(peerConnectionId),
                                            voice_activity_detection,
                                            ice_restart,
                                            use_rtp_mux,
                                            std::move(callback));

  if (error != "") {
    shared_result->Error("createAnswerOffer", std::string(error));
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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetLocalDescription(std::stoi(peerConnectionId),
                                                   type,
                                                   sdp,
                                                   std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
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

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error = webrtc->SetRemoteDescription(std::stoi(peerConnectionId),
                                                    type,
                                                    sdp,
                                                    std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
};

void DeletePC(Box<Webrtc>& webrtc,
              const flutter::MethodCall<EncodableValue>& method_call,
              std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");
  webrtc->DeletePeerConnection(stoi(peerConnectionId));
  result->Success(nullptr);
};

}  // namespace flutter_webrtc_plugin
