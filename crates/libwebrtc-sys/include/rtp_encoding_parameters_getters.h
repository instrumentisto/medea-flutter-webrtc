

#pragma once
#include "bridge.h"

namespace bridge {
bool rtp_encoding_parameters_get_active(
    const RtpEncodingParameters& encoding);

int32_t rtp_encoding_parameters_get_maxBitrate(
    const RtpEncodingParameters& encoding);

int32_t rtp_encoding_parameters_get_minBitrate(
    const RtpEncodingParameters& encoding);

double rtp_encoding_parameters_get_maxFramerate(
    const RtpEncodingParameters& encoding);

int64_t rtp_encoding_parameters_get_ssrc(
    const RtpEncodingParameters& encoding);

double rtp_encoding_parameters_get_scale_resolution_down_by(
    const RtpEncodingParameters& encoding);
}