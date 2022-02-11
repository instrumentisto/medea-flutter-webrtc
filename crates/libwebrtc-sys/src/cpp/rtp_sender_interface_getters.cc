

#include "rtp_sender_interface_getters.h"

namespace bridge {
std::unique_ptr<std::string> rtp_sender_interface_get_id(
    const RtpSenderInterface& sender) {
      return std::make_unique<std::string>(sender->id());
    }

std::unique_ptr<DtmfSenderInterface> rtp_sender_interface_get_dtmf(
    const RtpSenderInterface& sender) {
      return std::make_unique<DtmfSenderInterface>(sender->GetDtmfSender());
    }

std::unique_ptr<RtpParameters> rtp_sender_interface_get_parameters(
    const RtpSenderInterface& sender) {
      return std::make_unique<RtpParameters>(sender->GetParameters());
    }

std::unique_ptr<MediaStreamTrackInterface> rtp_sender_interface_get_track(
    const RtpSenderInterface& sender) {
      return std::make_unique<MediaStreamTrackInterface>(sender->track());
    }

}

// End RtpSenderInterface