

#pragma once
#include "bridge.h"

namespace bridge {

    // Returns a `kind` of the given `MediaStreamTrackInterface`.
    std::unique_ptr<std::string> get_media_stream_track_kind(
        const MediaStreamTrackInterface& track);

    // Returns a `id` of the given `MediaStreamTrackInterface`.
    std::unique_ptr<std::string> get_media_stream_track_id(
        const MediaStreamTrackInterface& track);

    // Returns a `state` of the given `MediaStreamTrackInterface`.
    TrackState get_media_stream_track_state(
        const MediaStreamTrackInterface& track);

    // Returns a `enabled` of the given `MediaStreamTrackInterface`.
    bool get_media_stream_track_enabled(
        const MediaStreamTrackInterface& track);

    // Downcast `MediaStreamTrackInterface` to `VideoTrackInterface`.
    std::unique_ptr<VideoTrackInterface> media_stream_track_interface_downcast_video_track(
    MediaStreamTrackInterface& track);
    
    // Downcast `MediaStreamTrackInterface` to `AudioTrackInterface`.
    std::unique_ptr<AudioTrackInterface> media_stream_track_interface_downcast_audio_track(
    MediaStreamTrackInterface& track);
}
