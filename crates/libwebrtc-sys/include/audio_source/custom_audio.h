#pragma once

#include <condition_variable>
#include <mutex>
#include "api/audio/audio_frame.h"
#include "api/audio/audio_mixer.h"
#include "common_audio/resampler/include/push_resampler.h"
#include "rtc_base/synchronization/mutex.h"

class RefCountedAudioSource : public webrtc::AudioMixer::Source,
                              public rtc::RefCountInterface {};

class AudioSource : public rtc::RefCountedObject<RefCountedAudioSource> {
 public:
  // Creates a new `AudioSource`.
  AudioSource();
  // Overwrites `audio_frame`. The data_ field is overwritten with
  // 10 ms of new audio (either 1 or 2 interleaved channels) at
  // `sample_rate_hz`. All fields in `audio_frame` must be updated.
  webrtc::AudioMixer::Source::AudioFrameInfo GetAudioFrameWithInfo(
      int sample_rate_hz,
      webrtc::AudioFrame* audio_frame) override;

  // A way for a mixer implementation to distinguish participants.
  int Ssrc() const override;

  // A way for this source to say that GetAudioFrameWithInfo called
  // with this sample rate or higher will not cause quality loss.
  int PreferredSampleRate() const;

  // Updates the audio frame data.
  void UpdateFrame(const int16_t* source,
                   int size,
                   int sample_rate,
                   int channels);

 private:
  webrtc::AudioFrame frame_;
  webrtc::PushResampler<int16_t> render_resampler_;
  int16_t resample_buffer[webrtc::AudioFrame::kMaxDataSizeSamples];

  std::mutex mutex_;
  std::condition_variable cv_;
  bool frame_available_ = false;
};