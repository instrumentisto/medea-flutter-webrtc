
#include "rtp_codec_parameters_getters.h"

namespace bridge {
    // todo 
std::unique_ptr<std::string> rtp_codec_parameters_get_name(
    const RtpCodecParameters& codec) {
      return std::make_unique<std::string>(codec.name);
    }

 // todo 
 int32_t rtp_codec_parameters_get_payload_type(
     const RtpCodecParameters& codec) {
       return codec.payload_type;
     }

 // todo optinoanl
 int32_t rtp_codec_parameters_get_clock_rate(
     const RtpCodecParameters& codec) {
       return codec.clock_rate.value();
     }

 // todo optinoanl
 int32_t rtp_codec_parameters_get_num_channels(
     const RtpCodecParameters& codec) {
       return codec.num_channels.value();
     }

// todo
MediaType rtp_codec_parameters_get_kind(
    const RtpCodecParameters& codec) {
      return codec.kind;
    }
}