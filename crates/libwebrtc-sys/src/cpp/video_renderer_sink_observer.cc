#include "libwebrtc-sys/include/video_renderer_sink_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include "rust/cxx.h"

namespace observer {
VideoRendererSinkObserver::VideoRendererSinkObserver(
    rust::Box<bridge::DynCallback> handler) {
  this->handler_ = std::move(handler);
}

void VideoRendererSinkObserver::OnFrame(const webrtc::VideoFrame& video_frame) {
  bridge::on_frame_asd(handler_.value(),
                       std::make_unique<webrtc::VideoFrame>(video_frame));
}
}  // namespace observer
