#include <memory>
#include <string>
#include <cstdint>

#include "libwebrtc-sys/include/bridge.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    const std::unique_ptr<webrtc::TaskQueueFactory> &task_queue_factory
) {
  auto adm = webrtc::AudioDeviceModule::Create(
      audio_layer,
      task_queue_factory.get()
  );

  return std::make_unique<AudioDeviceModule>(adm);
};

void init_audio_device_module(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  audio_device_module->ptr()->Init();
}

int16_t playout_devices(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  return audio_device_module->ptr()->PlayoutDevices();
};

int16_t recording_devices(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module) {
  return audio_device_module->ptr()->RecordingDevices();
};

rust::Vec<rust::String> playout_device_name(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module,
    int16_t index) {

  char name[webrtc::kAdmMaxDeviceNameSize];
  char guid[webrtc::kAdmMaxGuidSize];

  audio_device_module->ptr()->PlayoutDeviceName(index,
                                                name,
                                                guid);

  rust::String strname = name;
  rust::String strid = guid;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

rust::Vec<rust::String> recording_device_name(
    const std::unique_ptr<AudioDeviceModule> &audio_device_module,
    int16_t index
) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module->ptr()->RecordingDeviceName(
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
  return device_info->NumberOfDevices();
};

rust::Vec<rust::String> video_device_name(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> &device_info,
    uint32_t index
) {
  char device_name[256];
  char unique_id[256];

  device_info->GetDeviceName(index, device_name, 256, unique_id, 256);

  rust::String strname = device_name;
  rust::String strid = unique_id;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};
}
