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
// `VideoRendererSink` sinks to `VideoTrackInterface` and provides calling
// external callback on every incoming `VideoFrame`.
class VideoRendererSink : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Cretes a new `VideoRendererSink`.
  VideoRendererSink(rust::cxxbridge1::Fn<
                        void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb,
                    size_t flutter_cb_ptr);

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // Rust callback which is calling in `OnFrame`.
  rust::cxxbridge1::Fn<void(std::unique_ptr<webrtc::VideoFrame>, size_t)> cb_;
  // `context` which is passed to `cb_`.
  size_t ctx_;
};
}  // namespace bridge
