#include <memory>
#include <string>
#include <cstdint>

#include "libwebrtc-sys/include/bridge.h"

namespace WEBRTC {
std::unique_ptr<webrtc::TaskQueueFactory> create_default_task_queue_factory() {
  return webrtc::CreateDefaultTaskQueueFactory();
}

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    std::unique_ptr<webrtc::TaskQueueFactory> &task_queue_factory
) {
  auto adm = webrtc::AudioDeviceModule::Create(
      webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio,
      task_queue_factory.get());

  return std::make_unique<AudioDeviceModule>(adm);
};

void init_audio_device_module(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  audio_device_module.get()->getptr()->Init();
}

int16_t playout_devices(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  return audio_device_module.get()->getptr()->PlayoutDevices();
};

int16_t recording_devices(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  return audio_device_module.get()->getptr()->RecordingDevices();
};

rust::Vec<rust::String> get_playout_audio_info(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module,
    int16_t index) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->PlayoutDeviceName(index,
                                                         strNameUTF8,
                                                         strGuidUTF8);

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

rust::Vec<rust::String> get_recording_audio_info(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module,
    int16_t index
) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->RecordingDeviceName(
      index, strNameUTF8, strGuidUTF8
  );

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>
create_video_device_info() {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
};

uint32_t number_of_video_devices(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> &device_info) {
  return device_info.get()->NumberOfDevices();
};

rust::Vec<rust::String> get_video_device_name(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> &device_info,
    uint32_t index
) {
  char device_name[256];
  char unique_id[256];

  device_info.get()->GetDeviceName(index, device_name, 256, unique_id, 256);

  rust::String strname = device_name;
  rust::String strid = unique_id;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};
}
