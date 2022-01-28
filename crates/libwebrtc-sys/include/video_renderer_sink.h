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
// `VideoSink` sinks to `VideoTrackInterface` and provides calling
// external callback on every incoming `VideoFrame`.
class VideoSink : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  // Creates a new `VideoSink`.
  VideoSink(std::unique_ptr<observer::VideoSinkObserver> obs_);

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // `VideoSinkObserver` which contains a `callback`.
  std::unique_ptr<observer::VideoSinkObserver> obs_;
};
}  // namespace bridge
