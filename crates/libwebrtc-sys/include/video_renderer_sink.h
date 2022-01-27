#include <map>
#include <memory>
#include <string>

#include "api/media_stream_interface.h"
#include "api/video/i420_buffer.h"
#include "api/video/video_frame.h"
#include "libwebrtc-sys/include/video_renderer_sink_observer.h"
#include "media/base/media_channel.h"
#include "media/base/video_common.h"
#include "rtc_base/win32.h"
#include "third_party/libyuv/include/libyuv/convert_argb.h"

namespace bridge {
// `VideoRendererSink` sinks to `VideoTrackInterface` and provides calling
// external callback on every incoming `VideoFrame`.
class VideoRendererSink : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Creates a new `VideoRendererSink`.
  VideoRendererSink(std::unique_ptr<observer::VideoRendererSinkObserver> obs_);

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // `context` which is passed to `cb_`.
  std::unique_ptr<observer::VideoRendererSinkObserver> obs_;
};
}  // namespace bridge
