

#pragma once
#include "bridge.h"

namespace bridge {
    // todo 
    std::unique_ptr<std::string> rtp_codec_parameters_get_name(
        const RtpCodecParameters& codec);

    // todo 
    int32_t rtp_codec_parameters_get_payload_type(
        const RtpCodecParameters& codec);

    // todo optinoanl
    int32_t rtp_codec_parameters_get_clock_rate(
        const RtpCodecParameters& codec);

    // todo
    int32_t rtp_codec_parameters_get_num_channels(
        const RtpCodecParameters& codec);

    // todo
    std::unique_ptr<std::vector<StringPair>> rtp_codec_parameters_get_parameters(
        const RtpCodecParameters& codec);

    // todo
    MediaType rtp_codec_parameters_get_kind(
        const RtpCodecParameters& codec);

    // Enc RtpCodecParameters
}
