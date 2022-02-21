#pragma once

#include "bridge.h"

namespace bridge {

// Returns `RtpCodecParameters.name` field value.
std::unique_ptr<std::string> rtp_codec_parameters_name(
    const webrtc::RtpCodecParameters& codec);

// Returns `RtpCodecParameters.num_channels` field value.
int32_t rtp_codec_parameters_num_channels(
    const webrtc::RtpCodecParameters& codec);

// Returns `RtpCodecParameters.kind` field value.
MediaType rtp_codec_parameters_kind(const webrtc::RtpCodecParameters& codec);

// Returns `RtpCodecParameters.payload_type` field value.
int32_t rtp_codec_parameters_payload_type(
    const webrtc::RtpCodecParameters& codec);

// Returns `RtpCodecParameters.clock_rate` field value.
int32_t rtp_codec_parameters_clock_rate(
    const webrtc::RtpCodecParameters& codec);

}  // namespace bridge
