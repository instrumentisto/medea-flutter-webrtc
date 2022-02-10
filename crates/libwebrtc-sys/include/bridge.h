#pragma once

#include <memory>
#include <string>

#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"

#include "api/task_queue/default_task_queue_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_track_source_proxy_factory.h"
#include "device_video_capturer.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "pc/audio_track.h"
#include "pc/local_audio_source.h"
#include "pc/video_track_source.h"
#include "peer_connection_observer.h"
#include "video_sink.h"
#include "rust/cxx.h"

namespace bridge {

// Smart pointer designed to wrap WebRTC's `rtc::scoped_refptr`.
//
// `rtc::scoped_refptr` can't be used with `std::uniqueptr` since it has private
// destructor. `rc` unwraps raw pointer from the provided `rtc::scoped_refptr`
// and calls `Release()` in its destructor therefore this allows wrapping `rc`
// into a `std::uniqueptr`.
template<class T>
class rc {
 public:
  typedef T element_type;

  // Unwraps the actual pointer from the provided `rtc::scoped_refptr`.
  rc(rtc::scoped_refptr<T> p) : ptr_(p.release()) {}

  // Calls `RefCountInterface::Release()` on the underlying pointer.
  ~rc() { ptr_->Release(); }

  // Returns a pointer to the managed object.
  T* ptr() const { return ptr_; }

  // Returns a pointer to the managed object.
  T* operator->() const { return ptr_; }

 protected:
  // Pointer to the managed object.
  T* ptr_;
};

using Thread = rtc::Thread;
using VideoSinkInterface = rtc::VideoSinkInterface<webrtc::VideoFrame>;

using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;
using PeerConnectionDependencies = webrtc::PeerConnectionDependencies;
using RTCConfiguration = webrtc::PeerConnectionInterface::RTCConfiguration;
using RTCOfferAnswerOptions =
    webrtc::PeerConnectionInterface::RTCOfferAnswerOptions;
using SdpType = webrtc::SdpType;
using SessionDescriptionInterface = webrtc::SessionDescriptionInterface;
using TaskQueueFactory = webrtc::TaskQueueFactory;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using VideoRotation = webrtc::VideoRotation;

using AudioDeviceModule = rc<webrtc::AudioDeviceModule>;
using AudioSourceInterface = rc<webrtc::AudioSourceInterface>;
using AudioTrackInterface = rc<webrtc::AudioTrackInterface>;
using MediaStreamInterface = rc<webrtc::MediaStreamInterface>;
using PeerConnectionFactoryInterface =
    rc<webrtc::PeerConnectionFactoryInterface>;
using PeerConnectionInterface = rc<webrtc::PeerConnectionInterface>;
using VideoTrackInterface = rc<webrtc::VideoTrackInterface>;

using VideoTrackSourceInterface = rc<webrtc::VideoTrackSourceInterface>;

using CreateSessionDescriptionObserver =
    observer::CreateSessionDescriptionObserver;
using PeerConnectionObserver = observer::PeerConnectionObserver;
using SetLocalDescriptionObserver = observer::SetLocalDescriptionObserver;
using SetRemoteDescriptionObserver = observer::SetRemoteDescriptionObserver;

using SignalingState = webrtc::PeerConnectionInterface::SignalingState;
using IceConnectionState = webrtc::PeerConnectionInterface::IceConnectionState;
using IceGatheringState = webrtc::PeerConnectionInterface::IceGatheringState;
using PeerConnectionState = webrtc::PeerConnectionInterface::PeerConnectionState;
using TrackState = webrtc::MediaStreamTrackInterface::TrackState;

using IceCandidateInterface = webrtc::IceCandidateInterface;
using Candidate = cricket::Candidate;
using CandidatePairChangeEvent = cricket::CandidatePairChangeEvent;
using CandidatePair = cricket::CandidatePair;

using RtpReceiverInterface = rc<webrtc::RtpReceiverInterface>;
using RtpTransceiverInterface = rc<webrtc::RtpTransceiverInterface>;
using RtpSenderInterface = rc<webrtc::RtpSenderInterface>;
using MediaStreamTrackInterface = rc<webrtc::MediaStreamTrackInterface>;
using RtcpParameters = webrtc::RtcpParameters; // todo
using RtpParameters = webrtc::RtpParameters;
using RtpCodecParameters = webrtc::RtpCodecParameters;
using RtpExtension = webrtc::RtpExtension;
using RtpEncodingParameters = webrtc::RtpEncodingParameters;
using DtmfSenderInterface = rc<webrtc::DtmfSenderInterface>;

using MediaType = cricket::MediaType;
using RtpTransceiverDirection = webrtc::RtpTransceiverDirection;

struct StringPair;


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

// Creates a new `VideoTrackSourceInterface` according to the specified
// constraints.
std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps,
    uint32_t device_index);

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

// Registers the provided video `sink` for the given `track`.
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

// Creates a new `PeerConnectionObserver`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer(
    rust::Box<bridge::DynPeerConnectionOnEvent> cb);

// Creates a new `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    const std::unique_ptr<PeerConnectionObserver>& observer);
    
// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_default_rtc_offer_answer_options();

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

// Calls `IceCandidateInterface->ToString` and wraps result in `std::unqiue_ptr`.
std::unique_ptr<std::string> ice_candidate_interface_to_string(const IceCandidateInterface* candidate);

// Calls `Candidate->ToString` and wraps result in `std::unqiue_ptr`.
std::unique_ptr<std::string> candidate_to_string(const Candidate& candidate);

// Gets `CandidatePairChangeEvent.candidate_pair`.
const CandidatePair& get_candidate_pair(const CandidatePairChangeEvent& event);

// Gets `CandidatePairChangeEvent.last_data_received_ms`.
int64_t get_last_data_received_ms(const CandidatePairChangeEvent& event);

// Gets `CandidatePairChangeEvent.reason` and wraps result in `std::unqiue_ptr`.
std::unique_ptr<std::string> get_reason(const CandidatePairChangeEvent& event);

// Gets `CandidatePairChangeEvent.estimated_disconnected_time_ms`.
int64_t get_estimated_disconnected_time_ms(const CandidatePairChangeEvent& event);

// Calls `CandidatePair->local_candidate`.
const Candidate& get_local_candidate(const CandidatePair& pair);

// Calls `CandidatePair->remote_candidate`.
const Candidate& get_remote_candidate(const CandidatePair& pair);




// RtpTransceiverInterface

// todo
std::unique_ptr<RtpReceiverInterface> rtp_transceiver_interface_get_receiver(
    const RtpTransceiverInterface& transceiver);

std::unique_ptr<std::string> rtp_transceiver_interface_get_mid(
    const RtpTransceiverInterface& transceiver);

RtpTransceiverDirection rtp_transceiver_interface_get_direction(
    const RtpTransceiverInterface& transceiver);

std::unique_ptr<RtpSenderInterface> rtp_transceiver_interface_get_sender(
    const RtpTransceiverInterface& transceiver);

// End RtpTransceiverInterface




// RtpSenderInterface

std::unique_ptr<std::string> rtp_sender_interface_get_id(
    const RtpSenderInterface& sender);

std::unique_ptr<DtmfSenderInterface> rtp_sender_interface_get_dtmf(
    const RtpSenderInterface& sender);

std::unique_ptr<RtpParameters> rtp_sender_interface_get_parameters(
    const RtpSenderInterface& sender);

std::unique_ptr<MediaStreamTrackInterface> rtp_sender_interface_get_track(
    const RtpSenderInterface& sender);

// End RtpSenderInterface


// DtmfSenderInterface

int32_t dtmf_sender_interface_get_duration(
    const DtmfSenderInterface& dtmf);

int32_t dtmf_sender_interface_get_inter_tone_gap(
    const DtmfSenderInterface& dtmf);

// End DtmfSenderInterface



// RtpReceiverInterface

// todo
std::unique_ptr<std::string> rtp_receiver_interface_get_id(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<MediaStreamInterface>> rtp_receiver_interface_get_streams(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<MediaStreamTrackInterface> rtp_receiver_interface_get_track(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<std::string>> rtp_receiver_interface_get_stream_ids(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<RtpParameters> rtp_receiver_interface_get_parameters(
    const RtpReceiverInterface& receiver);

// End RtpReceiverInterface




// RtpParameters 

// todo
std::unique_ptr<std::string> rtp_parameters_get_transaction_id(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::string> rtp_parameters_get_mid(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpCodecParameters>> rtp_parameters_get_codecs(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpExtension>> rtp_parameters_get_header_extensions(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpEncodingParameters>> rtp_parameters_get_encodings(
    const RtpParameters& parameters);

// todo
std::unique_ptr<RtcpParameters> rtp_parameters_get_rtcp(
    const RtpParameters& parameters);

// End RtpParameters




// RtpExtension

// todo
std::unique_ptr<std::string> rtp_extension_get_uri(
    const RtpExtension& extension);

int32_t rtp_extension_get_id(
    const RtpExtension& extension);

bool rtp_extension_get_encrypt(
    const RtpExtension& extension);

// End RtpExtension




// RtcpParameters

// todo
std::unique_ptr<std::string> rtcp_parameters_get_cname(
    const RtcpParameters& rtcp);

// todo refact
bool rtcp_parameters_get_reduced_size(
    const RtcpParameters& rtcp);

// End RtcpParameters




// RtpCodecParameters

// todo 
std::unique_ptr<std::string> rtp_codec_parameters_get_name(
    const RtpCodecParameters& codec);

// todo 
int32_t rtp_codec_parameters_get_payload_type(
    const RtpCodecParameters& codec);

// todo optinoanl
int32_t rtp_codec_parameters_get_clock_rate(
    const RtpCodecParameters& codec);

// todo
int32_t rtp_codec_parameters_get_num_channels(
    const RtpCodecParameters& codec);

// todo
std::unique_ptr<std::vector<StringPair>> rtp_codec_parameters_get_parameters(
    const RtpCodecParameters& codec);

// todo
MediaType rtp_codec_parameters_get_kind(
    const RtpCodecParameters& codec);

// Enc RtpCodecParameters




// MediaStreamTrackInterface

// todo
std::unique_ptr<std::string> media_stream_track_interface_get_kind(
    const MediaStreamTrackInterface& track);

// todo
std::unique_ptr<std::string> media_stream_track_interface_get_id(
    const MediaStreamTrackInterface& track);

// todo
TrackState media_stream_track_interface_get_state(
    const MediaStreamTrackInterface& track);

// todo
bool media_stream_track_interface_get_enabled(
    const MediaStreamTrackInterface& track);

// todo recheck
std::unique_ptr<VideoTrackInterface> media_stream_track_interface_downcast_video_track(
  MediaStreamTrackInterface& track);
// todo recheck
std::unique_ptr<AudioTrackInterface> media_stream_track_interface_downcast_audio_track(
  MediaStreamTrackInterface& track);

// End MediaStreamTrackInterface




// MediaStreamInterface

// todo
std::unique_ptr<std::string> media_stream_interface_get_id(const MediaStreamInterface& stream);

// todo
std::unique_ptr<std::vector<AudioTrackInterface>> media_stream_interface_get_audio_tracks(
    const MediaStreamInterface& stream);

// todo
std::unique_ptr<std::vector<VideoTrackInterface>> media_stream_interface_get_video_tracks(
    const MediaStreamInterface& stream);

// End MediaStreamInterface




// VideoTrackInterface

// todo
const MediaStreamTrackInterface& video_track_truncation(
    const VideoTrackInterface& track);

// todo
std::unique_ptr<VideoTrackSourceInterface> video_track_get_sourse(
    const VideoTrackInterface& track);

// End VideoTrackInterface




// RtpEncodingParameters

// todo
bool rtp_encoding_parameters_get_active(
    const RtpEncodingParameters& encoding);

int32_t rtp_encoding_parameters_get_maxBitrate(
    const RtpEncodingParameters& encoding);

int32_t rtp_encoding_parameters_get_minBitrate(
    const RtpEncodingParameters& encoding);

double rtp_encoding_parameters_get_maxFramerate(
    const RtpEncodingParameters& encoding);

int64_t rtp_encoding_parameters_get_ssrc(
    const RtpEncodingParameters& encoding);

double rtp_encoding_parameters_get_scale_resolution_down_by(
    const RtpEncodingParameters& encoding);

// End RtpEncodingParameters




// AudioTrackInterface

// todo
const MediaStreamTrackInterface& audio_track_truncation(
    const AudioTrackInterface& track);

// todo
std::unique_ptr<AudioSourceInterface> audio_track_get_sourse(
     const AudioTrackInterface& track);

// End AudioTrackInterface



}  // namespace bridge
