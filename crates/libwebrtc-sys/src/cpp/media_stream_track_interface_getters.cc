

#include "media_stream_track_interface_getters.h"

namespace bridge {
// todo
std::unique_ptr<std::string> media_stream_track_interface_get_kind(
    const MediaStreamTrackInterface& track) {
      return std::make_unique<std::string>(track->kind());
    }

// todo
std::unique_ptr<std::string> media_stream_track_interface_get_id(
    const MediaStreamTrackInterface& track) {
      return std::make_unique<std::string>(track->id());
    }

// todo
TrackState media_stream_track_interface_get_state(
    const MediaStreamTrackInterface& track) {
      return track->state();
    }

// todo
bool media_stream_track_interface_get_enabled(
    const MediaStreamTrackInterface& track) {
      return track->enabled();
    }

// todo recheck
std::unique_ptr<VideoTrackInterface> media_stream_track_interface_downcast_video_track(
  MediaStreamTrackInterface& track) {
    return std::make_unique<VideoTrackInterface>(static_cast<webrtc::VideoTrackInterface*>(track.release()));
  }

// todo recheck
std::unique_ptr<AudioTrackInterface> media_stream_track_interface_downcast_audio_track(
  MediaStreamTrackInterface& track) {
    return std::make_unique<AudioTrackInterface>(static_cast<webrtc::AudioTrackInterface*>(track.release()));
  }

}
