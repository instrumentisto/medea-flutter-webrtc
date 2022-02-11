

#include "rtp_parameters_getters.h"

// RtpParameters 
namespace bridge {
// todo
std::unique_ptr<std::string> rtp_parameters_get_transaction_id(
    const RtpParameters& parameters) {
      return std::make_unique<std::string>(parameters.transaction_id);
    }

// todo
std::unique_ptr<std::string> rtp_parameters_get_mid(
    const RtpParameters& parameters) {
      return std::make_unique<std::string>(parameters.mid);
    }

// todo
std::unique_ptr<std::vector<RtpCodecParameters>> rtp_parameters_get_codecs(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpCodecParameters>>(parameters.codecs);
    }

// todo
std::unique_ptr<std::vector<RtpExtension>> rtp_parameters_get_header_extensions(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpExtension>>(parameters.header_extensions);
    }

// todo
std::unique_ptr<std::vector<RtpEncodingParameters>> rtp_parameters_get_encodings(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpEncodingParameters>>(parameters.encodings);
    }

// todo
std::unique_ptr<RtcpParameters> rtp_parameters_get_rtcp(
    const RtpParameters& parameters) {
      return std::make_unique<RtcpParameters>(parameters.rtcp);
    }
}
// End RtpParameters