#include <map>
#include <memory>
#include <string>

#include "api/media_stream_interface.h"
#include "api/video/i420_buffer.h"
#include "api/video/video_frame.h"
#include "media/base/media_channel.h"
#include "media/base/video_common.h"
#include "rtc_base/win32.h"
#include "third_party/libyuv/include/libyuv/convert_argb.h"

#include "rust/cxx.h"

namespace bridge {

class VideoRenderer : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  VideoRenderer(rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>,
                                          size_t)> cb,
                size_t flutter_cb_ptr,
                webrtc::VideoTrackInterface* track_to_render);
  virtual ~VideoRenderer();

  void SetNoTrack();

  // VideoSinkInterface implementation
  void OnFrame(const webrtc::VideoFrame& frame) override;

  webrtc::VideoTrackInterface* rendered_track_;
  rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb_;
  size_t flutter_cb_ptr_;
  bool no_track_ = false;
};
}  // namespace bridge
