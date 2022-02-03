#include "flutter_peer_connection.h"
#include "media_stream.h"

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>
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


// `PeerConnectionOnEventInterface` implementation that forwards completion
// events to the Flutter side via inner `flutter::EventSink`.
class PeerConnectionOnEvent : public PeerConnectionOnEventInterface {
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

  PeerConnectionOnEvent(std::shared_ptr<EventContext> context, rust::Box<Webrtc>* webrtc)
      : context_(std::move(context)), webrtc_(webrtc) {};

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

  // Successfully writes serialized `OnStandardizedIceConnectionChange` event 
  // an inner `flutter::EventSink`.
  void OnStandardizedIceConnectionChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnStandardizedIceConnectionChange";
      params[flutter::EncodableValue("new_state")] =
          new_state;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnConnectionChange` event 
  // an inner `flutter::EventSink`.
  void OnConnectionChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnConnectionChange";
      params[flutter::EncodableValue("new_state")] =
          std::string(new_state);
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnIceGatheringChange` event 
  // an inner `flutter::EventSink`.
  void OnIceGatheringChange(const std::string& new_state) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceGatheringChange";
      params[flutter::EncodableValue("new_state")] =
          new_state;
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

  // Successfully writes `OnIceConnectionReceivingChange` event 
  // an inner `flutter::EventSink`.
  void OnIceConnectionReceivingChange(bool receiving) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceConnectionReceivingChange";
      params[EncodableValue("receiving")] = receiving;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes `OnInterestingUsage` event 
  // an inner `flutter::EventSink`.
  void OnInterestingUsage(int usage_pattern) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnInterestingUsage";
      params[EncodableValue("usage_pattern")] = usage_pattern;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnInterestingUsage` event 
  // an inner `flutter::EventSink`.
  void OnIceCandidate(const std::string& candidate) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceCandidate";
      params[EncodableValue("candidate")] = candidate;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

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

  // Successfully writes serialized `OnIceSelectedCandidatePairChanged` event 
  // an inner `flutter::EventSink`.
  void OnIceSelectedCandidatePairChanged(CandidatePairChangeEventSerialized event) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap pair;
      pair[EncodableValue("local")] = std::string(event.selected_candidate_pair.local);
      pair[EncodableValue("remote")] = std::string(event.selected_candidate_pair.remote);

      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnIceSelectedCandidatePairChanged";
      params[EncodableValue("selected_candidate_pair")] = EncodableValue(pair);
      params[EncodableValue("estimated_disconnected_time_ms")] = event.estimated_disconnected_time_ms;
      params[EncodableValue("reason")] = std::string(event.reason);
      params[EncodableValue("last_data_received_ms")] = event.last_data_received_ms;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  ~PeerConnectionOnEvent() {
    printf("YES I AM DROP\n");
  }

 private:
  // For initialization/reset `EventContext.event_sink` 
  // in flutter subscribe/unsubscribe event.
  // `shared_ptr` for shared context 
  // in `flutter::StreamHandlerFunctions` (subscribe/unsubscribe event).
  std::shared_ptr<EventContext> context_;

  // todo megrate to new PR.
  rust::Box<Webrtc>* webrtc_;
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

  rust::Box<Webrtc>* webrtc_(&webrtc);
  std::shared_ptr<PeerConnectionOnEvent::EventContext> event_context =
      std::make_shared<PeerConnectionOnEvent::EventContext>(std::move(PeerConnectionOnEvent::EventContext()));

  std::unique_ptr<PeerConnectionOnEventInterface> event_callback =
      std::unique_ptr<PeerConnectionOnEventInterface>(
          new PeerConnectionOnEvent(event_context, webrtc_));

  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [=](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) 
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        const std::lock_guard<std::mutex> lock(*event_context->channel_mutex);
        event_context->event_sink = std::move(events);
        return nullptr;
      },

      [=](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        const std::lock_guard<std::mutex> lock(*event_context->channel_mutex);
        event_context->event_sink.reset();
        return nullptr;
      });

  rust::cxxbridge1::String error;
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

  rust::cxxbridge1::String error =
      webrtc->CreateOffer(std::stoi(peerConnectionId), voice_activity_detection,
                          ice_restart, use_rtp_mux, std::move(callback));

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

  rust::cxxbridge1::String error = webrtc->CreateAnswer(
      std::stoi(peerConnectionId), voice_activity_detection, ice_restart,
      use_rtp_mux, std::move(callback));

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
  rust::cxxbridge1::String type = findString(constraints, "type");
  rust::cxxbridge1::String sdp = findString(constraints, "sdp");

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::cxxbridge1::String error = webrtc->SetLocalDescription(
      std::stoi(peerConnectionId), type, sdp, std::move(callback));

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
  rust::cxxbridge1::String type = findString(constraints, "type");
  rust::cxxbridge1::String sdp = findString(constraints, "sdp");

  auto shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::cxxbridge1::String error = webrtc->SetRemoteDescription(
      std::stoi(peerConnectionId), type, sdp, std::move(callback));

  if (error != "") {
    shared_result->Error("SetLocalDescription", std::string(error));
  }
};

// todo delete. fn for peerconnection memory leak.
void DeletePC(Box<Webrtc>& webrtc,
              const flutter::MethodCall<EncodableValue>& method_call,
              std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");
  webrtc->DeletePeerConnection(stoi(peerConnectionId));
  result->Success(nullptr);
};

}  // namespace flutter_webrtc_plugin
