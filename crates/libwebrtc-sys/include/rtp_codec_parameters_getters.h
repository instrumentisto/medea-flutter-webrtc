

#pragma once
#include "bridge.h"

namespace bridge {
    // todo 
    std::unique_ptr<std::string> get_rtp_codec_parameters_name(
        const RtpCodecParameters& codec);

    // todo 
    int32_t get_rtp_codec_parameters_type(
        const RtpCodecParameters& codec);

    // todo 
    int32_t get_rtp_codec_parameters_rate(
        const RtpCodecParameters& codec);

    // todo
    int32_t get_rtp_codec_parameters_num_channels(
        const RtpCodecParameters& codec);

    // todo
    std::unique_ptr<std::vector<StringPair>> get_rtp_codec_parameters_parameters(
        const RtpCodecParameters& codec);

    // todo
    MediaType get_rtp_codec_parameters_kind(
        const RtpCodecParameters& codec);

     // todo 
    int32_t get_rtp_codec_parameters_payload_type(
        const RtpCodecParameters& codec);

     // todo
    int32_t get_rtp_codec_parameters_clock_rate(
     const RtpCodecParameters& codec);

    // Enc RtpCodecParameters
}
