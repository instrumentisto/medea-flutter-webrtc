#pragma once

#include "bridge.h"

namespace bridge {

// Returns a `kind` of the given `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_kind(
    const MediaStreamTrackInterface& track);

// Returns an `id` of the given `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_id(
    const MediaStreamTrackInterface& track);

// Returns a `state` of the given `MediaStreamTrackInterface`.
TrackState media_stream_track_state(const MediaStreamTrackInterface& track);

// Returns an `enabled` property of the given `MediaStreamTrackInterface`.
bool media_stream_track_enabled(const MediaStreamTrackInterface& track);

// Downcasts the provided `MediaStreamTrackInterface` to `VideoTrackInterface`.
std::unique_ptr<VideoTrackInterface>
media_stream_track_interface_downcast_video_track(
    std::unique_ptr<MediaStreamTrackInterface> track);

// Downcasts the provided `MediaStreamTrackInterface` to `AudioTrackInterface`.
std::unique_ptr<AudioTrackInterface>
media_stream_track_interface_downcast_audio_track(
    std::unique_ptr<MediaStreamTrackInterface> track);

}  // namespace bridge
