#ifndef BRIDGE_LOCAL_AUDIO_SOURCE_H_
#define BRIDGE_LOCAL_AUDIO_SOURCE_H_

#include <mutex>
#include <optional>

#include "api/audio_options.h"
#include "api/media_stream_interface.h"
#include "api/notifier.h"
#include "api/scoped_refptr.h"
#include "rust/cxx.h"

namespace bridge {

struct DynAudioSourceOnAudioLevelChangeCallback;

class AudioSourceOnAudioLevelChangeObserver {
  public:
  AudioSourceOnAudioLevelChangeObserver(rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback> cb);
  void AudioLevelChanged(float volume);

  private:
    rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback> cb_;
};

// Implementation of an `AudioSourceInterface` with settings for switching audio
// processing on and off.
class LocalAudioSource : public webrtc::Notifier<webrtc::AudioSourceInterface> {
 public:
  // Creates a new `LocalAudioSource`.
  static rtc::scoped_refptr<LocalAudioSource> Create(
      cricket::AudioOptions audio_options);

  SourceState state() const override { return kLive; }
  bool remote() const override { return false; }

  const cricket::AudioOptions options() const override { return _options; }

  void AddSink(webrtc::AudioTrackSinkInterface* sink) override;
  void RemoveSink(webrtc::AudioTrackSinkInterface* sink) override;

  void OnData(const void* audio_data,
              int bits_per_sample,
              int sample_rate,
              size_t number_of_channels,
              size_t number_of_frames);

  void RegisterAudioLevelObserver(AudioSourceOnAudioLevelChangeObserver* obs);
  void UnregisterAudioLevelObserver();

 protected:
  LocalAudioSource() {}
  ~LocalAudioSource() override {}

 private:
  cricket::AudioOptions _options;
  std::recursive_mutex sink_lock_;
  uint16_t _frames_without_volume_recalculation = 0;
  std::list<webrtc::AudioTrackSinkInterface*> sinks_;
  std::optional<AudioSourceOnAudioLevelChangeObserver*> observer_;
};

}  // namespace bridge

#endif  // BRIDGE_LOCAL_AUDIO_SOURCE_H_
