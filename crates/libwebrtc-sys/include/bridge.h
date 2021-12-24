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
using Thread = rtc::Thread;
using PeerConnectionFactoryInterface =
    RefCounted<webrtc::PeerConnectionFactoryInterface>;
using VideoTrackSourceInterface = RefCounted<webrtc::VideoTrackSourceInterface>;
using AudioSourceInterface = RefCounted<webrtc::AudioSourceInterface>;
using VideoTrackInterface = RefCounted<webrtc::VideoTrackInterface>;
using AudioTrackInterface = RefCounted<webrtc::AudioTrackInterface>;
using MediaStreamInterface = RefCounted<webrtc::MediaStreamInterface>;

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

std::unique_ptr<rtc::Thread> create_thread();

bool start_thread(const std::unique_ptr<rtc::Thread>& thread);

std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread);

std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread,
    size_t width,
    size_t height,
    size_t fps);

std::unique_ptr<AudioSourceInterface> create_audio_source(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory);

std::unique_ptr<VideoTrackInterface> create_video_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<VideoTrackSourceInterface>& video_source);

std::unique_ptr<AudioTrackInterface> create_audio_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<AudioSourceInterface>& audio_source);

std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory);

bool add_video_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<VideoTrackInterface>& track);

bool add_audio_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<AudioTrackInterface>& track);

bool remove_video_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<VideoTrackInterface>& track);

bool remove_audio_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<AudioTrackInterface>& track);
}  // namespace WEBRTC
