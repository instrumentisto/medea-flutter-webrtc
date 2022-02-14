

#pragma once

#include "bridge.h"


namespace bridge {
// Returns a `id` of the given `RtpReceiverInterface`.
std::unique_ptr<std::string> get_rtp_receiver_id(
    const RtpReceiverInterface& receiver);

// Returns a `streams` of the given `RtpReceiverInterface`.
std::unique_ptr<std::vector<MediaStreamInterface>> get_rtp_receiver_streams(
    const RtpReceiverInterface& receiver);

// Returns a `track` of the given `RtpReceiverInterface`.
std::unique_ptr<MediaStreamTrackInterface> get_rtp_receiver_track(
    const RtpReceiverInterface& receiver);

// Returns a `stream_ids` of the given `RtpReceiverInterface`.
std::unique_ptr<std::vector<std::string>> get_rtp_receiver_stream_ids(
    const RtpReceiverInterface& receiver);

// Returns a `parameters` of the given `RtpReceiverInterface`.
std::unique_ptr<RtpParameters> get_rtp_receiver_parameters(
    const RtpReceiverInterface& receiver);
}

