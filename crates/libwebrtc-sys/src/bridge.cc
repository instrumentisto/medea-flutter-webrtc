#include <cstdint>
#include <memory>
#include <string>

#include "libwebrtc-sys/include/bridge.h"

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

bool add_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
               const std::unique_ptr<AudioTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool add_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
               const std::unique_ptr<VideoTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool stream_test() {
  // const std::string id = "123";

  auto g_worker_thread = rtc::Thread::Create();
  g_worker_thread->Start();
  auto g_signaling_thread = rtc::Thread::Create();
  g_signaling_thread->Start();

  // rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> pcf =
  //     webrtc::CreatePeerConnectionFactory(
  //         g_worker_thread.get(), g_worker_thread.get(),
  //         g_signaling_thread.get(), nullptr,
  //         webrtc::CreateBuiltinAudioEncoderFactory(),
  //         webrtc::CreateBuiltinAudioDecoderFactory(),
  //         webrtc::CreateBuiltinVideoEncoderFactory(),
  //         webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr);

  // rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> vsrc =
  //     webrtc::CreateVideoTrackSourceProxy(
  //         g_signaling_thread.get(), g_worker_thread.get(),
  //         DeviceVideoCapturer::Create(640, 480, 30, 0));
  // rtc::scoped_refptr<webrtc::AudioSourceInterface> asrc =
  //     pcf.get()->CreateAudioSource(cricket::AudioOptions());

  // rtc::scoped_refptr<webrtc::VideoTrackInterface> vtrack =
  //     pcf.get()->CreateVideoTrack("video_track", vsrc);
  // rtc::scoped_refptr<webrtc::AudioTrackInterface> atrack =
  //     pcf.get()->CreateAudioTrack("audio_track", asrc);

  // rtc::scoped_refptr<webrtc::MediaStreamInterface> lstream =
  //     pcf.get()->CreateLocalMediaStream("local_stream");
  // lstream.get()->AddTrack(vtrack);
  // lstream.get()->AddTrack(atrack);

  // printf("Id: %s\nKind: %s\nState: %d\n", vtrack.get()->id().c_str(),
  //        vtrack.get()->kind().c_str(), vtrack.get()->state());
  // printf("Id: %s\nKind: %s\nState: %d\n", atrack.get()->id().c_str(),
  //        atrack.get()->kind().c_str(), atrack.get()->state());
  // printf("Id: %s\nVideos: %zd\nAudios: %zd\n", lstream.get()->id().c_str(),
  //        lstream.get()->GetVideoTracks().size(),
  //        lstream.get()->GetAudioTracks().size());

  // printf("Enabled: %s\n", lstream.get()->GetVideoTracks()[0].get()->enabled()
  //                             ? "true"
  //                             : "false");

  // system("PAUSE");

  // lstream.get()->GetVideoTracks()[0].get()->set_enabled(false);
  // printf("Enabled: %s\n", lstream.get()->GetVideoTracks()[0].get()->enabled()
  //                             ? "true"
  //                             : "false");

  // system("PAUSE");

  return true;
}
}  // namespace WEBRTC
