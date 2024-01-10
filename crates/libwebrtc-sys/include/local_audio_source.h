#ifndef BRIDGE_LOCAL_AUDIO_SOURCE_H_
#define BRIDGE_LOCAL_AUDIO_SOURCE_H_

#include "api/audio_options.h"
#include "api/media_stream_interface.h"
#include "rtc_base/logging.h"
#include "api/notifier.h"
#include "api/scoped_refptr.h"

// LocalAudioSource implements AudioSourceInterface.
// This contains settings for switching audio processing on and off.
namespace bridge {

class LocalAudioSource : public webrtc::Notifier<webrtc::AudioSourceInterface> {
 public:
  // Creates an instance of LocalAudioSource.
  static rtc::scoped_refptr<LocalAudioSource> Create(cricket::AudioOptions audio_options);

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

 protected:
  LocalAudioSource() {}
  ~LocalAudioSource() override {}

 private:
  cricket::AudioOptions _options;
  // TODO(review): why its only one sink? i believe it should be possible to create multiple
  //               tracks from single source.
  webrtc::AudioTrackSinkInterface* _sink;
};

}  // namespace bridge

#endif  // PC_LOCAL_AUDIO_SOURCE_H_
