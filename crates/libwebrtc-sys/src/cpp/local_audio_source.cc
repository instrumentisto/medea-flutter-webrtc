#include "local_audio_source.h"

namespace bridge {

AudioSourceOnVolumeChangeObserver::AudioSourceOnVolumeChangeObserver(
    rust::Box<bridge::DynAudioSourceOnVolumeChangeCallback> cb)
    : cb_(std::move(cb)){};

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

  for (auto* sink : sinks_) {
    auto volume = calculate_audio_level((int16_t*) audio_data, number_of_channels * sample_rate / 100);
    if ((*observer_) != nullptr) {
      (*observer_)->VolumeChanged(volume);
    }
    sink->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels,
                 number_of_frames);
  }
}

void LocalAudioSource::RegisterVolumeObserver(AudioSourceOnVolumeChangeObserver* obs) {
  observer_ = obs;
}

}  // namespace bridge
