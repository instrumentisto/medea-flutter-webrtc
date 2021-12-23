#include "custom_video_renderer.h"

template <typename T>
class AutoLock {
 public:
  explicit AutoLock(T* obj) : obj_(obj) { obj_->Lock(); }
  ~AutoLock() { obj_->Unlock(); }

 protected:
  T* obj_;
};

namespace WEBRTC {

VideoRenderer::VideoRenderer(
    rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, int64_t*)>
        cb,
    int64_t* flutter_cb_ptr,
    webrtc::VideoTrackInterface* track_to_render)
    : cb_(cb),
      flutter_cb_ptr_(flutter_cb_ptr),
      rendered_track_(track_to_render) {
  rendered_track_->AddOrUpdateSink(this, rtc::VideoSinkWants());
}

VideoRenderer::~VideoRenderer() {
  rendered_track_->RemoveSink(this);
}

void VideoRenderer::OnFrame(const webrtc::VideoFrame& video_frame) {
  cb_(std::make_unique<webrtc::VideoFrame>(video_frame), flutter_cb_ptr_);
}

}  // namespace WEBRTC
