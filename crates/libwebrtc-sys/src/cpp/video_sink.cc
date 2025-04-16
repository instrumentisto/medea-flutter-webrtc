#include "libwebrtc-sys/include/video_sink.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include "rtc_base/logging.h"

namespace video_sink {

// Creates a new `ForwardingVideoSink` backed by the provided
// `DynOnFrameCallback`.
ForwardingVideoSink::ForwardingVideoSink(
    rust::Box<bridge::DynOnFrameCallback> cb_) : cb_(std::move(cb_)) {}

// Propagates the received `VideoFrame` to the Rust side.
void ForwardingVideoSink::OnFrame(const webrtc::VideoFrame& video_frame) {
    ++n_frames;

    auto now = std::chrono::steady_clock::now();
    auto elapsed_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                          now - loged_at)
                          .count();

    if (elapsed_ms > 1000) {
      loged_at = now;
      RTC_LOG(LS_ERROR) << "ForwardingVideoSink fps: " << n_frames;
      n_frames = 0;
    }

  bridge::on_frame(*cb_.value(),
                   std::make_unique<webrtc::VideoFrame>(video_frame));
}

}  // namespace video_sink
