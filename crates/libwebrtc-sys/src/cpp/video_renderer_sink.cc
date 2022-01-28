#include "video_renderer_sink.h"

namespace bridge {
// Creates a new `VideoSink` and calls
// `VideoTrackInterface->AddOrUpdateSink()`.
VideoSink::VideoSink(std::unique_ptr<observer::VideoSinkObserver> obs)
    : obs_(std::move(obs)) {}

// Calls the `Callback` which is passed to `VideoSinkObserver` on every
// incoming `VideoFrame`.
void VideoSink::OnFrame(const webrtc::VideoFrame& video_frame) {
  obs_->OnFrame(video_frame);
}
}  // namespace bridge
