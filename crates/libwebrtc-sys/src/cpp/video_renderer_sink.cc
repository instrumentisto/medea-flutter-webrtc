#include "video_renderer_sink.h"

namespace bridge {
// Creates a new `VideoRendererSink` and calls
// `VideoTrackInterface->AddOrUpdateSink()`.
VideoRendererSink::VideoRendererSink(
    rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb,
    size_t ctx)
    : cb_(cb), ctx_(ctx) {}

// Calls the `cb_` on every incoming `VideoFrame`.
void VideoRendererSink::OnFrame(const webrtc::VideoFrame& video_frame) {
  cb_(std::make_unique<webrtc::VideoFrame>(video_frame), ctx_);
}

}  // namespace bridge
