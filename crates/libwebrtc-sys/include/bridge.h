#pragma once

#include <memory>
#include <string>
#include <iostream>

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

/// Creates 'NULL AudioFrameProcessor'
std::unique_ptr<AudioFrameProcessor> create_audio_drame_processor_null();

/// Creates a new Peer Connection Factory.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory_null(
    Thread* network_thread,
    Thread* worker_thread,
    Thread* signaling_thread,
    //AudioDeviceModule& default_adm,
    AudioEncoderFactory& audio_encoder_factory,
    AudioDecoderFactory& audio_decoder_factory,
    std::unique_ptr<VideoEncoderFactory> video_encoder_factory,
    std::unique_ptr<VideoDecoderFactory> video_decoder_factory,
    //AudioMixer& audio_mixer,
    //AudioProcessing& audio_processing,
    AudioFrameProcessor* audio_frame_processor); 
}
