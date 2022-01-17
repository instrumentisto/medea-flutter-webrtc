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
// `VideoRenderer` sinks to `VideoTrackInterface` and provides calling external
// callback on every incoming `VideoFrame`.
class VideoRenderer : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Cretes a new `VideoRenderer`.
  VideoRenderer(rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>,
                                          size_t)> cb,
                size_t flutter_cb_ptr,
                webrtc::VideoTrackInterface* track_to_render);

  // Disposes the existing `VideoRenderer`.
  virtual ~VideoRenderer();

  // Sets `no_track_` to `false`.
  void SetNoTrack();

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // `VideoTrackInterface` which is watched by this `VideoRenderer`.
  webrtc::VideoTrackInterface* rendered_track_;
  // Rust callback which is calling in `OnFrame`.
  rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb_;
  // Flutter C++ callback which is passed to `cb_`.
  size_t flutter_cb_ptr_;
  // Indicates is passed `VideoTrackInterface` exists. It's required because the
  // `VideoTrackInterface` is presented as a raw pointer and its existing
  // can't be controlled from the `VideoRenderer`.
  bool no_track_ = false;
};
}  // namespace bridge
