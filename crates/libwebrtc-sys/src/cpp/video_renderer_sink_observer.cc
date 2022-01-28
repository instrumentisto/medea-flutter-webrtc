#include "libwebrtc-sys/include/video_renderer_sink_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include "rust/cxx.h"

namespace observer {
// `VideoSinkObserver` constructor.
VideoSinkObserver::VideoSinkObserver(
    rust::Box<bridge::DynOnFrameCallback> handler) {
  this->handler_ = std::move(handler);
}

// A `callback` which is called on `VideoFrame`.
void VideoSinkObserver::OnFrame(const webrtc::VideoFrame& video_frame) {
  bridge::on_frame(*handler_.value(),
                   std::make_unique<webrtc::VideoFrame>(video_frame));
}
}  // namespace observer
