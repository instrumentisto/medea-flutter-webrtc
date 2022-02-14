
#pragma once

#include <memory>
#include <string>

#include "bridge.h"

namespace bridge {
std::unique_ptr<std::string> get_rtp_sender_id(
    const RtpSenderInterface& sender);

std::unique_ptr<DtmfSenderInterface> get_rtp_sender_dtmf(
    const RtpSenderInterface& sender);

std::unique_ptr<RtpParameters> get_rtp_sender_parameters(
    const RtpSenderInterface& sender);

std::unique_ptr<MediaStreamTrackInterface> get_rtp_sender_track(
    const RtpSenderInterface& sender);

}
