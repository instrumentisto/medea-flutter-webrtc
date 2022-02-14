

#pragma once
#include "bridge.h"

namespace bridge {
    std::unique_ptr<std::string> media_stream_track_interface_get_kind(
        const MediaStreamTrackInterface& track);

    // todo
    std::unique_ptr<std::string> media_stream_track_interface_get_id(
        const MediaStreamTrackInterface& track);

    // todo
    TrackState media_stream_track_interface_get_state(
        const MediaStreamTrackInterface& track);

    // todo
    bool media_stream_track_interface_get_enabled(
        const MediaStreamTrackInterface& track);

    // todo recheck
    std::unique_ptr<VideoTrackInterface> media_stream_track_interface_downcast_video_track(
    MediaStreamTrackInterface& track);
    
    // todo recheck
    std::unique_ptr<AudioTrackInterface> media_stream_track_interface_downcast_audio_track(
    MediaStreamTrackInterface& track);
}
