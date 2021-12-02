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

bool stream_test() {
  const std::string id = "123";

  auto g_worker_thread = rtc::Thread::Create();
  g_worker_thread->Start();
  auto g_signaling_thread = rtc::Thread::Create();
  g_signaling_thread->Start();

  rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> pcf =
      webrtc::CreatePeerConnectionFactory(
          g_worker_thread.get(), g_worker_thread.get(),
          g_signaling_thread.get(), nullptr,
          webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr);

  rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> vsrc =
      webrtc::CreateVideoTrackSourceProxy(
          g_signaling_thread.get(), g_worker_thread.get(),
          DeviceVideoCapturer::Create(640, 480, 30, 0));
  rtc::scoped_refptr<webrtc::AudioSourceInterface> asrc =
      pcf.get()->CreateAudioSource(cricket::AudioOptions());

  rtc::scoped_refptr<webrtc::VideoTrackInterface> vtrack =
      pcf.get()->CreateVideoTrack("video_track", vsrc);
  rtc::scoped_refptr<webrtc::AudioTrackInterface> atrack =
      pcf.get()->CreateAudioTrack("audio_source", asrc);

  rtc::scoped_refptr<webrtc::MediaStreamInterface> lstream =
      pcf.get()->CreateLocalMediaStream("local_stream");
  lstream.get()->AddTrack(vtrack);
  lstream.get()->AddTrack(atrack);

  printf("Id: %s\nKind: %s\nState: %d\n", vtrack.get()->id().c_str(),
         vtrack.get()->kind().c_str(), vtrack.get()->state());
  printf("Id: %s\nKind: %s\nState: %d\n", atrack.get()->id().c_str(),
         atrack.get()->kind().c_str(), atrack.get()->state());
  printf("Id: %s\nVideos: %zd\nAudios: %zd\n", lstream.get()->id().c_str(),
         lstream.get()->GetVideoTracks().size(),
         lstream.get()->GetAudioTracks().size());

  printf("Enabled: %s\n", lstream.get()->GetVideoTracks()[0].get()->enabled()
                              ? "true"
                              : "false");

  system("PAUSE");

  lstream.get()->GetVideoTracks()[0].get()->set_enabled(false);
  printf("Enabled: %s\n", lstream.get()->GetVideoTracks()[0].get()->enabled()
                              ? "true"
                              : "false");

  system("PAUSE");

  return true;
}
}  // namespace WEBRTC
