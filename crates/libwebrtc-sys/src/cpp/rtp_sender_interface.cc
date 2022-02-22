#include "rtp_sender_interface.h"

namespace bridge {

// Returns a `parameters` of the given `RtpSenderInterface`.
std::unique_ptr<webrtc::RtpParameters> rtp_sender_parameters(
    const RtpSenderInterface& sender) {
  return std::make_unique<webrtc::RtpParameters>(sender->GetParameters());
}

// Returns a `track` of the given `RtpSenderInterface`.
std::unique_ptr<MediaStreamTrackInterface> rtp_sender_track(
    const RtpSenderInterface& sender) {
  return std::make_unique<MediaStreamTrackInterface>(sender->track());
}

// Calls `RtpSenderInterface->SetTrack()`.
bool replace_sender_video_track(
    const RtpSenderInterface& sender,
    const std::unique_ptr<VideoTrackInterface>& track) {
  if (!track.get()) {
    return sender->SetTrack(nullptr);
  } else {
    return sender->SetTrack(track.get()->get());
  }
}

// Calls `RtpSenderInterface->SetTrack()`.
bool replace_sender_audio_track(
    const RtpSenderInterface& sender,
    const std::unique_ptr<AudioTrackInterface>& track) {
  if (!track.get()) {
    return sender->SetTrack(nullptr);
  } else {
    return sender->SetTrack(track.get()->get());
  }
}

}  // namespace bridge
