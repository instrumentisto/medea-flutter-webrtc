#pragma once

#include "media/base/adapted_video_track_source.h"
#include "modules/desktop_capture/desktop_capturer.h"
#include "modules/video_capture/video_capture.h"
#include "rtc_base/platform_thread.h"

class ScreenVideoCapturer : public rtc::AdaptedVideoTrackSource,
                            public rtc::VideoSinkInterface<webrtc::VideoFrame>,
                            public webrtc::DesktopCapturer::Callback {
 public:
  // Returns a list of avaliable `screen`s to capture.
  static bool GetSourceList(webrtc::DesktopCapturer::SourceList* sources);

  ScreenVideoCapturer(webrtc::DesktopCapturer::SourceId source_id,
                      size_t max_width,
                      size_t max_height,
                      size_t target_fps);
  ~ScreenVideoCapturer();

 private:
  // A handler for the `capture thread`.
  static void CaptureThread(void* obj);

  // Captures a `webrtc::DesktopFrame`.
  bool CaptureProcess();

  // Creates a `webrtc::DesktopCaptureOptions`.
  static webrtc::DesktopCaptureOptions CreateDesktopCaptureOptions();

  // A callback for `webrtc::DesktopCapturer::CaptureFrame`. Handles a
  // `DesktopFrame`, makes a `VideoFrame` from it.
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

  // A max width of the `VideoFrame`.
  size_t max_width_;

  // A max height of the `VideoFrame`.
  size_t max_height_;

  // The width of the captured `DesktopFrame`.
  size_t capture_width_;

  // The height of the captured `DesktopFrame`.
  size_t capture_height_;

  // An interval of capturing screen. Calculated according to the `target fps`.
  int requested_frame_duration_;

  // A percent of CPU consumption while capturing is going on. It can make `real
  // fps` lower than the `target fps` if CPU is slow. The `real fps` is so lower
  // as `max_cpu_consumption_percentage_` is higher. And on the contrary - `real
  // fps` rises when `max_cpu_consumption_percentage_` is getting lower, but the
  // `real fps` can't be higher than the `target fps`.
  int max_cpu_consumption_percentage_;

  // A size of the previous captured `DesktopFrame`.
  webrtc::DesktopSize previous_frame_size_;

  // The last captured `DesktopFrame`.
  std::unique_ptr<webrtc::DesktopFrame> output_frame_;

  // The `thread` where the capturing is going on.
  rtc::PlatformThread capture_thread_;

  // The instanse of the `webrtc::DesktopCapturer`, works on the
  // `capture_thread_`.
  std::unique_ptr<webrtc::DesktopCapturer> capturer_;

  // A signal flag to stop the capturing in the `capture_thread_`.
  std::atomic<bool> quit_;
};
