#include "custom_video_renderer.h"

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
    rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb,
    size_t flutter_cb_ptr,
    webrtc::VideoTrackInterface* track_to_render) {
  printf("created rend\n");
  // rendered_track_->AddOrUpdateSink(this, rtc::VideoSinkWants());
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
  // cb_(std::make_unique<webrtc::VideoFrame>(video_frame), flutter_cb_ptr_);
  printf("on frame renderer\n");
}

}  // namespace bridge
