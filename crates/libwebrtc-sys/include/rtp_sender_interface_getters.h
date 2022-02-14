
#pragma once

#include <memory>
#include <string>

#include "bridge.h"

namespace bridge {

// Returns a `id` of the given `RtpSenderInterface`.
std::unique_ptr<std::string> get_rtp_sender_id(
    const RtpSenderInterface& sender);

// Returns a `dtmf` of the given `RtpSenderInterface`.
std::unique_ptr<DtmfSenderInterface> get_rtp_sender_dtmf(
    const RtpSenderInterface& sender);

// Returns a `parameters` of the given `RtpSenderInterface`.
std::unique_ptr<RtpParameters> get_rtp_sender_parameters(
    const RtpSenderInterface& sender);

// Returns a `track` of the given `RtpSenderInterface`.
std::unique_ptr<MediaStreamTrackInterface> get_rtp_sender_track(
    const RtpSenderInterface& sender);

}
