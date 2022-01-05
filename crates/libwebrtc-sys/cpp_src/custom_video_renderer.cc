#include "custom_video_renderer.h"

#include <chrono>

template <typename T>
class AutoLock {
 public:
  explicit AutoLock(T* obj) : obj_(obj) { obj_->Lock(); }
  ~AutoLock() { obj_->Unlock(); }

 protected:
  T* obj_;
};

namespace bridge {
VideoRenderer::VideoRenderer(
    rust::cxxbridge1::Fn<
        void(std::unique_ptr<webrtc::VideoFrame>, size_t, uint16_t)> cb,
    size_t flutter_cb_ptr,
    webrtc::VideoTrackInterface* track_to_render)
    : cb_(cb),
      flutter_cb_ptr_(flutter_cb_ptr),
      rendered_track_(track_to_render) {
  rendered_track_->AddOrUpdateSink(this, rtc::VideoSinkWants());
}

VideoRenderer::~VideoRenderer() {
  if (!no_track_) {
    rendered_track_->RemoveSink(this);
  }
}

void VideoRenderer::SetNoTrack() {
  no_track_ = true;
}

void VideoRenderer::OnFrame(const webrtc::VideoFrame& video_frame) {
  printf("Frame '%d' before call CB in C++ at: %d (libWebRTC)\n",
         video_frame.id(),
         std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
             .count());

  cb_(std::make_unique<webrtc::VideoFrame>(video_frame), flutter_cb_ptr_,
      video_frame.id());
}

}  // namespace bridge
