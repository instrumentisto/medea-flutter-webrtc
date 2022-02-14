

#pragma once
#include "bridge.h"

namespace bridge {
bool get_rtp_encoding_parameters_active(
    const RtpEncodingParameters& encoding);

int32_t get_rtp_encoding_parameters_maxBitrate(
    const RtpEncodingParameters& encoding);

int32_t get_rtp_encoding_parameters_minBitrate(
    const RtpEncodingParameters& encoding);

double get_rtp_encoding_parameters_maxFramerate(
    const RtpEncodingParameters& encoding);

int64_t get_rtp_encoding_parameters_ssrc(
    const RtpEncodingParameters& encoding);

double get_rtp_encoding_parameters_scale_resolution_down_by(
    const RtpEncodingParameters& encoding);
}