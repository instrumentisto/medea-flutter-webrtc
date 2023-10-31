#pragma once

#include "bridge.h"

namespace bridge {

// Returns the `parameters` of the provided `RtpSenderInterface`.
std::unique_ptr<webrtc::RtpParameters> rtp_sender_parameters(
    const bridge::RtpSenderInterface& sender);

// Returns the `track` of the provided `RtpSenderInterface`.
std::unique_ptr<bridge::MediaStreamTrackInterface> rtp_sender_track(
    const bridge::RtpSenderInterface& sender);

// Replaces the track currently being used as the `sender`'s source with a new
// `VideoTrackInterface`.
bool replace_sender_video_track(
    const bridge::RtpSenderInterface& sender,
    const std::unique_ptr<bridge::VideoTrackInterface>& track);

// Replaces the track currently being used as the `sender`'s source with a new
// `AudioTrackInterface`.
bool replace_sender_audio_track(
    const bridge::RtpSenderInterface& sender,
    const std::unique_ptr<bridge::AudioTrackInterface>& track);

// Sets the `parameters` for the provided `RtpSenderInterface`.
rust::String rtp_sender_set_parameters(const bridge::RtpSenderInterface& sender, const webrtc::RtpParameters& parameters);

}  // namespace bridge
