
#include "rtp_codec_parameters_getters.h"

namespace bridge {
// Returns `RtpCodecParameters.name` field value.
std::unique_ptr<std::string> get_rtp_codec_parameters_name(
    const RtpCodecParameters& codec) {
      return std::make_unique<std::string>(codec.name);
    }

// Returns `RtpCodecParameters.payload_type` field value.
int32_t get_rtp_codec_parameters_payload_type(
    const RtpCodecParameters& codec) {
      return codec.payload_type;
    }

// Returns `RtpCodecParameters.clock_rate` field value.
int32_t get_rtp_codec_parameters_clock_rate(
    const RtpCodecParameters& codec) {
      return codec.clock_rate.value();
    }

// Returns `RtpCodecParameters.num_channels` field value.
int32_t get_rtp_codec_parameters_num_channels(
    const RtpCodecParameters& codec) {
      return codec.num_channels.value();
    }

// Returns `RtpCodecParameters.kind` field value.
MediaType get_rtp_codec_parameters_kind(
    const RtpCodecParameters& codec) {
      return codec.kind;
    }
}