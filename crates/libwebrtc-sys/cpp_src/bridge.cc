#include <cstdint>
#include <memory>
#include <string>

#include <modules/desktop_capture/cropped_desktop_frame.h>
#include <modules/desktop_capture/desktop_and_cursor_composer.h>
#include <modules/desktop_capture/desktop_capture_options.h>
#include "libwebrtc-sys/include/bridge.h"

namespace bridge {

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
};

// Calls `AudioDeviceModule->Init()`.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->Init();
}

// Calls `AudioDeviceModule->PlayoutDevices()`.
int16_t playout_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->PlayoutDevices();
};

// Calls `AudioDeviceModule->RecordingDevices()`.
int16_t recording_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->RecordingDevices();
};

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
};

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
};

// Calls `VideoCaptureFactory->CreateDeviceInfo()`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
};

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
};

/// Calls `Thread->Create()`.
std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

/// Calls `Thread->Start()`.
bool start_thread(Thread& thread) {
  return thread.Start();
}

/// Calls `CreatePeerConnectionFactory()`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    Thread& worker_thread,
    Thread& signaling_thread) {
  return std::make_unique<PeerConnectionFactoryInterface>(
      webrtc::CreatePeerConnectionFactory(
          &worker_thread, &worker_thread, &signaling_thread, nullptr,
          webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr));
}

/// Calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  return std::make_unique<VideoTrackSourceInterface>(
      webrtc::CreateVideoTrackSourceProxy(
          &signaling_thread, &worker_thread,
          DeviceVideoCapturer::Create(width, height, fps, 0)));
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioSource()`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  return std::make_unique<AudioSourceInterface>(
      peer_connection_factory->CreateAudioSource(cricket::AudioOptions()));
}

/// Calls `PeerConnectionFactoryInterface->CreateVideoTrack`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    const VideoTrackSourceInterface& video_source) {
  return std::make_unique<VideoTrackInterface>(
      peer_connection_factory->CreateVideoTrack("video_track",
                                                video_source.ptr()));
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioTrack`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    const AudioSourceInterface& audio_source) {
  return std::make_unique<AudioTrackInterface>(
      peer_connection_factory->CreateAudioTrack("audio_track",
                                                audio_source.ptr()));
}

/// Calls `MediaStreamInterface->CreateLocalMediaStream`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  return std::make_unique<MediaStreamInterface>(
      peer_connection_factory->CreateLocalMediaStream("local_stream"));
}

/// Calls `MediaStreamInterface->AddTrack`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track) {
  return media_stream->AddTrack(track.ptr());
}

/// Calls `MediaStreamInterface->AddTrack`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track) {
  return media_stream->AddTrack(track.ptr());
}

/// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track) {
  return media_stream->RemoveTrack(track.ptr());
}

/// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track) {
  return media_stream->RemoveTrack(track.ptr());
}

void test() {
  webrtc::DesktopCapturer::SourceList sourceList;
  ScreenVideoCapturer::GetSourceList(&sourceList);
  std::unique_ptr<ScreenVideoCapturer> capturer(
      new rtc::RefCountedObject<ScreenVideoCapturer>(sourceList[0].id, 640, 480,
                                                     30));
  while (true) {
  }
}

}  // namespace bridge
