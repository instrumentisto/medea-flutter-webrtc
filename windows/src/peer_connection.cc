#include <mutex>

#include "peer_connection.h"
#include "media_stream.h"
#include "flutter_webrtc.h"
#include "flutter-webrtc-native/include/api.h"
#include "flutter/standard_method_codec.h"
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

// `PeerConnectionObserverInterface` implementation that forwards completion
// events to the Flutter side via inner `flutter::EventSink`.
class PeerConnectionObserver : public PeerConnectionObserverInterface {
 public:

  // `EventContext` provides `PeerConnection` events recording to flutter.
  struct EventContext {
    // Mutex uses for thread safe access `event_sink`.
    std::unique_ptr<std::mutex> channel_mutex = std::make_unique<std::mutex>();
    // flutter::EventSink for writes PeerConnection events.
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink;
    // Owns for lifetime flutter::EventChannel.
    std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> _lt_channel;
  };

  // Creates a new `CreateSdpCallback`.
  PeerConnectionObserver(std::shared_ptr<EventContext> context)
      : context_(std::move(context)) {};

  ~PeerConnectionObserver() {
    if (context_->_lt_channel.get() != nullptr){
      context_->_lt_channel->SetStreamHandler(nullptr);
    }
  }

  // Successfully writes serialized `OnSignalingChange` event
  // an inner `flutter::EventSink`.
  void OnSignalingChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnSignalingChange";
      params[flutter::EncodableValue("new_state")] =
          new_state;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  // Successfully writes serialized `OnIceConnectionStateChange` event
  // an inner `flutter::EventSink`.
  void OnIceConnectionStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceConnectionStateChange";
      params[flutter::EncodableValue("new_state")] = new_state;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnConnectionStateChange` event
  // an inner `flutter::EventSink`.
  void OnConnectionStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnConnectionStateChange";
      params[flutter::EncodableValue("new_state")] = std::string(new_state);
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnIceGatheringStateChange` event
  // an inner `flutter::EventSink`.
  void OnIceGatheringStateChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceGatheringStateChange";
      params[flutter::EncodableValue("new_state")] = new_state;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes `OnNegotiationNeededEvent` event
  // an inner `flutter::EventSink`.
  void OnNegotiationNeededEvent(uint32_t event_id) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnNegotiationNeededEvent";
      params[flutter::EncodableValue("event_id")] = (int64_t)event_id;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes `OnIceCandidateError` event
  // an inner `flutter::EventSink`.
  void OnIceCandidateError(const std::string& host_candidate,
                           const std::string& url,
                           int error_code,
                           const std::string& error_text) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidateError";
      params[flutter::EncodableValue("host_candidate")] = host_candidate;
      params[flutter::EncodableValue("url")] = url;
      params[flutter::EncodableValue("error_code")] = error_code;
      params[flutter::EncodableValue("error_text")] = error_text;

      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes `OnIceCandidateError` event
  // an inner `flutter::EventSink`.
  void OnIceCandidateError(const std::string& address,
                           int port,
                           const std::string& url,
                           int error_code,
                           const std::string& error_text) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidateError";
      params[flutter::EncodableValue("address")] = address;
      params[flutter::EncodableValue("port")] = port;
      params[flutter::EncodableValue("error_code")] = error_code;
      params[flutter::EncodableValue("error_text")] = error_text;

      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnIceCandidatesRemoved` event
  // an inner `flutter::EventSink`.
  void OnIceCandidatesRemoved(rust::Vec<rust::String> candidates) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      EncodableList candidate_list;
      for (int i = 0; i<candidates.size(); ++i) {
        candidate_list.push_back(std::string(candidates[i]));
      }
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidatesRemoved";
      params[EncodableValue("candidates")] = EncodableValue(candidate_list);
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

 private:
  // For initialization/reset `EventContext.event_sink`
  // in flutter subscribe/unsubscribe event.
  // `shared_ptr` for shared context
  // in `flutter::StreamHandlerFunctions` (subscribe/unsubscribe event).
  std::shared_ptr<EventContext> context_;
};

namespace flutter_webrtc_plugin {

using namespace flutter;

// Calls Rust `CreatePeerConnection()` and writes newly created peer ID to the
// provided `MethodResult`.
void CreateRTCPeerConnection(
    flutter::BinaryMessenger* messenger,
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {

  std::shared_ptr<PeerConnectionObserver::EventContext> event_context =
      std::make_shared<PeerConnectionObserver::EventContext>(
        std::move(PeerConnectionObserver::EventContext()));

  std::unique_ptr<PeerConnectionObserverInterface> event_callback =
      std::unique_ptr<PeerConnectionObserverInterface>(
          new PeerConnectionObserver(event_context));

  std::weak_ptr<PeerConnectionObserver::EventContext> weak_context(
      event_context);
  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [=](
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        auto context = weak_context.lock();
        if (context) {
          const std::lock_guard<std::mutex> lock(*context->channel_mutex);
          context->event_sink = std::move(events);
        }
        return nullptr;
      },

      [=](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        auto context = weak_context.lock();
        if (context) {
          const std::lock_guard<std::mutex> lock(*context->channel_mutex);
          context->event_sink.reset();
        }
        return nullptr;
      });

  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(std::move(event_callback), error);
  if (error == "") {
      std::string peer_connection_id = std::to_string(id);
      auto event_channel = std::unique_ptr<EventChannel<EncodableValue>>(
          new EventChannel<EncodableValue>(
              messenger, "PeerConnection/Event/channel/id/" + peer_connection_id,
              &StandardMethodCodec::GetInstance()));

      event_channel->SetStreamHandler(std::move(handler));
      event_context->_lt_channel = std::move(event_channel);

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

  rust::String error = webrtc->CreateAnswer(std::stoi(peerConnectionId),
                                            voice_activity_detection,
                                            ice_restart,
                                            use_rtp_mux,
                                            std::move(callback));

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

  rust::String error = webrtc->SetLocalDescription(std::stoi(peerConnectionId),
                                                   type,
                                                   sdp,
                                                   std::move(callback));

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

  rust::String error = webrtc->SetRemoteDescription(std::stoi(peerConnectionId),
                                                    type,
                                                    sdp,
                                                    std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
}

}  // namespace flutter_webrtc_plugin
