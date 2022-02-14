
#include "rtp_codec_parameters_getters.h"

namespace bridge {
    // todo 
std::unique_ptr<std::string> get_rtp_codec_parameters_name(
    const RtpCodecParameters& codec) {
      return std::make_unique<std::string>(codec.name);
    }

 // todo 
 int32_t get_rtp_codec_parameters_payload_type(
     const RtpCodecParameters& codec) {
       return codec.payload_type;
     }

 // todo optinoanl
 int32_t get_rtp_codec_parameters_clock_rate(
     const RtpCodecParameters& codec) {
       return codec.clock_rate.value();
     }

 // todo optinoanl
 int32_t get_rtp_codec_parameters_num_channels(
     const RtpCodecParameters& codec) {
       return codec.num_channels.value();
     }

// todo
MediaType get_rtp_codec_parameters_kind(
    const RtpCodecParameters& codec) {
      return codec.kind;
    }
}