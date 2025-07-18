#ifndef BRIDGE_AUDIO_RECORDER_H_
#define BRIDGE_AUDIO_RECORDER_H_

#include "libwebrtc-sys/include/local_audio_source.h"

// Uniform interface for recording audio.
class AudioRecorder {
 public:
  // Captures a new batch of audio samples and propagates it to the inner
  // `bridge::LocalAudioSource`.
  virtual bool ProcessRecordedPart(bool firstInCycle) = 0;

  // Stops audio capture freeing the captured device.
  virtual void StopCapture() = 0;

  // Starts recording audio from the captured device.
  virtual void StartCapture() = 0;

  // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
  // writes the recorded audio to.
  virtual webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() = 0;

  virtual ~AudioRecorder() = default;
};

#endif  // BRIDGE_AUDIO_RECORDER_H_