#pragma once

#include <optional>

#include "api/video/video_frame.h"
#include "rust/cxx.h"

namespace bridge {
struct DynCallback;
}

namespace observer {
class VideoRendererSinkObserver {
 public:
  VideoRendererSinkObserver(rust::Box<bridge::DynCallback> handler);

  void OnFrame(const webrtc::VideoFrame& video_frame);

 private:
  std::optional<rust::Box<bridge::DynCallback>> handler_;
};
}  // namespace observer
