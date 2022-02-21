#include "rtp_parameters.h"

namespace bridge {

// Returns `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> get_rtp_parameters_transaction_id(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::string>(parameters.transaction_id);
}

// Returns `RtpParameters.mid` field value.
std::unique_ptr<std::string> get_rtp_parameters_mid(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::string>(parameters.mid);
}

// Returns `RtpParameters.codecs` field value.
std::unique_ptr<std::vector<webrtc::RtpCodecParameters>>
get_rtp_parameters_codecs(const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::vector<webrtc::RtpCodecParameters>>(
      parameters.codecs);
}

// Returns `RtpParameters.header_extensions` field value.
std::unique_ptr<std::vector<webrtc::RtpExtension>>
get_rtp_parameters_header_extensions(const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::vector<webrtc::RtpExtension>>(
      parameters.header_extensions);
}

// Returns `RtpParameters.encodings` field value.
std::unique_ptr<std::vector<webrtc::RtpEncodingParameters>>
get_rtp_parameters_encodings(const webrtc::RtpParameters& parameters) {
  return std::make_unique<std::vector<webrtc::RtpEncodingParameters>>(
      parameters.encodings);
}

// Returns `RtpParameters.rtcp` field value.
std::unique_ptr<webrtc::RtcpParameters> get_rtp_parameters_rtcp(
    const webrtc::RtpParameters& parameters) {
  return std::make_unique<webrtc::RtcpParameters>(parameters.rtcp);
}

}  // namespace bridge
