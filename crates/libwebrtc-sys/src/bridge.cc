#include <memory>
#include <string>
#include <cstdint>

#include "libwebrtc-sys/include/bridge.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory &task_queue_factory
) {
  auto adm = webrtc::AudioDeviceModule::Create(
      audio_layer,
      &task_queue_factory
  );

  return std::make_unique<AudioDeviceModule>(adm);
};

void init_audio_device_module(
    const AudioDeviceModule &audio_device_module) {
  audio_device_module->Init();
}

int16_t playout_devices(
    const AudioDeviceModule &audio_device_module) {
  return audio_device_module->PlayoutDevices();
};

int16_t recording_devices(
    const AudioDeviceModule &audio_device_module) {
  return audio_device_module->RecordingDevices();
};

rust::Vec<rust::String> playout_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid) {

  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result = audio_device_module->PlayoutDeviceName(index,
                                                                name_buff,
                                                                guid_buff);
  name = name_buff;
  guid = guid_buff;

  return result;
};

int32_t recording_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid
) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->RecordingDeviceName(index, name_buff, guid_buff);

  name = name_buff;
  guid = guid_buff;

  return result;
};

std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
};

int32_t video_device_name(
    VideoDeviceInfo &device_info,
    uint32_t index,
    rust::String &name,
    rust::String &guid
) {
  char name_buff[256];
  char guid_buff[256];

  const int32_t
      size = device_info.GetDeviceName(index, name_buff, 256, guid_buff, 256);

  name = name_buff;
  guid = guid_buff;

  return size;
};
}
