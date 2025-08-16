#ifndef BRIDGE_AUDIO_DEVICE_RECORDER_H_
#define BRIDGE_AUDIO_DEVICE_RECORDER_H_

#include <AL/al.h>
#include <AL/alc.h>
#include <mutex>

#include "libwebrtc-sys/include/audio_recorder.h"

// Audio recording from an audio device and propagation of the recorded audio
// data to a `bridge::LocalAudioSource`.
class AudioDeviceRecorder final : public AudioRecorder {
 public:
  AudioDeviceRecorder(std::string deviceId,
                      webrtc::scoped_refptr<webrtc::AudioProcessing> ap);

  // Captures a new batch of audio samples and propagates it to the inner
  // `bridge::LocalAudioSource`.
  bool ProcessRecordedPart(bool firstInCycle) override;

  // Stops audio capture freeing the captured device.
  void StopCapture() override;

  // Starts recording audio from the captured device.
  bool StartCapture() override;

  // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
  // writes the recorded audio to.
  webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() override;

 private:
  void openRecordingDevice();
  bool checkDeviceFailed();
  void closeRecordingDevice();
  void restartRecording();
  bool validateRecordingDeviceId();

  webrtc::scoped_refptr<bridge::LocalAudioSource> _source;
  webrtc::scoped_refptr<webrtc::AudioProcessing> _audio_processing;
  ALCdevice* _device;
  std::string _deviceId;
  std::recursive_mutex _mutex;
  bool _recordingFailed = false;
  bool _recording = false;
  int _recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
  std::vector<char> _recordedSamples;
  int _emptyRecordingData = 0;
};

#endif  // BRIDGE_AUDIO_DEVICE_RECORDER_H_
