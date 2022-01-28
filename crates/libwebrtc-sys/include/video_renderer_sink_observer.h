#pragma once

#include <optional>

#include "api/video/video_frame.h"
#include "rust/cxx.h"

namespace bridge {
// Struct implement Rust trait `DynOnFrameCallback`.
struct DynOnFrameCallback;
}  // namespace bridge

namespace observer {
// Class used for calling Rust callback.
class VideoSinkObserver {
 public:
  // Class constructor, accepts `DynOnFrameCallback`.
  VideoSinkObserver(rust::Box<bridge::DynOnFrameCallback> handler);

  // Calls on every `VideoFrame`.
  void OnFrame(const webrtc::VideoFrame& video_frame);

 private:
  // A handler which contains RUst `DynOnFrameCallback`.
  std::optional<rust::Box<bridge::DynOnFrameCallback>> handler_;
};
}  // namespace observer
