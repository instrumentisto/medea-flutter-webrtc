#include <iostream>

#include <algorithm>
#include <cfenv>
#include <chrono>
#include <cmath>
#include <thread>
#include <vector>
#include "audio_device_recorder.h"
#include "api/make_ref_counted.h"
#include "common_audio/wav_file.h"
#include "modules/audio_device/include/test_audio_device.h"
#include "rtc_base/checks.h"
#include "rtc_base/logging.h"
#include "rtc_base/platform_thread.h"

constexpr auto kPlayoutFrequency = 48000;
constexpr auto kRecordingFrequency = 48000;
constexpr auto kRecordingChannels = 1;
constexpr std::int64_t kBufferSizeMs = 10;
constexpr auto kRecordingPart =
    (kRecordingFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kProcessInterval = 10;
constexpr auto kALMaxValues = 6;
constexpr auto kQueryExactTimeEach = 20;
constexpr auto kDefaultPlayoutLatency = std::chrono::duration<double>(20.0);
constexpr auto kDefaultRecordingLatency = std::chrono::milliseconds(20);
constexpr auto kRestartAfterEmptyData = 50;  // Half a second with no data.
constexpr auto kPlayoutPart = (kPlayoutFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kBuffersFullCount = 7;
constexpr auto kBuffersKeepReadyCount = 5;

template <typename Callback>
void EnumerateDevices(ALCenum specifier, Callback&& callback) {
  auto devices = alcGetString(nullptr, specifier);
  while (*devices != 0) {
    callback(devices);
    while (*devices != 0) {
      ++devices;
    }
    ++devices;
  }
}

std::string GetDefaultDeviceId(ALCenum specifier) {
  const auto device = alcGetString(nullptr, specifier);
  return device ? std::string(device) : std::string();
}

bool CheckDeviceFailed(ALCdevice* device) {
  if (auto code = alcGetError(device); code != ALC_NO_ERROR) {
    RTC_LOG(LS_ERROR) << "OpenAL Error " << code << ": "
                      << (const char*)alcGetString(device, code);
    return true;
  }

  return false;
}

struct AudioDeviceRecorder::Data {
  Data() {}

  int recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
  std::vector<char>* recordedSamples =
      new std::vector<char>(recordBufferSize, 0);
  int emptyRecordingData = 0;
};

AudioDeviceRecorder::AudioDeviceRecorder(std::string deviceId) {
  _device = alcCaptureOpenDevice(
        deviceId.empty() ? nullptr : deviceId.c_str(),
        kRecordingFrequency, AL_FORMAT_MONO16, kRecordingFrequency);
  _source = bridge::LocalAudioSource::Create(cricket::AudioOptions());
  _deviceId = deviceId;
  _data = std::make_unique<Data>();
}

bool AudioDeviceRecorder::ProcessRecordedPart(bool isFirstInCycle) {
  RTC_LOG(LS_ERROR) << "proccess recorded part";
  auto data = _data.get();
  auto samples = ALint();
  alcGetIntegerv(_device, ALC_CAPTURE_SAMPLES, 1, &samples);

  if (CheckDeviceFailed(_device)) {
    _recordingFailed = true;
    return false;
  }

  if (samples <= 0) {
    if (isFirstInCycle) {
      ++data->emptyRecordingData;
      if (data->emptyRecordingData == kRestartAfterEmptyData) {
        restartRecording();
      }
    }
    return false;
  } else if (samples < kRecordingPart) {
    // Not enough data for 10 milliseconds.
    return false;
  }

  data->emptyRecordingData = 0;
  alcCaptureSamples(_device, data->recordedSamples->data(),
                    kRecordingPart);

  if (checkDeviceFailed()) {
    restartRecording();
    return false;
  }

  _source->OnData(
    data->recordedSamples->data(), // audio_data
    16,
    kRecordingFrequency, // sample_rate
    kRecordingChannels,
    kRecordingFrequency * 10 / 1000
  );
}

void AudioDeviceRecorder::StopCapture() {
  {
    std::lock_guard<std::recursive_mutex> lk(_mutex);
    if (!_recording) {
      return;
    }

    _recording = false;
    if (_recordingFailed) {
      return;
    }
    if (_device) {
      alcCaptureStop(_device);
    }
  }
}

void AudioDeviceRecorder::StartCapture() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);
  RTC_LOG(LS_ERROR) << "StartCapture";

  _recording = true;
  if (_recordingFailed) {
    return;
  }

  alcCaptureStart(_device);
  if (CheckDeviceFailed(_device)) {
    _recordingFailed = true;
    return;
  }

  if (_recordingFailed) {
    closeRecordingDevice();
  }
}

int32_t AudioDeviceRecorder::StartRecording() {
{
  RTC_LOG(LS_ERROR) << "StartRecording";
  if (_recording) {
    return 0;
  }

  if (_recordingFailed) {
    _recordingFailed = false;
    openRecordingDevice();
  }

  return 0;
}
}

bool AudioDeviceRecorder::IsRecording() const {
  return _recording;
}

int32_t AudioDeviceRecorder::StopRecording() {

}

rtc::scoped_refptr<bridge::LocalAudioSource> AudioDeviceRecorder::GetSource() {
  return _source;
}

bool AudioDeviceRecorder::checkDeviceFailed() {
  if (auto code = alcGetError(_device); code != ALC_NO_ERROR) {
    RTC_LOG(LS_ERROR) << "OpenAL Error " << code << ": "
                      << (const char*)alcGetString(_device, code);
    return true;
  }

  return false;
}

bool AudioDeviceRecorder::validateRecordingDeviceId() {
  auto valid = false;
  EnumerateDevices(ALC_CAPTURE_DEVICE_SPECIFIER, [&](const char* device) {
    if (!valid && _deviceId == std::string(device)) {
      valid = true;
    }
  });
  if (valid) {
    return true;
  }
  const auto defaultDeviceId =
      GetDefaultDeviceId(ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
  if (!defaultDeviceId.empty()) {
    _deviceId = defaultDeviceId;
    return true;
  }
  return false;
}

void AudioDeviceRecorder::restartRecording() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  // TODO(evdokimovs): Maybe check data for nullptr here:
  if (!_recording) {
    return;
  }

  closeRecordingDevice();

  if (!validateRecordingDeviceId()) {
    std::lock_guard<std::recursive_mutex> lk(_mutex);

    _recording = true;
    _recordingFailed = true;
    return;
  }

  _recordingFailed = false;
  openRecordingDevice();

  return;
}

void AudioDeviceRecorder::closeRecordingDevice() {
  std::lock_guard<std::recursive_mutex> lk(_mutex);

  if (_device) {
    alcCaptureCloseDevice(_device);
    _device = nullptr;
  }
}

void AudioDeviceRecorder::openRecordingDevice() {
  // TODO(evdokimovs): There was check for _recordingFailed,
  // but I think that this is wrong check.
  if (_device) {
    return;
  }

  _device = alcCaptureOpenDevice(
        _deviceId.empty() ? nullptr : _deviceId.c_str(),
        kRecordingFrequency, AL_FORMAT_MONO16, kRecordingFrequency);

  if (!_device) {
    _recordingFailed = true;
    return;
  }
}

