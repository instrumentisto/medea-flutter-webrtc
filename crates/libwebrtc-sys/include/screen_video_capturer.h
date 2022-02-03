#ifndef SCREEN_VIDEO_CAPTURER_H_
#define SCREEN_VIDEO_CAPTURER_H_

#include <memory>
#include <vector>

#include <api/scoped_refptr.h>
#include <api/video/i420_buffer.h>
#include <media/base/adapted_video_track_source.h>
#include <modules/desktop_capture/cropped_desktop_frame.h>
#include <modules/desktop_capture/desktop_and_cursor_composer.h>
#include <modules/desktop_capture/desktop_capture_options.h>
#include <modules/desktop_capture/desktop_capturer.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/checks.h>
#include <rtc_base/logging.h>
#include <rtc_base/platform_thread.h>
#include <rtc_base/time_utils.h>
#include <system_wrappers/include/sleep.h>
#include <third_party/libyuv/include/libyuv.h>

class ScreenVideoCapturer : public rtc::AdaptedVideoTrackSource,
                            public rtc::VideoSinkInterface<webrtc::VideoFrame>,
                            public webrtc::DesktopCapturer::Callback {
 public:
  static bool GetSourceList(webrtc::DesktopCapturer::SourceList* sources);
  static const std::string GetSourceListString();
  ScreenVideoCapturer(webrtc::DesktopCapturer::SourceId source_id,
                      size_t max_width,
                      size_t max_height,
                      size_t target_fps);
  ~ScreenVideoCapturer();

 private:
  static void CaptureThread(void* obj);
  bool CaptureProcess();
  static webrtc::DesktopCaptureOptions CreateDesktopCaptureOptions();
  void OnCaptureResult(webrtc::DesktopCapturer::Result result,
                       std::unique_ptr<webrtc::DesktopFrame> frame) override;

  // `VideoSinkInterface` implementation.
  void OnFrame(const webrtc::VideoFrame& frame) override;

  // Indicates that parameters suitable for screencast should be automatically
  // applied to RtpSenders.
  bool is_screencast() const override;

  // Indicates that the encoder should denoise video before encoding it.
  // If it's not set, the default configuration is used which is different
  // depending on a video codec.
  absl::optional<bool> needs_denoising() const override;

  // Returns state of this `DeviceVideoCapturer`.
  webrtc::MediaSourceInterface::SourceState state() const override;

  // Returns `false` since `DeviceVideoCapturer` is meant to source local
  // devices only.
  bool remote() const override;

  size_t max_width_;
  size_t max_height_;
  size_t capture_width_;
  size_t capture_height_;
  int requested_frame_duration_;
  int max_cpu_consumption_percentage_;
  webrtc::DesktopSize previous_frame_size_;
  std::unique_ptr<webrtc::DesktopFrame> output_frame_;
  rtc::PlatformThread capture_thread_;
  std::unique_ptr<webrtc::DesktopCapturer> capturer_;
  std::atomic<bool> quit_;
};

#endif  // SCREEN_VIDEO_CAPTURER_H_
