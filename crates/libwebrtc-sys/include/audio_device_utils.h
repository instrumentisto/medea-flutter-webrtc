#ifndef AUDIO_DEVICE_UTILS_H_
#define AUDIO_DEVICE_UTILS_H_

#include <cstdint>
#include <string>

/// Audio device information.
struct DeviceNameWithFormat {
  /// Unique identifier for the represented device.
  std::string name;

  /// Unique identifier for the represented device.
  std::string guid;

  /// For audio devices: platform container ID (physical device identifier).
  std::string container_id;

  /// For audio devices: native sample rate.
  uint32_t sample_rate = 0;

  /// For audio devices: number of channels.
  uint16_t num_channels = 0;
};

// TODO: Only implemented on Windows.
// Fills sample_rate, num_channels and container_id by finding the WASAPI
// device whose friendly name matches `device_name`.
bool GetPlayoutDeviceFormat(const std::string& device_name,
                            DeviceNameWithFormat& out);

// TODO: Only implemented on Windows.
// Fills sample_rate, num_channels and container_id by finding the WASAPI
// device whose friendly name matches `device_name`.
bool GetRecordingDeviceFormat(const std::string& device_name,
                              DeviceNameWithFormat& out);

#endif  // AUDIO_DEVICE_UTILS_H_
