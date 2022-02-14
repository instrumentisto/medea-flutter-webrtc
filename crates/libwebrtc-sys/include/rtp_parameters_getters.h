
#pragma once
#include "bridge.h"


namespace bridge {

// Returns `RtpParameters.transaction_id` field value.
std::unique_ptr<std::string> get_rtp_parameters_transaction_id(
    const RtpParameters& parameters);

// Returns `RtpParameters.mid` field value.
std::unique_ptr<std::string> get_rtp_parameters_mid(
    const RtpParameters& parameters);

// Returns `RtpParameters.codecs` field value.
std::unique_ptr<std::vector<RtpCodecParameters>> get_rtp_parameters_codecs(
    const RtpParameters& parameters);

// Returns `RtpParameters.header_extensions` field value.
std::unique_ptr<std::vector<RtpExtension>> get_rtp_parameters_header_extensions(
    const RtpParameters& parameters);

// Returns `RtpParameters.encodings` field value.
std::unique_ptr<std::vector<RtpEncodingParameters>> get_rtp_parameters_encodings(
    const RtpParameters& parameters);

// Returns `RtpParameters.rtcp` field value.
std::unique_ptr<RtcpParameters> get_rtp_parameters_rtcp(
    const RtpParameters& parameters);
}