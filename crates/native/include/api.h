#pragma once

#include <string>

namespace rust {

inline namespace cxxbridge1 {

class String;

} // namespace cxxbridge1

} // namespace rust

struct VideoFrame;

// Callback for video frames handlers provided to the
// `Webrtc::create_video_sink()` function.
class OnFrameCallbackInterface {
 public:
  // Called when the underlying video engine produces a new video frame.
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};
