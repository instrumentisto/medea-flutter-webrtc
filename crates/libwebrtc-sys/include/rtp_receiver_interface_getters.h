

#pragma once

#include "bridge.h"


namespace bridge {
// todo
std::unique_ptr<std::string> get_rtp_receiver_id(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<MediaStreamInterface>> get_rtp_receiver_streams(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<MediaStreamTrackInterface> get_rtp_receiver_track(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<std::string>> get_rtp_receiver_stream_ids(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<RtpParameters> get_rtp_receiver_parameters(
    const RtpReceiverInterface& receiver);
}

