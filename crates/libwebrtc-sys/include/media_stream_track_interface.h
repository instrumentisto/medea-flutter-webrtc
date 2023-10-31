#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `kind` of the provided `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_kind(
    const bridge::MediaStreamTrackInterface& track);

// Returns the `id` of the provided `MediaStreamTrackInterface`.
std::unique_ptr<std::string> media_stream_track_id(
    const bridge::MediaStreamTrackInterface& track);

// Returns the `state` of the provided `MediaStreamTrackInterface`.
bridge::TrackState media_stream_track_state(const bridge::MediaStreamTrackInterface& track);

// Returns the `enabled` property of the provided `MediaStreamTrackInterface`.
bool media_stream_track_enabled(const bridge::MediaStreamTrackInterface& track);

// Downcasts the provided `MediaStreamTrackInterface` to a
// `VideoTrackInterface`.
std::unique_ptr<bridge::VideoTrackInterface>
media_stream_track_interface_downcast_video_track(
    std::unique_ptr<bridge::MediaStreamTrackInterface> track);

// Downcasts the provided `MediaStreamTrackInterface` to an
// `AudioTrackInterface`.
std::unique_ptr<bridge::AudioTrackInterface>
media_stream_track_interface_downcast_audio_track(
    std::unique_ptr<bridge::MediaStreamTrackInterface> track);

}  // namespace bridge
