#pragma once

#include <iostream>
#include <memory>
#include <string>

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
#include "rust/cxx.h"

namespace WEBRTC {
template <class T>
class RefCounted {
 public:
  typedef T element_type;
  RefCounted(rtc::scoped_refptr<T> p) : ptr_(p.release()) {}
  ~RefCounted() { ptr_->Release(); }
  auto getptr() { return ptr_; }

 protected:
  T* ptr_;
};

using TaskQueueFactory = webrtc::TaskQueueFactory;
using AudioDeviceModule = RefCounted<webrtc::AudioDeviceModule>;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;

std::unique_ptr<webrtc::TaskQueueFactory> create_default_task_queue_factory();

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    std::unique_ptr<webrtc::TaskQueueFactory> task_queue_factory);
void init_audio_device_module(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module);
int16_t playout_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module);
int16_t recording_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module);
rust::Vec<rust::String> get_playout_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index);
rust::Vec<rust::String> get_recording_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index);

std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>
create_video_device_info();
uint32_t number_of_video_devices(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>& device_info);
rust::Vec<rust::String> get_video_device_name(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>& device_info,
    uint32_t index);

bool stream_test();
}  // namespace WEBRTC
