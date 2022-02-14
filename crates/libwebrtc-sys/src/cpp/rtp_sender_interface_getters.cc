

#include "rtp_sender_interface_getters.h"

namespace bridge {
std::unique_ptr<std::string> get_rtp_sender_id(
    const RtpSenderInterface& sender) {
      return std::make_unique<std::string>(sender->id());
    }

std::unique_ptr<DtmfSenderInterface> get_rtp_sender_dtmf(
    const RtpSenderInterface& sender) {
      return std::make_unique<DtmfSenderInterface>(sender->GetDtmfSender());
    }

std::unique_ptr<RtpParameters> get_rtp_sender_parameters(
    const RtpSenderInterface& sender) {
      return std::make_unique<RtpParameters>(sender->GetParameters());
    }

std::unique_ptr<MediaStreamTrackInterface> get_rtp_sender_track(
    const RtpSenderInterface& sender) {
      return std::make_unique<MediaStreamTrackInterface>(sender->track());
    }

}

// End RtpSenderInterface