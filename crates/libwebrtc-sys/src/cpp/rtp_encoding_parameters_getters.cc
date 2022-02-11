

#include "rtp_encoding_parameters_getters.h"

namespace bridge {

bool rtp_encoding_parameters_get_active(
    const RtpEncodingParameters& encoding) {
      return encoding.active; 
    }

int32_t rtp_encoding_parameters_get_maxBitrate(
    const RtpEncodingParameters& encoding) {
      return encoding.max_bitrate_bps.value();
    }

int32_t rtp_encoding_parameters_get_minBitrate(
    const RtpEncodingParameters& encoding) {
      return encoding.min_bitrate_bps.value();
    }

double rtp_encoding_parameters_get_maxFramerate(
    const RtpEncodingParameters& encoding) {
      return encoding.max_framerate.value();
    }

int64_t rtp_encoding_parameters_get_ssrc(
    const RtpEncodingParameters& encoding) {
      return encoding.ssrc.value();
    }

double rtp_encoding_parameters_get_scale_resolution_down_by(
    const RtpEncodingParameters& encoding) {
      return encoding.scale_resolution_down_by.value();
    }
}