#pragma once

#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/task_queue/default_task_queue_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"
#include "api/video_track_source_proxy_factory.h"
#include "device_video_capturer.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "pc/audio_track.h"
#include "pc/local_audio_source.h"
#include "pc/video_track_source.h"
#include "peer_connection_observer.h"
#include "rust/cxx.h"
#include "screen_video_capturer.h"
#include "video_sink.h"
#include <functional>

namespace bridge {

struct DynTrackEventCallback;

// `TrackEventObserver` propagating track events to the Rust side.
class TrackEventObserver : public webrtc::ObserverInterface {
 public:
  // Creates a new `TrackEventObserver`.
  TrackEventObserver(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> track,
                     rust::Box<bridge::DynTrackEventCallback> cb);
  
  // Called when track calls `set_state` or `set_enabled`.
  void OnChanged();

 private:

  // `SourceEventObserver` propagating mute/unmute track events to the Rust side.
  class SourceEventObserver : public webrtc::ObserverInterface {
      public:
      SourceEventObserver(std::function<void()> callback): callback_(callback) {}
      void OnChanged() {callback_();}
      private:
      std::function<void()> callback_;
  };

  // `MediaStreamTrackInterface` for mute/unmute event.
  std::unique_ptr<SourceEventObserver> source_obs;

  // `MediaStreamTrackInterface` for determine the event.
  rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> track_;

  // Rust side callback.
  rust::Box<bridge::DynTrackEventCallback> cb_;
};

struct TransceiverContainer;
struct StringPair;
struct RtpCodecParametersContainer;
struct RtpExtensionContainer;
struct RtpEncodingParametersContainer;


using Thread = rtc::Thread;
using VideoSinkInterface = rtc::VideoSinkInterface<webrtc::VideoFrame>;

using MediaType = cricket::MediaType;

using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;
using IceCandidateInterface = webrtc::IceCandidateInterface;
using IceConnectionState = webrtc::PeerConnectionInterface::IceConnectionState;
using IceGatheringState = webrtc::PeerConnectionInterface::IceGatheringState;
using PeerConnectionDependencies = webrtc::PeerConnectionDependencies;
using PeerConnectionState =
    webrtc::PeerConnectionInterface::PeerConnectionState;
using RTCConfiguration = webrtc::PeerConnectionInterface::RTCConfiguration;
using RTCOfferAnswerOptions =
    webrtc::PeerConnectionInterface::RTCOfferAnswerOptions;
using SdpType = webrtc::SdpType;
using SessionDescriptionInterface = webrtc::SessionDescriptionInterface;
using SignalingState = webrtc::PeerConnectionInterface::SignalingState;
using TaskQueueFactory = webrtc::TaskQueueFactory;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using VideoRotation = webrtc::VideoRotation;
using RtpTransceiverDirection = webrtc::RtpTransceiverDirection;
using TrackState = webrtc::MediaStreamTrackInterface::TrackState;

using AudioDeviceModule = rtc::scoped_refptr<webrtc::AudioDeviceModule>;
using AudioSourceInterface = rtc::scoped_refptr<webrtc::AudioSourceInterface>;
using AudioTrackInterface = rtc::scoped_refptr<webrtc::AudioTrackInterface>;
using MediaStreamInterface = rtc::scoped_refptr<webrtc::MediaStreamInterface>;
using PeerConnectionFactoryInterface =
    rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface>;
using PeerConnectionInterface =
    rtc::scoped_refptr<webrtc::PeerConnectionInterface>;
using RtpTransceiverInterface =
    rtc::scoped_refptr<webrtc::RtpTransceiverInterface>;
using RtpSenderInterface = rtc::scoped_refptr<webrtc::RtpSenderInterface>;
using VideoTrackInterface = rtc::scoped_refptr<webrtc::VideoTrackInterface>;
using VideoTrackSourceInterface =
    rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>;
using RtpReceiverInterface = rtc::scoped_refptr<webrtc::RtpReceiverInterface>;
using MediaStreamTrackInterface =
    rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>;

using CreateSessionDescriptionObserver =
    observer::CreateSessionDescriptionObserver;
using PeerConnectionObserver = observer::PeerConnectionObserver;
using SetLocalDescriptionObserver = observer::SetLocalDescriptionObserver;
using SetRemoteDescriptionObserver = observer::SetRemoteDescriptionObserver;

// Creates a new `AudioDeviceModule` for the given `AudioLayer`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory& task_queue_factory);

// Initializes the native audio parts required for each platform.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module);

// Returns count of the available playout audio devices.
int16_t playout_devices(const AudioDeviceModule& audio_device_module);

// Returns count of the available recording audio devices.
int16_t recording_devices(const AudioDeviceModule& audio_device_module);

// Obtains information regarding the specified audio playout device.
int32_t playout_device_name(const AudioDeviceModule& audio_device_module,
                            int16_t index,
                            rust::String& name,
                            rust::String& guid);

// Obtains information regarding the specified audio recording device.
int32_t recording_device_name(const AudioDeviceModule& audio_device_module,
                              int16_t index,
                              rust::String& name,
                              rust::String& guid);

// Specifies which microphone to use for recording audio using an index
// retrieved by the corresponding enumeration method which is
// `AudiDeviceModule::RecordingDeviceName`.
int32_t set_audio_recording_device(const AudioDeviceModule& audio_device_module,
                                   uint16_t index);

// Creates a new `VideoDeviceInfo`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info();

// Obtains information regarding the specified video recording device.
int32_t video_device_name(VideoDeviceInfo& device_info,
                          uint32_t index,
                          rust::String& name,
                          rust::String& guid);

// Creates a new `Thread`.
std::unique_ptr<rtc::Thread> create_thread();

// Creates a new `VideoTrackSourceInterface` from the specified video input
// device according to the specified constraints.
std::unique_ptr<VideoTrackSourceInterface> create_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps,
    uint32_t device_index);

// Starts screen capturing and creates a new `VideoTrackSourceInterface`
// according to the specified constraints.
std::unique_ptr<VideoTrackSourceInterface> create_display_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps);

// Creates a new `AudioSourceInterface`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory);

// Creates a new `VideoTrackInterface`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const VideoTrackSourceInterface& video_source);

// Creates a new `AudioTrackInterface`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const AudioSourceInterface& audio_source);

// Creates a new `MediaStreamInterface`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id);

// Adds the provided `VideoTrackInterface` to the specified
// `MediaStreamInterface`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track);

// Adds the provided `AudioTrackInterface` to the specified
// `MediaStreamInterface`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track);

// Removes the provided `VideoTrackInterface` to the specified
// `MediaStreamInterface`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track);

// Removes the provided `AudioTrackInterface` to the specified
// `MediaStreamInterface`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track);

// Changes the `enabled` property of the provided `VideoTrackInterface`.
void set_video_track_enabled(const VideoTrackInterface& track, bool enabled);

// Changes the `enabled` property of the provided `AudioTrackInterface`.
void set_audio_track_enabled(const AudioTrackInterface& track, bool enabled);

// Registers the provided video `sink` for the given `track`.
//
// Used to connect the given `track` to the underlying video engine.
void add_or_update_video_sink(const VideoTrackInterface& track,
                              VideoSinkInterface& sink);

// Detaches the provided video `sink` from the given `track`.
void remove_video_sink(const VideoTrackInterface& track,
                       VideoSinkInterface& sink);

// Creates a new `ForwardingVideoSink`.
std::unique_ptr<VideoSinkInterface> create_forwarding_video_sink(
    rust::Box<DynOnFrameCallback> handler);

// Converts the provided `webrtc::VideoFrame` pixels to the ABGR scheme and
// writes the result to the provided `dst_abgr`.
void video_frame_to_abgr(const webrtc::VideoFrame& frame, uint8_t* dst_abgr);

// Creates a new `PeerConnectionFactoryInterface`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<Thread>& network_thread,
    const std::unique_ptr<Thread>& worker_thread,
    const std::unique_ptr<Thread>& signaling_thread,
    const std::unique_ptr<AudioDeviceModule>& default_adm);

// Creates a new `PeerConnectionInterface`.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
    PeerConnectionFactoryInterface& peer_connection_factory,
    const RTCConfiguration& configuration,
    std::unique_ptr<PeerConnectionDependencies> dependencies,
    rust::String& error);

// Creates a new default `RTCConfiguration`.
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration();

// Creates a new `PeerConnectionObserver` backed by the provided
// `DynPeerConnectionEventsHandler`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer(
    rust::Box<bridge::DynPeerConnectionEventsHandler> cb);

// Creates a new `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    const std::unique_ptr<PeerConnectionObserver>& observer);

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions>
create_default_rtc_offer_answer_options();

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(
    int32_t offer_to_receive_video,
    int32_t offer_to_receive_audio,
    bool voice_activity_detection,
    bool ice_restart,
    bool use_rtp_mux);

// Creates a new `CreateSessionDescriptionObserver` from the provided
// `bridge::DynCreateSdpCallback`.
std::unique_ptr<CreateSessionDescriptionObserver>
create_create_session_observer(rust::Box<bridge::DynCreateSdpCallback> cb);

// Creates a new `SetLocalDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetLocalDescriptionObserver>
create_set_local_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb);

// Creates a new `SetRemoteDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetRemoteDescriptionObserver>
create_set_remote_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb);

// Calls `PeerConnectionInterface->CreateOffer`.
void create_offer(PeerConnectionInterface& peer,
                  const RTCOfferAnswerOptions& options,
                  std::unique_ptr<CreateSessionDescriptionObserver> obs);

// Calls `PeerConnectionInterface->CreateAnswer`.
void create_answer(PeerConnectionInterface& peer,
                   const RTCOfferAnswerOptions& options,
                   std::unique_ptr<CreateSessionDescriptionObserver> obs);

// Calls `PeerConnectionInterface->SetLocalDescription`.
void set_local_description(PeerConnectionInterface& peer,
                           std::unique_ptr<SessionDescriptionInterface> desc,
                           std::unique_ptr<SetLocalDescriptionObserver> obs);

// Calls `PeerConnectionInterface->SetRemoteDescription`.
void set_remote_description(PeerConnectionInterface& peer,
                            std::unique_ptr<SessionDescriptionInterface> desc,
                            std::unique_ptr<SetRemoteDescriptionObserver> obs);

// Returns `RtpExtension.uri` field value.
std::unique_ptr<std::string> rtp_extension_uri(
    const webrtc::RtpExtension& extension);

// Returns `RtpExtension.id` field value.
int32_t rtp_extension_id(const webrtc::RtpExtension& extension);

// Returns `RtpExtension.encrypt` field value.
bool rtp_extension_encrypt(const webrtc::RtpExtension& extension);

// Returns `RtcpParameters.cname` field value.
std::unique_ptr<std::string> rtcp_parameters_cname(
    const webrtc::RtcpParameters& rtcp);

// Returns `RtcpParameters.reduced_size` field value.
bool rtcp_parameters_reduced_size(const webrtc::RtcpParameters& rtcp);

// Returns a `VideoTrackInterface` of the given `VideoTrackSourceInterface`.
std::unique_ptr<VideoTrackSourceInterface> get_video_track_source(
    const VideoTrackInterface& track);

// Returns a `AudioSourceInterface` of the given `AudioTrackInterface`.
std::unique_ptr<AudioSourceInterface> get_audio_track_source(
    const AudioTrackInterface& track);

// Calls `IceCandidateInterface->ToString`.
std::unique_ptr<std::string> ice_candidate_interface_to_string(
    const IceCandidateInterface* candidate);

// Creates an SDP-ized form of this `Candidate`.
std::unique_ptr<std::string> candidate_to_string(
    const cricket::Candidate& candidate);

// Returns `CandidatePairChangeEvent.candidate_pair` field value.
const cricket::CandidatePair& candidate_pair(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.last_data_received_ms` field value.
int64_t last_data_received_ms(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.reason` field value.
std::unique_ptr<std::string> reason(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.estimated_disconnected_time_ms` field
// value.
int64_t estimated_disconnected_time_ms(
    const cricket::CandidatePairChangeEvent& event);

// Adds a new `RtpTransceiverInterface` to the given `PeerConnectionInterface`.
std::unique_ptr<RtpTransceiverInterface> add_transceiver(
    PeerConnectionInterface& peer,
    cricket::MediaType media_type,
    RtpTransceiverDirection direction);

// Returns a list of `RtpTransceiverInterface`s attached to the given
// `PeerConnectionInterface`.
rust::Vec<TransceiverContainer> get_transceivers(
    const PeerConnectionInterface& peer);

// Returns a `mid` of the given `RtpTransceiverInterface`.
rust::String transceiver_mid(const RtpTransceiverInterface& transceiver);

// Returns a `MediaType` of the given `RtpTransceiverInterface`.
MediaType transceiver_media_type(
    const RtpTransceiverInterface& transceiver);

// Returns a `direction` of the given `RtpTransceiverInterface`.
RtpTransceiverDirection transceiver_direction(
    const RtpTransceiverInterface& transceiver);

// Changes the preferred `RtpTransceiverInterface` direction to the given
// `RtpTransceiverDirection`.
rust::String set_transceiver_direction(
    const RtpTransceiverInterface& transceiver,
    RtpTransceiverDirection new_direction);

// Irreversibly marks the `transceiver` as stopping, unless it's already
// stopped.
//
// This will immediately cause the `transceiver`'s sender to no longer send, and
// its receiver to no longer receive.
rust::String stop_transceiver(const RtpTransceiverInterface& transceiver);

// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_video_track_event_observer(
    const VideoTrackInterface& track,
    rust::Box<bridge::DynTrackEventCallback> cb
);

// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_audio_track_event_observer(
    const AudioTrackInterface& track,
    rust::Box<bridge::DynTrackEventCallback> cb
);

// Calls `VideoTrackInterface->RegisterObserver`.
void video_track_register_observer(
    VideoTrackInterface& track, 
    TrackEventObserver& obs);

// Calls `AudioTrackInterface->RegisterObserver`.
void audio_track_register_observer(
    AudioTrackInterface& track, 
    TrackEventObserver& obs);

// Calls `VideoTrackInterface->UnregisterObserver`.
void video_track_unregister_observer(
    VideoTrackInterface& track, 
    TrackEventObserver& obs);

// Calls `AudioTrackInterface->UnregisterObserver`.
void audio_track_unregister_observer(
    AudioTrackInterface& track, 
    TrackEventObserver& obs);
// Returns a `RtpSenderInterface` of the given `RtpTransceiverInterface`.
std::unique_ptr<RtpSenderInterface> transceiver_sender(
    const RtpTransceiverInterface& transceiver);

// Returns a `receiver` of the given `RtpTransceiverInterface`.
std::unique_ptr<RtpReceiverInterface> transceiver_receiver(
    const RtpTransceiverInterface& transceiver);

// Returns a `parameters` as std::vector<(std::string, std::string)>
// of the given `RtpCodecParameters`.
std::unique_ptr<std::vector<StringPair>> rtp_codec_parameters_parameters(
    const webrtc::RtpCodecParameters& codec);

// Returns `RtpParameters.codecs` field value.
rust::Vec<RtpCodecParametersContainer> rtp_parameters_codecs(
    const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.header_extensions` field value.
rust::Vec<RtpExtensionContainer>
rtp_parameters_header_extensions(const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.encodings` field value.
rust::Vec<RtpEncodingParametersContainer>
rtp_parameters_encodings(const webrtc::RtpParameters& parameters);

// Returns true if the two point to the same allocation.
bool transceiver_eq(
    const RtpTransceiverInterface& a,
    const RtpTransceiverInterface& b);

}  // namespace bridge
