

#include "rtp_receiver_interface_getters.h"


namespace bridge {

// Returns a `id` of the given `RtpReceiverInterface`.
std::unique_ptr<std::string> get_rtp_receiver_id(
    const RtpReceiverInterface& receiver) {
        return std::make_unique<std::string>(receiver->id());
    }

// Returns a `streams` of the given `RtpReceiverInterface`.
std::unique_ptr<std::vector<MediaStreamInterface>> get_rtp_receiver_streams(
    const RtpReceiverInterface& receiver) {
        return std::make_unique<std::vector<MediaStreamInterface>>(receiver->streams());
    }

// Returns a `track` of the given `RtpReceiverInterface`.
std::unique_ptr<MediaStreamTrackInterface> get_rtp_receiver_track(
    const RtpReceiverInterface& receiver) {
        return std::make_unique<MediaStreamTrackInterface>(receiver->track());
    }

// Returns a `stream_ids` of the given `RtpReceiverInterface`.
std::unique_ptr<std::vector<std::string>> get_rtp_receiver_stream_ids(
    const RtpReceiverInterface& receiver) {
        return std::make_unique<std::vector<std::string>>(receiver->stream_ids());
    }

// Returns a `Parameters` of the given `RtpReceiverInterface`.
std::unique_ptr<RtpParameters> get_rtp_receiver_parameters(
    const RtpReceiverInterface& receiver){
        return std::make_unique<RtpParameters>(receiver->GetParameters());
    }
}