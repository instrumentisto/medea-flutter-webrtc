#pragma once

#include <iostream>
#include <memory>
#include <string>

#include "libwebrtc-sys/include/peer_connection_observer.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"

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
using AudioFrameProcessor = webrtc::AudioFrameProcessor;
using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;
using PeerConnectionDependencies = webrtc::PeerConnectionDependencies;
using RTCConfiguration = webrtc::PeerConnectionInterface::RTCConfiguration;
using RTCOfferAnswerOptions =
    webrtc::PeerConnectionInterface::RTCOfferAnswerOptions;
using SdpType = webrtc::SdpType;
using SessionDescriptionInterface = webrtc::SessionDescriptionInterface;
using TaskQueueFactory = webrtc::TaskQueueFactory;
using VideoDecoderFactory = webrtc::VideoDecoderFactory;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using VideoEncoderFactory = webrtc::VideoEncoderFactory;

using AudioDecoderFactory = rc<webrtc::AudioDecoderFactory>;
using AudioDeviceModule = rc<webrtc::AudioDeviceModule>;
using AudioEncoderFactory = rc<webrtc::AudioEncoderFactory>;
using AudioMixer = rc<webrtc::AudioMixer>;
using AudioProcessing = rc<webrtc::AudioProcessing>;
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
using SetLocalDescriptionObserverInterface =
    observer::SetLocalDescriptionObserverInterface;
using SetRemoteDescriptionObserverInterface =
    observer::SetRemoteDescriptionObserverInterface;

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

// Calls `Thread->Create()`.
std::unique_ptr<Thread> create_thread();

// Creates `CreateBuiltinAudioEncoderFactory`.
std::unique_ptr<AudioEncoderFactory> create_builtin_audio_encoder_factory();

// Creates `CreateBuiltinAudioDecoderFactory`.
std::unique_ptr<AudioDecoderFactory> create_builtin_audio_decoder_factory();

// Creates `PeerConnectionFactoryInterface`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<Thread>& network_thread,
    const std::unique_ptr<Thread>& worker_thread,
    const std::unique_ptr<Thread>& signaling_thread,
    std::unique_ptr<AudioDeviceModule> default_adm,
    AudioEncoderFactory& audio_encoder_factory,
    AudioDecoderFactory& audio_decoder_factory,
    std::unique_ptr<VideoEncoderFactory> video_encoder_factory,
    std::unique_ptr<VideoDecoderFactory> video_decoder_factory,
    std::unique_ptr<AudioMixer> audio_mixer,
    std::unique_ptr<AudioProcessing> audio_processing,
    std::unique_ptr<AudioFrameProcessor> audio_frame_processor);

// Calls `PeerConnectionFactoryInterface->CreatePeerConnectionOrError`.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
    PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String& error,
    const RTCConfiguration& configuration,
    std::unique_ptr<PeerConnectionDependencies> dependencies);

// Creates default `RTCConfiguration`.
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration();

// Creates `PeerConnectionObserver`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer();

// Creates `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    std::unique_ptr<PeerConnectionObserver> observer);

// Creates `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_default_rtc_offer_answer_options();

// Creates `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(
    int32_t offer_to_receive_video,
    int32_t offer_to_receive_audio,
    bool voice_activity_detection,
    bool ice_restart,
    bool use_rtp_mux);

// Creates `CreateSessionDescriptionObserver`.
std::unique_ptr<CreateSessionDescriptionObserver> create_create_session_observer(
    rust::Fn<void(const std::string&, const std::string&, size_t)> s,
    rust::Fn<void(const std::string&, size_t)> f,
    rust::Fn<void(size_t)> d,
    size_t context_);

// Creates `SetLocalDescriptionObserverInterface`.
std::unique_ptr<SetLocalDescriptionObserverInterface> create_set_local_description_observer_interface(
    rust::Fn<void(size_t)> s,
    rust::Fn<void(const std::string&, size_t)> f,
    size_t context_);

// Creates `SetRemoteDescriptionObserverInterface`.
std::unique_ptr<SetRemoteDescriptionObserverInterface> create_set_remote_description_observer_interface(
    rust::Fn<void(size_t)> s,
    rust::Fn<void(const std::string&, size_t)> f,
    size_t context_);

// Calls `PeerConnectionInterface->CreateOffer`.
void create_offer(PeerConnectionInterface& peer_connection_interface,
                  const RTCOfferAnswerOptions& options,
                  std::unique_ptr<CreateSessionDescriptionObserver> obs);

// Calls `PeerConnectionInterface->CreateAnswer`.
void create_answer(PeerConnectionInterface& peer_connection_interface,
                   const RTCOfferAnswerOptions& options,
                   std::unique_ptr<CreateSessionDescriptionObserver> obs);

// Calls `PeerConnectionInterface->SetLocalDescription`.
void set_local_description(PeerConnectionInterface& peer_connection_interface,
                           std::unique_ptr<SessionDescriptionInterface> desc,
                           std::unique_ptr<SetLocalDescriptionObserverInterface> obs);

// Calls `PeerConnectionInterface->SetRemoteDescription`.
void set_remote_description(PeerConnectionInterface& peer_connection_interface,
                            std::unique_ptr<SessionDescriptionInterface> desc,
                            std::unique_ptr<SetRemoteDescriptionObserverInterface> obs);

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

}  // namespace bridge
