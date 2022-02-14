

#include "rtp_encoding_parameters_getters.h"

namespace bridge {

// Returns `RtpEncodingParameters.active` field value.
bool get_rtp_encoding_parameters_active(
    const RtpEncodingParameters& encoding) {
      return encoding.active; 
    }

// Returns `RtpEncodingParameters.maxBitrate` field value.
int32_t get_rtp_encoding_parameters_maxBitrate(
    const RtpEncodingParameters& encoding) {
      return encoding.max_bitrate_bps.value();
    }

// Returns `RtpEncodingParameters.minBitrate` field value.
int32_t get_rtp_encoding_parameters_minBitrate(
    const RtpEncodingParameters& encoding) {
      return encoding.min_bitrate_bps.value();
    }

// Returns `RtpEncodingParameters.maxFramerate` field value.
double get_rtp_encoding_parameters_maxFramerate(
    const RtpEncodingParameters& encoding) {
      return encoding.max_framerate.value();
    }

// Returns `RtpEncodingParameters.ssrc` field value.
int64_t get_rtp_encoding_parameters_ssrc(
    const RtpEncodingParameters& encoding) {
      return encoding.ssrc.value();
    }

// Returns `RtpEncodingParameters.scale_resolution_down_by` field value.
double get_rtp_encoding_parameters_scale_resolution_down_by(
    const RtpEncodingParameters& encoding) {
      return encoding.scale_resolution_down_by.value();
    }
}