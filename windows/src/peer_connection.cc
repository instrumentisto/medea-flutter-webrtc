#include "peer_connection.h"
#include "media_stream.h"

#include <mutex>
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

  // Creates a new `CreateSdpCallback`.
  PeerConnectionOnEvent(std::shared_ptr<EventContext> context)
      : context_(std::move(context)) {};

  ~PeerConnectionOnEvent() {
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
      params[flutter::EncodableValue("event")] = "OnSignalingChange";
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
      params[flutter::EncodableValue("event")] = "OnStandardizedIceConnectionChange";
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
      params[flutter::EncodableValue("event")] = "OnConnectionChange";
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
      params[flutter::EncodableValue("event")] = "OnIceGatheringChange";
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
      params[flutter::EncodableValue("event")] = "OnNegotiationNeededEvent";
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
      params[flutter::EncodableValue("event")] = "OnIceCandidateError";
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
      params[flutter::EncodableValue("event")] = "OnIceCandidateError";
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
      params[flutter::EncodableValue("event")] = "OnIceConnectionReceivingChange";
      params[flutter::EncodableValue("receiving")] = receiving;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes `OnInterestingUsage` event 
  // an inner `flutter::EventSink`.
  void OnInterestingUsage(int usage_pattern) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[flutter::EncodableValue("event")] = "OnInterestingUsage";
      params[flutter::EncodableValue("usage_pattern")] = usage_pattern;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  };

  // Successfully writes serialized `OnInterestingUsage` event 
  // an inner `flutter::EventSink`.
  void OnIceCandidate(const std::string& candidate) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[flutter::EncodableValue("event")] = "OnIceCandidate";
      params[flutter::EncodableValue("candidate")] = candidate;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  // Successfully writes serialized `OnIceCandidatesRemoved` event 
  // an inner `flutter::EventSink`.
  void OnIceCandidatesRemoved(rust::Vec<rust::String> candidates) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableList candidate_list;
      for (int i = 0; i<candidates.size(); ++i) {
        candidate_list.push_back(std::string(candidates[i]));
      }
      flutter::EncodableMap params;
      params[flutter::EncodableValue("event")] = "OnIceCandidatesRemoved";
      params[flutter::EncodableValue("candidates")] = flutter::EncodableValue(candidate_list);
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  // Successfully writes serialized `OnIceSelectedCandidatePairChanged` event 
  // an inner `flutter::EventSink`.
  void OnIceSelectedCandidatePairChanged(CandidatePairChangeEventSerialized event) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap pair;
      pair[flutter::EncodableValue("local")] = std::string(event.selected_candidate_pair.local);
      pair[flutter::EncodableValue("remote")] = std::string(event.selected_candidate_pair.remote);

      flutter::EncodableMap params;
      params[flutter::EncodableValue("event")] = "OnIceSelectedCandidatePairChanged";
      params[flutter::EncodableValue("selected_candidate_pair")] = EncodableValue(pair);
      params[flutter::EncodableValue("estimated_disconnected_time_ms")] = event.estimated_disconnected_time_ms;
      params[flutter::EncodableValue("reason")] = std::string(event.reason);
      params[flutter::EncodableValue("last_data_received_ms")] = event.last_data_received_ms;
      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  void OnTrack(OnTrackSerialized transceiver) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      auto receiver = transceiver.receiver;
      flutter::EncodableList streams_info;
      for (int i = 0; i < transceiver.streams.size(); ++i) {
        streams_info.push_back(mediaStreamToMap(transceiver.streams[i]));
      }
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "onTrack";
      params[EncodableValue("streams")] = EncodableValue(streams_info);
      params[EncodableValue("track")] = EncodableValue(mediaTrackToMap(receiver.track));
      params[EncodableValue("receiver")] = EncodableValue(rtpReceiverToMap(receiver));
      params[EncodableValue("transceiver")] = EncodableValue(transceiverToMap(transceiver.transceiver));

      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

  void OnRemoveTrack(RtpReceiverInterfaceSerialized receiver) {
    const std::lock_guard<std::mutex> lock(*context_->channel_mutex);
    if (context_->event_sink.get() != nullptr) {
      flutter::EncodableMap params;
      params[EncodableValue("event")] = "OnRemoveTrack";
      params[EncodableValue("receiver")] = EncodableValue(rtpReceiverToMap(receiver));

      context_->event_sink.get()->Success(flutter::EncodableValue(params));
    }
  }

 private:
  // For initialization/reset `EventContext.event_sink` 
  // in flutter subscribe/unsubscribe event.
  // `shared_ptr` for shared context 
  // in `flutter::StreamHandlerFunctions` (subscribe/unsubscribe event).
  std::shared_ptr<EventContext> context_;

  flutter::EncodableMap transceiverToMap(RtpTransceiverInterfaceSerialized transceiver) {
    EncodableMap info;
    std::string mid = std::string(transceiver.mid);
    if (mid != "") {
      info[EncodableValue("transceiverId")] =  mid;
      info[EncodableValue("mid")] =  mid;
    }
    info[EncodableValue("direction")] = std::string(transceiver.direction);
    info[EncodableValue("sender")] =  rtpSenderToMap(transceiver.sender);
    info[EncodableValue("receiver")] =  rtpReceiverToMap(transceiver.receiver);
    return info;
  }
  
  EncodableMap rtpSenderToMap(RtpSenderInterfaceSerialized sender) {
    EncodableMap info;
    std::string id = std::string(sender.senderId);
    info[EncodableValue("senderId")] =  id;
    info[EncodableValue("ownsTrack")] =  EncodableValue(true);
    info[EncodableValue("dtmfSender")] = EncodableValue(
        dtmfSenderToMap(sender.dtmfSender, id));
    info[EncodableValue("rtpParameters")] = EncodableValue(
        rtpParametersToMap(sender.rtpParameters));
    info[EncodableValue("track")] =  EncodableValue(mediaTrackToMap(sender.track));
    return info;
  }

  EncodableMap dtmfSenderToMap(
    DtmfSenderInterfaceSerialized dtmfSender,
    std::string id) {
    EncodableMap info;
    if (!dtmfSender.is_null) {
      info[EncodableValue("dtmfSenderId")] = EncodableValue(id);
      info[EncodableValue("interToneGap")] =
          EncodableValue(dtmfSender.interToneGap);
      info[EncodableValue("duration")] = EncodableValue(dtmfSender.duration);
    }
    return info;
  }

  flutter::EncodableMap mediaStreamToMap(MediaStreamInterfaceSerialized stream) {
    EncodableMap params;
    params[EncodableValue("streamId")] =  std::string(stream.streamId);
    // params[EncodableValue("ownerTag")] =  EncodableValue(id);
    EncodableList audioTracks;
    auto audio_tracks = stream.audio_tracks;
    for (TrackInterfaceSerialized val : audio_tracks) {
      audioTracks.push_back(EncodableValue(mediaTrackToMap(val)));
    }
    params[EncodableValue("audioTracks")] =  EncodableValue(audioTracks);

    EncodableList videoTracks;
    auto video_tracks = stream.video_tracks;
    for (TrackInterfaceSerialized val : video_tracks) {
      videoTracks.push_back(EncodableValue(mediaTrackToMap(val)));
    }
    params[EncodableValue("videoTracks")] =  EncodableValue(videoTracks);
    return params;
  }

  flutter::EncodableMap mediaTrackToMap(TrackInterfaceSerialized track) {
    EncodableMap info;
    info[EncodableValue("id")] = std::string(track.id);
    info[EncodableValue("kind")] = std::string(track.kind);
    info[EncodableValue("label")] = std::string(track.kind);
    info[EncodableValue("readyState")] = std::string(track.state);
    info[EncodableValue("enabled")] = EncodableValue(track.enabled);
    return info;
  }

  EncodableMap rtpReceiverToMap(RtpReceiverInterfaceSerialized receiver) {
  EncodableMap info;
  info[EncodableValue("receiverId")] =  std::string(receiver.receiverId);
  info[EncodableValue("rtpParameters")] = EncodableValue(
      rtpParametersToMap(receiver.parameters));
  info[EncodableValue("track")] =  EncodableValue(mediaTrackToMap(receiver.track));
  return info;
}

EncodableMap rtpParametersToMap(RtpParametersSerialized rtpParameters) {
  EncodableMap info;
  info[EncodableValue("transactionId")] = std::string(rtpParameters.transactionId);

  EncodableMap rtcp;
  rtcp[EncodableValue("cname")] =
      std::string(rtpParameters.rtcp.cname);
  rtcp[EncodableValue("reducedSize")] =
      EncodableValue(rtpParameters.rtcp.reduced_size);

  info[EncodableValue("rtcp")] = EncodableValue(rtcp);

  EncodableList headerExtensions;
  auto header_extensions = rtpParameters.header_extensions;
  for (RtpExtensionSerialized extension :
       rtpParameters.header_extensions) {
    EncodableMap map;
    map[EncodableValue("uri")] = std::string(extension.uri);
    map[EncodableValue("id")] = EncodableValue(extension.id);
    map[EncodableValue("encrypted")] = EncodableValue(extension.encrypted);
    headerExtensions.push_back(EncodableValue(map));
  }
  info[EncodableValue("headerExtensions")] = EncodableValue(headerExtensions);

  EncodableList encodings_info;
  auto encodings = rtpParameters.encodings;
  for (RtpEncodingParametersSerialized encoding :
       rtpParameters.encodings) {
    EncodableMap map;
    map[EncodableValue("active")] = EncodableValue(encoding.active);
    map[EncodableValue("maxBitrate")] = EncodableValue(encoding.maxBitrate);
    map[EncodableValue("minBitrate")] = EncodableValue(encoding.minBitrate);
    map[EncodableValue("maxFramerate")] = EncodableValue(encoding.maxFramerate);
    map[EncodableValue("scaleResolutionDownBy")] =
        EncodableValue(encoding.scaleResolutionDownBy);
    map[EncodableValue("ssrc")] = EncodableValue((long)encoding.ssrc);
    encodings_info.push_back(EncodableValue(map));
  }
  info[EncodableValue("encodings")] = EncodableValue(encodings_info);

  EncodableList codecs_info;
  for (RtpCodecParametersSerialized codec : rtpParameters.codecs) {
    EncodableMap map;
    map[EncodableValue("name")] = std::string(codec.name);
    map[EncodableValue("payloadType")] = EncodableValue(codec.payloadType);
    map[EncodableValue("clockRate")] = EncodableValue(codec.clockRate);
    map[EncodableValue("numChannels")] = EncodableValue(codec.numChannels);

    EncodableMap param;
    for (auto item : codec.parameters) {
      param[EncodableValue(std::string(item.first))] = EncodableValue(std::string(item.second));
    }
    map[EncodableValue("parameters")] = EncodableValue(param);

    map[EncodableValue("kind")] = EncodableValue(std::string(codec.kind));

    codecs_info.push_back(EncodableValue(map));
  }
  info[EncodableValue("codecs")] = EncodableValue(codecs_info);

  return info;
}
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

  std::shared_ptr<PeerConnectionOnEvent::EventContext> event_context =
      std::make_shared<PeerConnectionOnEvent::EventContext>(
        std::move(PeerConnectionOnEvent::EventContext()));

  std::unique_ptr<PeerConnectionOnEventInterface> event_callback =
      std::unique_ptr<PeerConnectionOnEventInterface>(
          new PeerConnectionOnEvent(event_context));

  std::weak_ptr<PeerConnectionOnEvent::EventContext> weak_context(
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
      params[flutter::EncodableValue("peerConnectionId")] = std::to_string(id);
      result->Success(EncodableValue(params));
    } else {
     result->Error(std::string(error));
  }
}

// Calls Rust `CreateOffer()` and writes the returned session description to the
// provided `MethodResult`.
void CreateOffer(
    Box<Webrtc>& webrtc,
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
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
