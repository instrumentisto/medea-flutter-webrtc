#include "local_audio_source.h"

namespace bridge {

rtc::scoped_refptr<LocalAudioSource> LocalAudioSource::Create(cricket::AudioOptions audio_options) {
  auto source = rtc::make_ref_counted<LocalAudioSource>();
  source->_options = audio_options;
  return source;
}

void LocalAudioSource::AddSink(webrtc::AudioTrackSinkInterface* sink) {
  _sink = sink;
}

void LocalAudioSource::RemoveSink(webrtc::AudioTrackSinkInterface* sink) {
  _sink = nullptr;
}

void LocalAudioSource::OnData(const void* audio_data,
                    int bits_per_sample,
                    int sample_rate,
                    size_t number_of_channels,
                    size_t number_of_frames) {
  if (_sink != nullptr) {
    _sink->OnData(audio_data, bits_per_sample, sample_rate, number_of_channels, number_of_frames);
  }
}

}  // namespace bridge
