#ifndef BRIDGE_VIDEO_SINK_H_
#define BRIDGE_VIDEO_SINK_H_

#include <map>
#include <memory>
#include <optional>
#include <chrono>

#include "api/media_stream_interface.h"
#include "api/video/video_frame.h"
#include "rust/cxx.h"

namespace bridge {

struct DynOnFrameCallback;

}  // namespace bridge

namespace video_sink {

// `VideoSinkInterface<webrtc::VideoFrame>` forwarding `VideoFrame`s to the Rust
// side via `DynOnFrameCallback`.
class ForwardingVideoSink : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Creates a new `ForwardingVideoSink` backed by the provided
  // `DynOnFrameCallback`.
  ForwardingVideoSink(rust::Box<bridge::DynOnFrameCallback> cb_);

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

 private:
  // Rust side callback that the `VideoFrame`s will be forwarded to.
  std::optional<rust::Box<bridge::DynOnFrameCallback>> cb_;
  int n_frames = 0;
  std::chrono::steady_clock::time_point loged_at = std::chrono::steady_clock::now();
};

}  // namespace video_sink

#endif // BRIDGE_VIDEO_SINK_H_
