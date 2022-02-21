#include "media_stream_track_interface.h"

namespace bridge {

// Returns a `kind` of the given `MediaStreamTrackInterface`.
const std::string& media_stream_track_kind(
    const MediaStreamTrackInterface& track) {
  return track->kind();
}

// Returns a `id` of the given `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_id(
    const MediaStreamTrackInterface& track) {
  return std::make_unique<std::string>(track->id());
}

// Returns a `state` of the given `MediaStreamTrackInterface`.
TrackState media_stream_track_state(
    const MediaStreamTrackInterface& track) {
  return track->state();
}

// Returns a `enabled` of the given `MediaStreamTrackInterface`.
bool media_stream_track_enabled(const MediaStreamTrackInterface& track) {
  return track->enabled();
}

// Downcast `MediaStreamTrackInterface` to `VideoTrackInterface`.
std::unique_ptr<VideoTrackInterface>
media_stream_track_interface_downcast_video_track(
    std::unique_ptr<MediaStreamTrackInterface> track) {
  return std::make_unique<VideoTrackInterface>(
      static_cast<webrtc::VideoTrackInterface*>(track.release()->release()));
}

// Downcast `MediaStreamTrackInterface` to `AudioTrackInterface`.
std::unique_ptr<AudioTrackInterface>
media_stream_track_interface_downcast_audio_track(
    std::unique_ptr<MediaStreamTrackInterface> track) {
  return std::make_unique<AudioTrackInterface>(
      static_cast<webrtc::AudioTrackInterface*>(track.release()->release()));
}

}  // namespace bridge
