

#pragma once
#include "bridge.h"

namespace bridge {
    std::unique_ptr<std::string> get_media_stream_track_kind(
        const MediaStreamTrackInterface& track);

    // todo
    std::unique_ptr<std::string> get_media_stream_track_id(
        const MediaStreamTrackInterface& track);

    // todo
    TrackState get_media_stream_track_state(
        const MediaStreamTrackInterface& track);

    // todo
    bool get_media_stream_track_enabled(
        const MediaStreamTrackInterface& track);

    // todo recheck
    std::unique_ptr<VideoTrackInterface> media_stream_track_interface_downcast_video_track(
    MediaStreamTrackInterface& track);
    
    // todo recheck
    std::unique_ptr<AudioTrackInterface> media_stream_track_interface_downcast_audio_track(
    MediaStreamTrackInterface& track);
}
