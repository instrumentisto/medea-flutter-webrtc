

#pragma once
#include "bridge.h"

namespace bridge {
    
    // Returns `RtpCodecParameters.name` field value.
    std::unique_ptr<std::string> get_rtp_codec_parameters_name(
        const RtpCodecParameters& codec);

    // Returns `RtpCodecParameters.num_channels` field value.
    int32_t get_rtp_codec_parameters_num_channels(
        const RtpCodecParameters& codec);

    // Returns `RtpCodecParameters.kind` field value.
    MediaType get_rtp_codec_parameters_kind(
        const RtpCodecParameters& codec);

    // Returns `RtpCodecParameters.payload_type` field value.
    int32_t get_rtp_codec_parameters_payload_type(
        const RtpCodecParameters& codec);

    // Returns `RtpCodecParameters.clock_rate` field value.
    int32_t get_rtp_codec_parameters_clock_rate(
     const RtpCodecParameters& codec);
}
