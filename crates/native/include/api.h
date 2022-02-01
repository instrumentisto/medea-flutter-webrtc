#pragma once

struct VideoFrame;

// Callback for the video frames handlers provided to the
// `Webrtc::create_video_sink()` function.
class OnFrameCallbackInterface {
 public:
  // Called when underlying video engine produces a new video frame.
  //
  // The provided frame is a pointer to the `rust::Box<VideoFrame>`. Its
  // ownership can be transferred back to the Rust side using the
  // `rust::Box::from_raw()`.
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};
