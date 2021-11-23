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
  // rtc::scoped_refptr<webrtc::MediaStream> media_stream =
  //     webrtc::MediaStream::Create(id);

  // cricket::AudioOptions opts;
  // rtc::scoped_refptr<webrtc::LocalAudioSource> audio_src =
  //     webrtc::LocalAudioSource::Create(&opts);

  // rtc::scoped_refptr<webrtc::AudioTrack> audio_track =
  //     webrtc::AudioTrack::Create(id, audio_src);

  // media_stream.get()->AddTrack(audio_track.get());

  // printf("Stream: %d\n", media_stream.get()->GetAudioTracks().size());

  // if (src.get()->remote()) {
  //   printf("remote");
  // } else {
  //   printf("local");
  // }

  // auto b = a.get()->GetAudioTracks();
  // auto c = a.get()->id();

  // webrtc::PeerConnectionInterface::RTCConfiguration cnstr;
  // webrtc::PeerConnectionDependencies dpnds(nullptr);

  auto g_worker_thread = rtc::Thread::Create();
  g_worker_thread->Start();
  auto g_signaling_thread = rtc::Thread::Create();
  g_signaling_thread->Start();

  rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> pcf =
      webrtc::CreatePeerConnectionFactory(
          g_worker_thread.get(), g_worker_thread.get(),
          g_signaling_thread.get(),
          webrtc::AudioDeviceModule::Create(
              webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio,
              create_default_task_queue_factory().get()),
          webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr);

  // rtc::scoped_refptr<webrtc::PeerConnectionInterface> pc =
  //     pcf.get()->CreatePeerConnection(cnstr, std::move(dpnds));

  // std::string label = "test_track";
  // cricket::AudioOptions opts;
  // rtc::scoped_refptr<webrtc::AudioSourceInterface> src =
  //     pcf.get()->CreateAudioSource(opts);

  // auto track = pcf.get()->CreateAudioTrack(label, src);

  // if (track.get()->enabled()) {
  //   printf("enabled\n");
  // } else {
  //   printf("disabled\n");
  // }

  // track.get()->set_enabled(false);

  // if (track.get()->enabled()) {
  //   printf("enabled\n");
  // } else {
  //   printf("disabled\n");
  // }

  // auto lcst = pcf.get()->CreateLocalMediaStream(id);
  // lcst.get()->AddTrack(track);

  // printf("\nSize: %d\n\n", lcst.get()->GetAudioTracks().size());

  // auto a = webrtc::VideoTrackSource(false);
  // auto a = webrtc::FrameGeneratorCapturerVideoTrackSource(
  //     webrtc::FrameGeneratorCapturerVideoTrackSource::Config(),
  //     webrtc::Clock::GetRealTimeClock());

  // pcf.get()->CreateVideoTrack(id, a);

  auto a = webrtc::VideoCaptureFactory::CreateDeviceInfo();

  char strNameUTF8[128];
  char strGuidUTF8[128];

  a->GetDeviceName(0, strNameUTF8, 128, strGuidUTF8, 128);

  webrtc::VideoCaptureCapability cap;

  a->GetCapability(strGuidUTF8, 0, cap);

  printf("Test: %d\n.", cap.videoType);

  auto b = webrtc::VideoCaptureFactory::Create(strGuidUTF8);

  b.get()->StartCapture(cap);
  _sleep(5000);
  b.get()->StopCapture();

  auto vtrack =
      pcf.get()->CreateVideoTrack("test", CapturerTrackSource::Create());

  printf("Track: %s\n", vtrack.get()->id());

  return true;
}
}  // namespace WEBRTC
