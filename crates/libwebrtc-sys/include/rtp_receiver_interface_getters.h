

#pragma once

#include "bridge.h"


namespace bridge {
    // todo
std::unique_ptr<std::string> rtp_receiver_interface_get_id(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<MediaStreamInterface>> rtp_receiver_interface_get_streams(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<MediaStreamTrackInterface> rtp_receiver_interface_get_track(
    const RtpReceiverInterface& receiver);

// todo 
std::unique_ptr<std::vector<std::string>> rtp_receiver_interface_get_stream_ids(
    const RtpReceiverInterface& receiver);

// todo
std::unique_ptr<RtpParameters> rtp_receiver_interface_get_parameters(
    const RtpReceiverInterface& receiver);
}