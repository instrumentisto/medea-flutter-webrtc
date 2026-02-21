#ifndef AUDIO_DEVICE_UTILS_H_
#define AUDIO_DEVICE_UTILS_H_

#include <cstdint>
#include <string>

// Audio device information.
struct DeviceNameWithFormat {
  // Human-readable device name.
  std::string name;

  // Unique identifier for the represented device.
  std::string guid;

  // Platform container ID (physical device identifier).
  //
  // For audio devices only.
  std::string container_id;

  // Native sample rate in `Hz`.
  //
  // For audio devices only.
  uint32_t sample_rate = 0;

  // Number of channels.
  //
  // For audio devices only.
  uint16_t num_channels = 0;
};

// TODO: Only implemented on Windows.
// Fills the `sample_rate`, `num_channels` and `container_id` by finding the
// WASAPI playout device whose friendly name matches the provided `device_name`.
bool GetPlayoutDeviceFormat(const std::string& device_name,
                            DeviceNameWithFormat& out);

// TODO: Only implemented on Windows.
// Fills the `sample_rate`, `num_channels` and `container_id` by finding the
// WASAPI recording device whose friendly name matches the provided
// `device_name`.
bool GetRecordingDeviceFormat(const std::string& device_name,
                              DeviceNameWithFormat& out);

#endif  // AUDIO_DEVICE_UTILS_H_
