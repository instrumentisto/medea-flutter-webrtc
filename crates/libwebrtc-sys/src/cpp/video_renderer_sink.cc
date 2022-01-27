#include "video_renderer_sink.h"

namespace bridge {
// Creates a new `VideoRendererSink` and calls
// `VideoTrackInterface->AddOrUpdateSink()`.
VideoRendererSink::VideoRendererSink(
    std::unique_ptr<observer::VideoRendererSinkObserver> obs)
    : obs_(std::move(obs)) {}

// Calls the `cb_` on every incoming `VideoFrame`.
void VideoRendererSink::OnFrame(const webrtc::VideoFrame& video_frame) {
  obs_->OnFrame(video_frame);
}

}  // namespace bridge
