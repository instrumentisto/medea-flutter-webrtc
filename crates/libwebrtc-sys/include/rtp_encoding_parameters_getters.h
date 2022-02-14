

#pragma once
#include "bridge.h"

namespace bridge {

// Returns `RtpEncodingParameters.active` field value.
bool get_rtp_encoding_parameters_active(
    const RtpEncodingParameters& encoding);

// Returns `RtpEncodingParameters.maxBitrate` field value.
int32_t get_rtp_encoding_parameters_maxBitrate(
    const RtpEncodingParameters& encoding);

// Returns `RtpEncodingParameters.minBitrate` field value.
int32_t get_rtp_encoding_parameters_minBitrate(
    const RtpEncodingParameters& encoding);

// Returns `RtpEncodingParameters.maxFramerate` field value.
double get_rtp_encoding_parameters_maxFramerate(
    const RtpEncodingParameters& encoding);

// Returns `RtpEncodingParameters.ssrc` field value.
int64_t get_rtp_encoding_parameters_ssrc(
    const RtpEncodingParameters& encoding);

// Returns `RtpEncodingParameters.scale_resolution_down_by` field value.
double get_rtp_encoding_parameters_scale_resolution_down_by(
    const RtpEncodingParameters& encoding);
}