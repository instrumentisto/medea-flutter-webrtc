#include "local_audio_source.h"
#include "rtc_base/logging.h"

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
  RTC_LOG(LS_ERROR) << "LocalAudioSource::OnData";
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
  RTC_LOG(LS_ERROR) << "LocalAudioSource::OnData";

  if ((*observer_) != nullptr) {
    auto elapsed_time = std::chrono::steady_clock::now() - last_audio_level_recalculation_;
    if (std::chrono::duration_cast<std::chrono::milliseconds>(elapsed_time).count() > 100) {
      last_audio_level_recalculation_ = std::chrono::steady_clock::now();
      auto volume = calculate_audio_level((int16_t*) audio_data, number_of_channels * sample_rate / 100);
      (*observer_)->AudioLevelChanged(volume);
    }
  }

  for (auto* sink : sinks_) {
    sink->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels,
                 number_of_frames);
  }
}

void LocalAudioSource::RegisterAudioLevelObserver(AudioSourceOnAudioLevelChangeObserver* obs) {
  RTC_LOG(LS_ERROR)
    << "LocalAudioSource::RegisterAudioLevelObserver";
  observer_ = obs;
}

void LocalAudioSource::UnregisterAudioLevelObserver() {
  observer_ = nullptr;
}

}  // namespace bridge
