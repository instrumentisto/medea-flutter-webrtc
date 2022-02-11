
#pragma once
#include "bridge.h"


namespace bridge {

// todo
std::unique_ptr<std::string> rtp_parameters_get_transaction_id(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::string> rtp_parameters_get_mid(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpCodecParameters>> rtp_parameters_get_codecs(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpExtension>> rtp_parameters_get_header_extensions(
    const RtpParameters& parameters);

// todo
std::unique_ptr<std::vector<RtpEncodingParameters>> rtp_parameters_get_encodings(
    const RtpParameters& parameters);

// todo
std::unique_ptr<RtcpParameters> rtp_parameters_get_rtcp(
    const RtpParameters& parameters);
}
// End RtpParameters