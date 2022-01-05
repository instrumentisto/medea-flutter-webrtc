
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

namespace bridge {

class NativeVideoRenderer : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  NativeVideoRenderer(HWND wnd,
                      int width,
                      int height,
                      webrtc::VideoTrackInterface* track_to_render);
  virtual ~NativeVideoRenderer();

  void Lock() { ::EnterCriticalSection(&buffer_lock_); }

  void Unlock() { ::LeaveCriticalSection(&buffer_lock_); }

  // VideoSinkInterface implementation
  void OnFrame(const webrtc::VideoFrame& frame) override;

  const BITMAPINFO& bmi() const { return bmi_; }
  const uint8_t* image() const { return image_.get(); }

 protected:
  void SetSize(int width, int height);

  enum {
    SET_SIZE,
    RENDER_FRAME,
  };

  HWND wnd_;
  BITMAPINFO bmi_;
  std::unique_ptr<uint8_t[]> image_;
  CRITICAL_SECTION buffer_lock_;
  rtc::scoped_refptr<webrtc::VideoTrackInterface> rendered_track_;
};
}  // namespace bridge
