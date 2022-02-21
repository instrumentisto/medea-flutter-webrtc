#pragma once

#include "bridge.h"

namespace bridge {

// Returns `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> rtp_parameters_transaction_id(
    const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.mid` field value.
std::unique_ptr<std::string> rtp_parameters_mid(
    const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.codecs` field value.
std::unique_ptr<std::vector<webrtc::RtpCodecParameters>> rtp_parameters_codecs(
    const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.header_extensions` field value.
std::unique_ptr<std::vector<webrtc::RtpExtension>>
rtp_parameters_header_extensions(const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.encodings` field value.
std::unique_ptr<std::vector<webrtc::RtpEncodingParameters>>
rtp_parameters_encodings(const webrtc::RtpParameters& parameters);

// Returns `RtpParameters.rtcp` field value.
std::unique_ptr<webrtc::RtcpParameters> rtp_parameters_rtcp(
    const webrtc::RtpParameters& parameters);

}  // namespace bridge
