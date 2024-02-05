#include "local_audio_source.h"

namespace bridge {

// Creates new `AudioSourceOnAudioLevelChangeObserver` with a provided `DynAudioSourceOnAudioLevelChangeCallback`.
AudioSourceOnAudioLevelChangeObserver::AudioSourceOnAudioLevelChangeObserver(
    rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback> cb)
    : cb_(std::move(cb)){};

// Calculates audio level based on the provided audio data.
float calculate_audio_level(int16_t* data, int size) {
  double sum = 0.0;
  for (int i = 0; i<size; ++i) {
    sum += data[i] * data[i];
  }
  return std::sqrt(sum / size) / INT16_MAX;
}

rtc::scoped_refptr<LocalAudioSource> LocalAudioSource::Create(
    cricket::AudioOptions audio_options) {
  auto source = rtc::make_ref_counted<LocalAudioSource>();
  source->_options = audio_options;
  return source;
}

void LocalAudioSource::AddSink(webrtc::AudioTrackSinkInterface* sink) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  sinks_.push_back(sink);
}

void LocalAudioSource::RemoveSink(webrtc::AudioTrackSinkInterface* sink) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  sinks_.remove(sink);
}

void LocalAudioSource::OnData(const void* audio_data,
                              int bits_per_sample,
                              int sample_rate,
                              size_t number_of_channels,
                              size_t number_of_frames) {
  std::lock_guard<std::recursive_mutex> lk(sink_lock_);

  if ((*observer_) != nullptr) {
    // TODO(review): now - last > 100ms?
    if (_frames_without_volume_recalculation > 10) {
      _frames_without_volume_recalculation = 0;
      auto volume = calculate_audio_level((int16_t*) audio_data, number_of_channels * sample_rate / 100);
      (*observer_)->AudioLevelChanged(volume);
    } else {
      _frames_without_volume_recalculation++;
    }
  }

  for (auto* sink : sinks_) {
    sink->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels,
                 number_of_frames);
  }
}

void LocalAudioSource::RegisterAudioLevelObserver(AudioSourceOnAudioLevelChangeObserver* obs) {
  observer_ = obs;
}

void LocalAudioSource::UnregisterAudioLevelObserver() {
  observer_ = nullptr;
}

}  // namespace bridge
