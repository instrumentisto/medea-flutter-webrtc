#pragma once

#include <memory>
#include <string>
#include <iostream>

#include "libwebrtc-sys/include/peer_connection_observer.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"

#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
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
  ~rc() {
    ptr_->Release();
  }

  // Returns a pointer to the managed object.
  T *ptr() const {
    return ptr_;
  }

  // Returns a pointer to the managed object.
  T *operator->() const {
    return ptr_;
  }

 protected:
  // Pointer to the managed object.
  T *ptr_;
};

using TaskQueueFactory = webrtc::TaskQueueFactory;
using AudioDeviceModule = rc<webrtc::AudioDeviceModule>;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;

using Thread = rtc::Thread;
using PeerConnectionFactoryInterface =
    rc<webrtc::PeerConnectionFactoryInterface>;

using PeerConnectionInterface = rc<webrtc::PeerConnectionInterface>;
using RTCConfiguration = webrtc::PeerConnectionInterface::RTCConfiguration;
using PeerConnectionDependencies = webrtc::PeerConnectionDependencies;

using AudioEncoderFactory = rc<webrtc::AudioEncoderFactory>;
using AudioDecoderFactory = rc<webrtc::AudioDecoderFactory>;

using AudioMixer = rc<webrtc::AudioMixer>;
using AudioProcessing = rc<webrtc::AudioProcessing>;
using VideoEncoderFactory = webrtc::VideoEncoderFactory;
using VideoDecoderFactory = webrtc::VideoDecoderFactory;
using AudioFrameProcessor = webrtc::AudioFrameProcessor;
using RTCError = webrtc::RTCError;

using MyObserver = my_stuff::MyObserver;
using MyCreateSessionObserver = my_stuff::MyCreateSessionObserver;
using MySessionObserver = my_stuff::MySessionObserver;

using CreateSessionDescriptionObserver = webrtc::CreateSessionDescriptionObserver;
using RTCOfferAnswerOptions = webrtc::PeerConnectionInterface::RTCOfferAnswerOptions;
using SessionDescriptionInterface = webrtc::SessionDescriptionInterface;
using SetLocalDescriptionObserverInterface = rc<webrtc::SetLocalDescriptionObserverInterface>;
using SetRemoteDescriptionObserverInterface = rc<webrtc::SetRemoteDescriptionObserverInterface>;
using SdpType = webrtc::SdpType;



// Creates a new `AudioDeviceModule` for the given `AudioLayer`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory &task_queue_factory
);

// Initializes the native audio parts required for each platform.
int32_t init_audio_device_module(const AudioDeviceModule &audio_device_module);

// Returns count of the available playout audio devices.
int16_t playout_devices(const AudioDeviceModule &audio_device_module);

// Returns count of the available recording audio devices.
int16_t recording_devices(const AudioDeviceModule &audio_device_module);

// Obtains information regarding the specified audio playout device.
int32_t playout_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid
);

// Obtains information regarding the specified audio recording device.
int32_t recording_device_name(const AudioDeviceModule &audio_device_module,
                              int16_t index,
                              rust::String &name,
                              rust::String &guid);

// Creates a new `VideoDeviceInfo`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info();

// Obtains information regarding the specified video recording device.
int32_t video_device_name(VideoDeviceInfo &device_info,
                          uint32_t index,
                          rust::String &name,
                          rust::String &guid);

/// Creates a new thread.
std::unique_ptr<rtc::Thread> create_thread();

/// Starts the thread.
bool start_thread(rtc::Thread& thread);

/// Creates 'AudioEncoderFactory'
std::unique_ptr<AudioEncoderFactory> create_builtin_audio_encoder_factory();

/// Creates 'AudioDecoderFactory'
std::unique_ptr<AudioDecoderFactory> create_builtin_audio_decoder_factory();

/// Creates 'NULL AudioDeviceModule'
std::unique_ptr<AudioDeviceModule> create_audio_device_module_null();

/// Creates 'NULL AudioMixer'
std::unique_ptr<AudioMixer> create_audio_mixer_null();

/// Creates 'NULL AudioProcessing'
std::unique_ptr<AudioProcessing> create_audio_processing_null();

/// Creates 'NULL AudioFrameProcessor'
std::unique_ptr<AudioFrameProcessor> create_audio_frame_processor_null();

/// Creates a new Peer Connection Factory.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    Thread* network_thread,
    Thread* worker_thread,
    Thread* signaling_thread,
    AudioDeviceModule* default_adm,
    AudioEncoderFactory& audio_encoder_factory,
    AudioDecoderFactory& audio_decoder_factory,
    std::unique_ptr<VideoEncoderFactory> video_encoder_factory,
    std::unique_ptr<VideoDecoderFactory> video_decoder_factory,
    AudioMixer* audio_mixer,
    AudioProcessing* audio_processing,
    AudioFrameProcessor* audio_frame_processor); 

/// Creates a new Peer Connection.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
      PeerConnectionFactoryInterface& peer_connection_factory,
      const RTCConfiguration& configuration,
      std::unique_ptr<PeerConnectionDependencies> dependencies);

/// Creates default RTCConfiguration.      
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration();

/// Create MyObserver.   
std::unique_ptr<MyObserver> create_my_observer();

/// Create PeerConnectionDependencies.      
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
  std::unique_ptr<MyObserver> observer);

/// Get RTCError message. 
const char* rtc_error_or_message(RTCError& rtc);

/// Create default RTCOfferAnswerOptions
std::unique_ptr<RTCOfferAnswerOptions> create_default_rtc_offer_answer_options();

/// Create RTCOfferAnswerOptions
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(int32_t offer_to_receive_video,
  int32_t offer_to_receive_audio,
  bool voice_activity_detection,
  bool ice_restart,
  bool use_rtp_mux);

/// Create MyCreateSessionObserver.   
std::unique_ptr<MyCreateSessionObserver> create_my_offer_answer_observer(
  size_t s, 
  size_t f);

/// Create MySessionObserver.   
std::unique_ptr<MySessionObserver> create_my_description_observer(
  size_t s, 
  size_t f);

/// Call CreateOffer
void create_offer(PeerConnectionInterface& peer_connection_interface,
  const RTCOfferAnswerOptions& options, MyCreateSessionObserver* obs);

/// Call CreateAnswer
void create_answer(PeerConnectionInterface&  peer_connection_interface,
  const RTCOfferAnswerOptions& options, MyCreateSessionObserver* obs);

/// Call setLocalDescription
void set_local_description(PeerConnectionInterface& peer_connection_interface,
  std::unique_ptr<SessionDescriptionInterface> desc, MySessionObserver* obs);

/// Call setRemoteDescription
void set_remote_description(PeerConnectionInterface& peer_connection_interface,
  std::unique_ptr<SessionDescriptionInterface> desc,  MySessionObserver* obs);
}
