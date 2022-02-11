
#pragma once

#include <memory>
#include <string>

#include "bridge.h"

namespace bridge {
std::unique_ptr<std::string> rtp_sender_interface_get_id(
    const RtpSenderInterface& sender);

std::unique_ptr<DtmfSenderInterface> rtp_sender_interface_get_dtmf(
    const RtpSenderInterface& sender);

std::unique_ptr<RtpParameters> rtp_sender_interface_get_parameters(
    const RtpSenderInterface& sender);

std::unique_ptr<MediaStreamTrackInterface> rtp_sender_interface_get_track(
    const RtpSenderInterface& sender);

}
