

#include "rtp_parameters_getters.h"

// RtpParameters 
namespace bridge {
// Returns `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> get_rtp_parameters_transaction_id(
    const RtpParameters& parameters) {
      return std::make_unique<std::string>(parameters.transaction_id);
    }

// Returns `RtpParameters.mid` field value.
std::unique_ptr<std::string> get_rtp_parameters_mid(
    const RtpParameters& parameters) {
      return std::make_unique<std::string>(parameters.mid);
    }

// Returns `RtpParameters.codecs` field value.
std::unique_ptr<std::vector<RtpCodecParameters>> get_rtp_parameters_codecs(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpCodecParameters>>(parameters.codecs);
    }

// Returns `RtpParameters.header_extensions` field value.
std::unique_ptr<std::vector<RtpExtension>> get_rtp_parameters_header_extensions(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpExtension>>(parameters.header_extensions);
    }

// Returns `RtpParameters.encodings` field value.
std::unique_ptr<std::vector<RtpEncodingParameters>> get_rtp_parameters_encodings(
    const RtpParameters& parameters) {
      return std::make_unique<std::vector<RtpEncodingParameters>>(parameters.encodings);
    }

// Returns `RtpParameters.rtcp` field value.
std::unique_ptr<RtcpParameters> get_rtp_parameters_rtcp(
    const RtpParameters& parameters) {
      return std::make_unique<RtcpParameters>(parameters.rtcp);
    }
}
// End RtpParameters