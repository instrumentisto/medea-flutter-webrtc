#ifndef SYS_AUDIO_CAPTURE_MAC_CAPTURE_H
#define SYS_AUDIO_CAPTURE_MAC_CAPTURE_H

#include <mutex>
#include <vector>

#include "libwebrtc-sys/include/audio_recorder.h"

// Returns true if ScreenCaptureKit-based system audio capture is available at
// runtime on this host (macOS >= 13).
bool IsSysAudioCaptureAvailable();

// System audio capture implementation for macOS using ScreenCaptureKit.
class SysAudioSource final : public AudioRecorder {
 public:
  SysAudioSource();

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

  // Forwards raw PCM data from ScreenCaptureKit callback.
  void OnPcmDataFromSC(const int16_t* data,
                       size_t frames,
                       unsigned int channels,
                       double sample_rate);

 private:
  std::recursive_mutex mutex_;

  bool recording_ = false;
  webrtc::scoped_refptr<bridge::LocalAudioSource> source_;
  std::vector<int16_t> recorded_samples_;

  void* stream_ = nullptr;  // SCStream*
  void* output_ = nullptr;  // id<SCStreamOutput>
  void* sample_queue_ = nullptr;  // dispatch_queue_t
};

#endif  // SYS_AUDIO_CAPTURE_MAC_CAPTURE_H


