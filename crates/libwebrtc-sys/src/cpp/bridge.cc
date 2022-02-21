#include <cstdint>
#include <memory>
#include <string>

#include "api/video/i420_buffer.h"
#include "libwebrtc-sys/include/bridge.h"
#include "libyuv.h"
#include "modules/audio_device/include/audio_device_factory.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

// Creates a new `TrackEventObserver`.
TrackEventObserver::TrackEventObserver(
    rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> track,
    rust::Box<bridge::DynTrackEventCallback> cb)
    : track_(track), cb_(std::move(cb)) {

  webrtc::MediaSourceInterface* source;
  if (track->kind() == "video") {
    auto video_track = static_cast<webrtc::VideoTrackInterface*>(track.get());
    source =
        static_cast<webrtc::MediaSourceInterface*>(video_track->GetSource());
  } else {
    auto audio_track = static_cast<webrtc::AudioTrackInterface*>(track.get());
    source =
        static_cast<webrtc::MediaSourceInterface*>(audio_track->GetSource());
  }

  this->source_obs = std::make_unique<SourceEventObserver>([=] {
    webrtc::MediaSourceInterface::SourceState state;
    if (track->kind() == "video") {
      auto video_track = static_cast<webrtc::VideoTrackInterface*>(track.get());
      state = video_track->GetSource()->state();

    } else {
      auto audio_track = static_cast<webrtc::AudioTrackInterface*>(track.get());
      state = audio_track->GetSource()->state();
    }

    if (state == webrtc::MediaSourceInterface::SourceState::kMuted) {
      bridge::on_mute(*cb_);
    } else if (state == webrtc::MediaSourceInterface::SourceState::kLive) {
      bridge::on_unmute(*cb_);
    }
  });

  if (source != nullptr) {
    source->RegisterObserver(this->source_obs.get());
  }
}

// Called when track calls `set_state` or `set_enabled`.
void TrackEventObserver::OnChanged() {
  if (track_ != nullptr) {
    if (track_->state() ==
        webrtc::MediaStreamTrackInterface::TrackState::kEnded) {
      bridge::on_ended(*cb_);
    }
  }
}

// Calls `AudioDeviceModule->Create()`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory& task_queue_factory) {
  auto adm =
      webrtc::AudioDeviceModule::Create(audio_layer, &task_queue_factory);

  if (adm == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioDeviceModule>(adm);
}

// Calls `AudioDeviceModule->Init()`.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->Init();
}

// Calls `AudioDeviceModule->PlayoutDevices()`.
int16_t playout_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->PlayoutDevices();
}

// Calls `AudioDeviceModule->RecordingDevices()`.
int16_t recording_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->RecordingDevices();
}

// Calls `AudioDeviceModule->PlayoutDeviceName()` with the provided arguments.
int32_t playout_device_name(const AudioDeviceModule& audio_device_module,
                            int16_t index,
                            rust::String& name,
                            rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->PlayoutDeviceName(index, name_buff, guid_buff);
  name = name_buff;
  guid = guid_buff;

  return result;
}

// Calls `AudioDeviceModule->RecordingDeviceName()` with the provided arguments.
int32_t recording_device_name(const AudioDeviceModule& audio_device_module,
                              int16_t index,
                              rust::String& name,
                              rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->RecordingDeviceName(index, name_buff, guid_buff);

  name = name_buff;
  guid = guid_buff;

  return result;
}

// Calls `AudioDeviceModule->SetRecordingDevice()` with the provided arguments.
int32_t set_audio_recording_device(const AudioDeviceModule& audio_device_module,
                                   uint16_t index) {
  return audio_device_module->SetRecordingDevice(index);
}

// Calls `VideoCaptureFactory->CreateDeviceInfo()`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
}

// Calls `VideoDeviceInfo->GetDeviceName()` with the provided arguments.
int32_t video_device_name(VideoDeviceInfo& device_info,
                          uint32_t index,
                          rust::String& name,
                          rust::String& guid) {
  char name_buff[256];
  char guid_buff[256];

  const int32_t size =
      device_info.GetDeviceName(index, name_buff, 256, guid_buff, 256);

  name = name_buff;
  guid = guid_buff;

  return size;
}

// Calls `Thread->Create()`.
std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

// Creates a new `DeviceVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps,
    uint32_t device) {
  auto src = webrtc::CreateVideoTrackSourceProxy(
      &signaling_thread, &worker_thread,
      DeviceVideoCapturer::Create(width, height, fps, device));

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(src);
}

// Creates a new `ScreenVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_display_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  webrtc::DesktopCapturer::SourceList sourceList;
  ScreenVideoCapturer::GetSourceList(&sourceList);

  if (sourceList.size() < 1) {
    return nullptr;
  }

  rtc::scoped_refptr<ScreenVideoCapturer> capturer(
      new rtc::RefCountedObject<ScreenVideoCapturer>(sourceList[0].id, width,
                                                     height, fps));

  auto src = webrtc::CreateVideoTrackSourceProxy(&signaling_thread,
                                                 &worker_thread, capturer);

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(src);
}

// Calls `PeerConnectionFactoryInterface->CreateAudioSource()` with empty
// `AudioOptions`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  auto src =
      peer_connection_factory->CreateAudioSource(cricket::AudioOptions());

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioSourceInterface>(src);
}

// Calls `PeerConnectionFactoryInterface->CreateVideoTrack`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const VideoTrackSourceInterface& video_source) {
  auto track =
      peer_connection_factory->CreateVideoTrack(std::string(id), video_source);

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackInterface>(track);
}

// Calls `PeerConnectionFactoryInterface->CreateAudioTrack`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const AudioSourceInterface& audio_source) {
  auto track =
      peer_connection_factory->CreateAudioTrack(std::string(id), audio_source);

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioTrackInterface>(track);
}

// Calls `MediaStreamInterface->CreateLocalMediaStream`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id) {
  auto stream =
      peer_connection_factory->CreateLocalMediaStream(std::string(id));

  if (stream == nullptr) {
    return nullptr;
  }

  return std::make_unique<MediaStreamInterface>(stream);
}

// Calls `MediaStreamInterface->AddTrack`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track) {
  return media_stream->AddTrack(track);
}

// Calls `MediaStreamInterface->AddTrack`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track) {
  return media_stream->AddTrack(track);
}

// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track) {
  return media_stream->RemoveTrack(track);
}

// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track) {
  return media_stream->RemoveTrack(track);
}

// Calls `VideoTrackInterface->set_enabled()`.
void set_video_track_enabled(const VideoTrackInterface& track, bool enabled) {
  track->set_enabled(enabled);
}

// Calls `AudioTrackInterface->set_enabled()`.
void set_audio_track_enabled(const AudioTrackInterface& track, bool enabled) {
  track->set_enabled(enabled);
}

// Registers the provided video `sink` for the given `track`.
//
// Used to connect the given `track` to the underlying video engine.
void add_or_update_video_sink(const VideoTrackInterface& track,
                              VideoSinkInterface& sink) {
  track->AddOrUpdateSink(&sink, rtc::VideoSinkWants());
}

// Detaches the provided video `sink` from the given `track`.
void remove_video_sink(const VideoTrackInterface& track,
                       VideoSinkInterface& sink) {
  track->RemoveSink(&sink);
}

// Creates a new `ForwardingVideoSink`.
std::unique_ptr<VideoSinkInterface> create_forwarding_video_sink(
    rust::Box<DynOnFrameCallback> cb) {
  return std::make_unique<video_sink::ForwardingVideoSink>(std::move(cb));
}

// Converts the provided `webrtc::VideoFrame` pixels to the ABGR scheme and
// writes the result to the provided `dst_abgr`.
void video_frame_to_abgr(const webrtc::VideoFrame& frame, uint8_t* dst_abgr) {
  rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
      frame.video_frame_buffer()->ToI420());

  libyuv::I420ToABGR(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
                     buffer->StrideU(), buffer->DataV(), buffer->StrideV(),
                     dst_abgr, buffer->width() * 4, buffer->width(),
                     buffer->height());
}

// Creates a new `PeerConnectionFactoryInterface`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<Thread>& network_thread,
    const std::unique_ptr<Thread>& worker_thread,
    const std::unique_ptr<Thread>& signaling_thread,
    const std::unique_ptr<AudioDeviceModule>& default_adm) {

  auto factory = webrtc::CreatePeerConnectionFactory(
      network_thread.get(),
      worker_thread.get(),
      signaling_thread.get(),
      default_adm ? *default_adm : nullptr,
      webrtc::CreateBuiltinAudioEncoderFactory(),
      webrtc::CreateBuiltinAudioDecoderFactory(),
      webrtc::CreateBuiltinVideoEncoderFactory(),
      webrtc::CreateBuiltinVideoDecoderFactory(),
      nullptr,
      nullptr);

  if (factory == nullptr) {
    return nullptr;
  }
  return std::make_unique<PeerConnectionFactoryInterface>(factory);
}

// Calls `PeerConnectionFactoryInterface->CreatePeerConnectionOrError`.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
    PeerConnectionFactoryInterface& peer_connection_factory,
    const RTCConfiguration& configuration,
    std::unique_ptr<PeerConnectionDependencies> dependencies,
    rust::String& error) {
  auto pc = peer_connection_factory->CreatePeerConnectionOrError(
      configuration, std::move(*dependencies));

  if (pc.ok()) {
    return std::make_unique<PeerConnectionInterface>(pc.MoveValue());
  }

  error = rust::String(pc.MoveError().message());
  return nullptr;
}

// Creates a new default `RTCConfiguration`.
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration() {
  RTCConfiguration config;
  config.sdp_semantics = webrtc::SdpSemantics::kUnifiedPlan;
  return std::make_unique<RTCConfiguration>(config);
}

// Creates a new `PeerConnectionObserver`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer(
    rust::Box<bridge::DynPeerConnectionEventsHandler> cb) {
  return std::make_unique<PeerConnectionObserver>(
      PeerConnectionObserver(std::move(cb)));
}

// Creates a new `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    const std::unique_ptr<PeerConnectionObserver>& observer) {
  PeerConnectionDependencies pcd(observer.get());
  return std::make_unique<PeerConnectionDependencies>(std::move(pcd));
}

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions>
create_default_rtc_offer_answer_options() {
  return std::make_unique<RTCOfferAnswerOptions>();
}

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(
    int32_t offer_to_receive_video,
    int32_t offer_to_receive_audio,
    bool voice_activity_detection,
    bool ice_restart,
    bool use_rtp_mux) {
  return std::make_unique<RTCOfferAnswerOptions>(offer_to_receive_video,
                                                 offer_to_receive_audio,
                                                 voice_activity_detection,
                                                 ice_restart, use_rtp_mux);
}

// Creates a new `CreateSessionDescriptionObserver` from the provided
// `bridge::DynCreateSdpCallback`.
std::unique_ptr<CreateSessionDescriptionObserver>
create_create_session_observer(rust::Box<bridge::DynCreateSdpCallback> cb) {
  return std::make_unique<CreateSessionDescriptionObserver>(std::move(cb));
}

// Creates a new `SetLocalDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetLocalDescriptionObserver>
create_set_local_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  return std::make_unique<SetLocalDescriptionObserver>(std::move(cb));
}

// Creates a new `SetRemoteDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetRemoteDescriptionObserver>
create_set_remote_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  return std::make_unique<SetRemoteDescriptionObserver>(std::move(cb));
}

// Calls `PeerConnectionInterface->CreateOffer`.
void create_offer(PeerConnectionInterface& peer_connection_interface,
                  const RTCOfferAnswerOptions& options,
                  std::unique_ptr<CreateSessionDescriptionObserver> obs) {
  peer_connection_interface->CreateOffer(obs.release(), options);
}

// Calls `PeerConnectionInterface->CreateAnswer`.
void create_answer(PeerConnectionInterface& peer_connection_interface,
                   const RTCOfferAnswerOptions& options,
                   std::unique_ptr<CreateSessionDescriptionObserver> obs) {
  peer_connection_interface->CreateAnswer(obs.release(), options);
}

// Calls `PeerConnectionInterface->SetLocalDescription`.
void set_local_description(PeerConnectionInterface& peer_connection_interface,
                           std::unique_ptr<SessionDescriptionInterface> desc,
                           std::unique_ptr<SetLocalDescriptionObserver> obs) {
  auto observer =
      rtc::scoped_refptr<webrtc::SetLocalDescriptionObserverInterface>(
          obs.release());
  peer_connection_interface->SetLocalDescription(std::move(desc), observer);
}

// Calls `PeerConnectionInterface->SetRemoteDescription`.
void set_remote_description(PeerConnectionInterface& peer_connection_interface,
                            std::unique_ptr<SessionDescriptionInterface> desc,
                            std::unique_ptr<SetRemoteDescriptionObserver> obs) {
  auto observer =
      rtc::scoped_refptr<SetRemoteDescriptionObserver>(obs.release());
  peer_connection_interface->SetRemoteDescription(std::move(desc), observer);
}

// Returns a `local` of the given `CandidatePair`.
const Candidate& get_candidate_pair_local_candidate(const CandidatePair& pair) {
  return pair.local_candidate();
};

// Returns a `remote` of the given `CandidatePair`.
const Candidate& get_candidate_pair_remote_candidate(const CandidatePair& pair) {
  return pair.remote_candidate();
};

// Returns a `duration` of the given `DtmfSenderInterface`.
int32_t get_dtmf_sender_duration(
    const DtmfSenderInterface& dtmf) {
      return dtmf->duration();
    }

// Returns a `inter_tone_gap` of the given `DtmfSenderInterface`.
int32_t get_dtmf_sender_inter_tone_gap(
    const DtmfSenderInterface& dtmf) {
      return dtmf->inter_tone_gap();
    }

// Returns `RtpExtension.uri` field value.
std::unique_ptr<std::string> get_rtp_extension_uri(
    const RtpExtension& extension) {
      return std::make_unique<std::string>(extension.uri);
    }

// Returns `RtpExtension.id` field value.
int32_t get_rtp_extension_id(
    const RtpExtension& extension) {
      return extension.id;
    }

// Returns `RtpExtension.encrypt` field value.
bool get_rtp_extension_encrypt(
    const RtpExtension& extension) {
      return extension.encrypt;
    }

// Returns `RtcpParameters.cname` field value.
std::unique_ptr<std::string> get_rtcp_parameters_cname(
    const RtcpParameters& rtcp) {
      return std::make_unique<std::string> (rtcp.cname);
    }

// Returns `RtcpParameters.reduced_size` field value.
bool get_rtcp_parameters_reduced_size(
    const RtcpParameters& rtcp) {
      return rtcp.reduced_size;
    }

// Returns a `id` of the given `MediaStreamInterface`.
std::unique_ptr<std::string> get_media_stream_id(
  const MediaStreamInterface& stream) {
  return std::make_unique<std::string>(stream->id());
}

// Returns a `AudioTrackVector` of the given `MediaStreamInterface`.
std::unique_ptr<std::vector<AudioTrackInterface>> get_media_stream_audio_tracks(
    const MediaStreamInterface& stream) {
      auto tracks = stream->GetAudioTracks();
      std::vector<AudioTrackInterface> result;
      for (int i = 0; i < tracks.size(); ++i) {
        result.push_back(tracks[i]);
      }
      return std::make_unique<std::vector<AudioTrackInterface>>(result);
    }

// Returns a `VideoTrackVector` of the given `MediaStreamInterface`.
std::unique_ptr<std::vector<VideoTrackInterface>> get_media_stream_video_tracks(
    const MediaStreamInterface& stream) {
      auto tracks = stream->GetVideoTracks();
      std::vector<VideoTrackInterface> result;
      for (int i = 0; i < tracks.size(); ++i) {
        result.push_back(tracks[i]);
      }
      return std::make_unique<std::vector<VideoTrackInterface>>(result);
    }

// Upcast `VideoTrackInterface` to `MediaStreamTrackInterface`.
const MediaStreamTrackInterface& video_track_media_stream_track_upcast(
    const VideoTrackInterface& track) {
      return MediaStreamTrackInterface(track);
    }

// Returns a `VideoTrackInterface` of the given `VideoTrackSourceInterface`.
std::unique_ptr<VideoTrackSourceInterface> get_video_track_sourse(
    const VideoTrackInterface& track) {
      return std::make_unique<VideoTrackSourceInterface>(track->GetSource());
    }

// Upcast `AudioTrackInterface` to `MediaStreamTrackInterface`.
const MediaStreamTrackInterface& audio_track_media_stream_track_upcast(
    const AudioTrackInterface& track) {
      return MediaStreamTrackInterface(track);
    }

// Returns a `AudioSourceInterface` of the given `AudioTrackInterface`.
std::unique_ptr<AudioSourceInterface> get_audio_track_sourse(
     const AudioTrackInterface& track) {
       return std::make_unique<AudioSourceInterface>(track->GetSource());
     }

// Calls `IceCandidateInterface->ToString`.
std::unique_ptr<std::string> ice_candidate_interface_to_string(
    const IceCandidateInterface* candidate) {
  std::string out;
  candidate->ToString(&out);
  return std::make_unique<std::string>(out);
};

// Calls `Candidate->ToString`.
std::unique_ptr<std::string> candidate_to_string(
    const cricket::Candidate& candidate) {
  return std::make_unique<std::string>(candidate.ToString());
};

// Returns `CandidatePairChangeEvent.candidate_pair` field value.
const cricket::CandidatePair& get_candidate_pair(
    const cricket::CandidatePairChangeEvent& event) {
  return event.selected_candidate_pair;
};

// Returns `CandidatePairChangeEvent.last_data_received_ms` field value.
int64_t get_last_data_received_ms(
    const cricket::CandidatePairChangeEvent& event) {
  return event.last_data_received_ms;
}

// Returns `CandidatePairChangeEvent.reason` field value.
std::unique_ptr<std::string> get_reason(
    const cricket::CandidatePairChangeEvent& event) {
  return std::make_unique<std::string>(event.reason);
}

// Returns `CandidatePairChangeEvent.estimated_disconnected_time_ms` field
// value.
int64_t get_estimated_disconnected_time_ms(
    const cricket::CandidatePairChangeEvent& event) {
  return event.estimated_disconnected_time_ms;
}

// Calls `PeerConnectionInterface->AddTransceiver`.
std::unique_ptr<RtpTransceiverInterface> add_transceiver(
    PeerConnectionInterface& peer,
    cricket::MediaType media_type,
    RtpTransceiverDirection direction) {
  auto transceiver_init = webrtc::RtpTransceiverInit();
  transceiver_init.direction = direction;

  return std::make_unique<RtpTransceiverInterface>(
      peer->AddTransceiver(media_type, transceiver_init).MoveValue());
}

// Calls `PeerConnectionInterface->GetTransceivers`.
rust::Vec<TransceiverContainer> get_transceivers(
    const PeerConnectionInterface& peer) {
  rust::Vec<TransceiverContainer> transceivers;

  for (auto transceiver : peer->GetTransceivers()) {
    TransceiverContainer container = {
        std::make_unique<RtpTransceiverInterface>(transceiver)
    };
    transceivers.push_back(std::move(container));
  }

  return transceivers;
}

// Calls `PeerConnectionInterface->mid()`.
rust::String get_transceiver_mid(const RtpTransceiverInterface& transceiver) {
  return rust::String(transceiver->mid().value_or(""));
}

// Calls `PeerConnectionInterface->direction()`.
RtpTransceiverDirection get_transceiver_direction(
    const RtpTransceiverInterface& transceiver) {
  return transceiver->direction();
}

// Returns a `receiver` of the given `RtpTransceiverInterface`.
std::unique_ptr<RtpReceiverInterface> get_transceiver_receiver(
    const RtpTransceiverInterface& transceiver) {
      return std::make_unique<RtpReceiverInterface>(transceiver->receiver());
    }
    
// Returns a `sender` of the given `RtpTransceiverInterface`.
std::unique_ptr<RtpSenderInterface> get_transceiver_sender(
    const RtpTransceiverInterface& transceiver) {
      return std::make_unique<RtpSenderInterface> (transceiver->sender());
    }

// Calls `RtpTransceiverInterface->SetDirectionWithError()`.
rust::String set_transceiver_direction(
    const RtpTransceiverInterface& transceiver,
    webrtc::RtpTransceiverDirection new_direction) {
  webrtc::RTCError result = transceiver->SetDirectionWithError(new_direction);
  rust::String error;

  if (!result.ok()) {
    error = result.message();
  }
  return error;
}

// Calls `RtpTransceiverInterface->StopStandard()`.
rust::String stop_transceiver(const RtpTransceiverInterface& transceiver) {
  webrtc::RTCError result = transceiver->StopStandard();
  rust::String error;

  if (!result.ok()) {
    error = result.message();
  }
  return error;
}

// Returns a `parameters` as std::vector<(std::string, std::string)> 
// of the given `RtpCodecParameters`.
std::unique_ptr<std::vector<StringPair>> get_rtp_codec_parameters_parameters(
    const RtpCodecParameters& codec) {
      std::vector<StringPair> result;
      for (auto const& p : codec.parameters) {
        result.push_back(new_string_pair(p.first, p.second));
      }
      return std::make_unique<std::vector<StringPair>>(result);
    }


// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_video_track_event_observer(
    const VideoTrackInterface& track,
    rust::Box<bridge::DynTrackEventCallback> cb
) {
    return std::make_unique<TrackEventObserver>(
      TrackEventObserver(track.get(), std::move(cb))
    );
}

// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_audio_track_event_observer(
    const AudioTrackInterface& track,
    rust::Box<bridge::DynTrackEventCallback> cb
) {
    return std::make_unique<TrackEventObserver>(
      TrackEventObserver(track, std::move(cb))
    );
}

// Calls `VideoTrackInterface->RegisterObserver`.
void video_track_register_observer(
    VideoTrackInterface& track, 
    TrackEventObserver& obs) {
      track->RegisterObserver(&obs);
    }

// Calls `AudioTrackInterface->RegisterObserver`.
void audio_track_register_observer(
    AudioTrackInterface& track, 
    TrackEventObserver& obs) {
      track->RegisterObserver(&obs);
    }

// Calls `VideoTrackInterface->UnregisterObserver`.
void video_track_unregister_observer(
    VideoTrackInterface& track, 
    TrackEventObserver& obs) {
      track->UnregisterObserver(&obs);
    }

// Calls `AudioTrackInterface->UnregisterObserver`.
void audio_track_unregister_observer(
    AudioTrackInterface& track, 
    TrackEventObserver& obs) {
      track->UnregisterObserver(&obs);
    }
}  // namespace bridge
