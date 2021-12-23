#include <cstdint>
#include <memory>
#include <string>

#include "libwebrtc-sys/include/bridge.h"
#include "rtc_base/win32.h"

namespace WEBRTC {
std::unique_ptr<webrtc::TaskQueueFactory> create_default_task_queue_factory() {
  return webrtc::CreateDefaultTaskQueueFactory();
}

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    std::unique_ptr<webrtc::TaskQueueFactory> task_queue_factory) {
  rtc::scoped_refptr<webrtc::AudioDeviceModule> adm =
      webrtc::AudioDeviceModule::Create(
          webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio,
          task_queue_factory.get());

  return std::make_unique<AudioDeviceModule>(adm);
};

void init_audio_device_module(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  audio_device_module.get()->getptr()->Init();
};

int16_t playout_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  return audio_device_module.get()->getptr()->PlayoutDevices();
};

int16_t recording_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  return audio_device_module.get()->getptr()->RecordingDevices();
};

rust::Vec<rust::String> get_playout_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->PlayoutDeviceName(index, strNameUTF8,
                                                         strGuidUTF8);

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

rust::Vec<rust::String> get_recording_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->RecordingDeviceName(index, strNameUTF8,
                                                           strGuidUTF8);

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>
create_video_device_info() {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> unq_ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return unq_ptr;
};

uint32_t number_of_video_devices(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>&
        device_info) {
  return device_info.get()->NumberOfDevices();
};

rust::Vec<rust::String> get_video_device_name(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>& device_info,
    uint32_t index) {
  char device_name[256];
  char unique_id[256];

  device_info.get()->GetDeviceName(index, device_name, 256, unique_id, 256);

  rust::String strname = device_name;
  rust::String strid = unique_id;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

void start_thread(const std::unique_ptr<rtc::Thread>& thread) {
  thread.get()->Start();
}

std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread) {
  return std::make_unique<PeerConnectionFactoryInterface>(
      webrtc::CreatePeerConnectionFactory(
          worker_thread.get(), worker_thread.get(), signaling_thread.get(),
          nullptr, webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr));
}

std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  return std::make_unique<VideoTrackSourceInterface>(
      webrtc::CreateVideoTrackSourceProxy(
          signaling_thread.get(), worker_thread.get(),
          DeviceVideoCapturer::Create(width, height, fps, 0)));
}

std::unique_ptr<AudioSourceInterface> create_audio_source(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory) {
  return std::make_unique<AudioSourceInterface>(
      peer_connection_factory.get()->getptr()->CreateAudioSource(
          cricket::AudioOptions()));
}

std::unique_ptr<VideoTrackInterface> create_video_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<VideoTrackSourceInterface>& video_source) {
  return std::make_unique<VideoTrackInterface>(
      peer_connection_factory.get()->getptr()->CreateVideoTrack(
          "video_track", video_source.get()->getptr()));
}

std::unique_ptr<AudioTrackInterface> create_audio_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<AudioSourceInterface>& audio_source) {
  return std::make_unique<AudioTrackInterface>(
      peer_connection_factory.get()->getptr()->CreateAudioTrack(
          "audio_track", audio_source.get()->getptr()));
}

std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory) {
  return std::make_unique<MediaStreamInterface>(
      peer_connection_factory.get()->getptr()->CreateLocalMediaStream(
          "local_stream"));
}

bool add_video_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<VideoTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool add_audio_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<AudioTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool remove_video_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<VideoTrackInterface>& track) {
  return media_stream.get()->getptr()->RemoveTrack(track.get()->getptr());
}

bool remove_audio_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<AudioTrackInterface>& track) {
  return media_stream.get()->getptr()->RemoveTrack(track.get()->getptr());
}

int32_t frame_width(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->width();
}

int32_t frame_height(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->height();
}

int32_t frame_rotation(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->rotation();
}

rust::Vec<uint8_t> convert_to_argb(const std::unique_ptr<VideoFrame>& frame,
                                   const int32_t buffer_size) {
  auto video_frame = frame.get();
  rust::Vec<uint8_t> image;
  for (int i = 0; i < buffer_size; i++) {
    image.push_back((uint8_t)0);
  }

  rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
      video_frame->video_frame_buffer()->ToI420());
  if (video_frame->rotation() != webrtc::kVideoRotation_0) {
    buffer = webrtc::I420Buffer::Rotate(*buffer, video_frame->rotation());
  }

  libyuv::I420ToABGR(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
                     buffer->StrideU(), buffer->DataV(), buffer->StrideV(),
                     image.data(), video_frame->width() * 32 / 8,
                     buffer->width(), buffer->height());

  return image;
}

std::unique_ptr<VideoRenderer> get_video_renderer(
    rust::Fn<void(std::unique_ptr<VideoFrame>, int64_t*)> cb,
    int64_t* flutter_cb_ptr,
    const std::unique_ptr<VideoTrackInterface>& track_to_render) {
  return std::make_unique<VideoRenderer>(cb, flutter_cb_ptr,
                                         track_to_render.get()->getptr());
}

}  // namespace WEBRTC
