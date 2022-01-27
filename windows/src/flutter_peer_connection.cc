#include "flutter_peer_connection.h"
#include "media_stream.h"

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>
#include "flutter_webrtc.h"

using namespace rust::cxxbridge1;

template <class T>
class atomic_unique_ptr {
  using pointer = T*;
  std::atomic<pointer> ptr;

 public:
  constexpr atomic_unique_ptr() noexcept : ptr() {}
  explicit atomic_unique_ptr(pointer p) noexcept : ptr(p) {}
  atomic_unique_ptr(atomic_unique_ptr&& p) noexcept : ptr(p.release()) {}
  atomic_unique_ptr& operator=(atomic_unique_ptr&& p) noexcept {
    reset(p.release());
    return *this;
  }
  atomic_unique_ptr(std::unique_ptr<T>&& p) noexcept : ptr(p.release()) {}
  atomic_unique_ptr& operator=(std::unique_ptr<T>&& p) noexcept {
    reset(p.release());
    return *this;
  }

  void reset(pointer p = pointer()) {
    auto old = ptr.exchange(p);
    if (old)
      delete old;
  }
  operator pointer() const { return ptr; }
  pointer operator->() const { return ptr; }
  pointer get() const { return ptr; }
  explicit operator bool() const { return ptr != pointer(); }
  pointer release() { return ptr.exchange(pointer()); }
  ~atomic_unique_ptr() { reset(); }
};

// todo.
struct EventContext {
 public:
  atomic_unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink;
  atomic_unique_ptr<flutter::EventChannel<flutter::EncodableValue>> lt_channel;
};

#include "flutter_webrtc.h"
#include "flutter_webrtc_native/include/api.h"

using namespace rust::cxxbridge1;

class CreateSdpCallback : public CreateSdpCallbackInterface {
 public:
  CreateSdpCallback(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result(std::move(res)) {}
  void OnSuccess(const std::string& sdp, const std::string& type_) {
    flutter::EncodableMap params;
    params[flutter::EncodableValue("sdp")] = sdp;
    params[flutter::EncodableValue("type")] = type_;
    result->Success(flutter::EncodableValue(params));
  }
  void OnFail(const std::string& error) { result->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
};

class SetDescriptionCallBack : public SetDescriptionCallbackInterface {
 public:
  SetDescriptionCallBack(
      std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> res)
      : result(std::move(res)) {}
  void OnSuccess() { result->Success(nullptr); }
  void OnFail(const std::string& error) { result->Error(error); }

 private:
  std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
};

class PeerConnectionOnEvent : public PeerConnectionOnEventInterface {
 public:
  PeerConnectionOnEvent(std::shared_ptr<EventContext> context)
      : context(context){};
  void OnSignalingChange(const std::string& event) {
    context->event_sink.get()->Success(EncodableValue(event));
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
      std::make_shared<EventContext>(EventContext());
  std::unique_ptr<PeerConnectionOnEventInterface> event_callback =
      std::unique_ptr<PeerConnectionOnEventInterface>(
          new PeerConnectionOnEvent(event_context));

  // create id
  rust::String error;
  uint64_t id = webrtc->CreatePeerConnection(error, std::move(event_callback));

  auto handler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
      [=](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_context->event_sink = std::move(events);
        return nullptr;
      },

      [=](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<StreamHandlerError<flutter::EncodableValue>> {
        event_context->event_sink.reset();
        return nullptr;
      });

  std::string peer_connection_id = std::to_string(id);
  auto event_channel = std::unique_ptr<EventChannel<EncodableValue>>(
      new EventChannel<EncodableValue>(
          messenger, "PeerConnection/Event/channel/id/" + peer_connection_id,
          &StandardMethodCodec::GetInstance()));
  event_channel->SetStreamHandler(std::move(handler));

  event_context->lt_channel = std::move(event_channel);

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

  std::shared_ptr<flutter::MethodResult<EncodableValue>> shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error;
  webrtc->CreateOffer(error, std::stoi(peerConnectionId),
                      voice_activity_detection, ice_restart, use_rtp_mux,
                      std::move(callback));
  if (error != "") {
    std::string err(error);
    shared_result->Error("createAnswerOffer", err);
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

  std::shared_ptr<flutter::MethodResult<EncodableValue>> shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<CreateSdpCallbackInterface>(
      new CreateSdpCallback(shared_result));

  rust::String error;
  webrtc->CreateAnswer(error, std::stoi(peerConnectionId),
                       voice_activity_detection, ice_restart, use_rtp_mux,
                       std::move(callback));
  if (error != "") {
    std::string err(error);
    shared_result->Error("createAnswerOffer", err);
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

  std::shared_ptr<flutter::MethodResult<EncodableValue>> shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error;
  webrtc->SetLocalDescription(error, std::stoi(peerConnectionId), type, sdp,
                              std::move(callback));

  if (error != "") {
    std::string err(error);
    shared_result->Error("SetLocalDescription", err);
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

  std::shared_ptr<flutter::MethodResult<EncodableValue>> shared_result =
      std::shared_ptr<flutter::MethodResult<EncodableValue>>(result.release());

  auto callback = std::unique_ptr<SetDescriptionCallbackInterface>(
      new SetDescriptionCallBack(shared_result));

  rust::String error;
  webrtc->SetRemoteDescription(error, std::stoi(peerConnectionId), type, sdp,
                               std::move(callback));

  if (error != "") {
    std::string err(error);
    shared_result->Error("SetLocalDescription", err);
  }
};

void DeletePC(Box<Webrtc>& webrtc,
              const flutter::MethodCall<EncodableValue>& method_call,
              std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const EncodableMap params = GetValue<EncodableMap>(*method_call.arguments());
  const std::string peerConnectionId = findString(params, "peerConnectionId");
  webrtc->DeletePeerConnection(stoi(peerConnectionId));
};

}  // namespace flutter_webrtc_plugin
