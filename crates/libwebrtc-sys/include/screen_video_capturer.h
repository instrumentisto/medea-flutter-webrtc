// This is a slightly tweaked version of
// https://github.com/shiguredo/momo/blob/b81b51da8e2b823090d6a7f966fc517e047237e6/src/rtc/screen_video_capturer.h
//
// Copyright 2015-2021, tnoho (Original Author)
// Copyright 2018-2021, Shiguredo Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#pragma once

#include "media/base/adapted_video_track_source.h"
#include "modules/desktop_capture/desktop_capturer.h"
#include "modules/video_capture/video_capture.h"
#include "rtc_base/platform_thread.h"

// `VideoTrackSourceInterface` that captures frames a user's display.
class ScreenVideoCapturer : public rtc::AdaptedVideoTrackSource,
                            public rtc::VideoSinkInterface<webrtc::VideoFrame>,
                            public webrtc::DesktopCapturer::Callback {
 public:

  // Fills the provided `SourceList` with all available screens that can be
  // used by this `ScreenVideoCapturer`.
  static bool GetSourceList(webrtc::DesktopCapturer::SourceList* sources);

  // Creates a new `ScreenVideoCapturer` with the specified constraints.
  ScreenVideoCapturer(webrtc::DesktopCapturer::SourceId source_id,
                      size_t max_width,
                      size_t max_height,
                      size_t target_fps);
  ~ScreenVideoCapturer();

 private:
  // Captures a `webrtc::DesktopFrame`.
  bool CaptureProcess();

  // A callback for `webrtc::DesktopCapturer::CaptureFrame`. Converts a
  // `DesktopFrame` to a `VideoFrame` that is forwarded to
  // `ScreenVideoCapturer::OnFrame`.
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

  // Returns state of this `ScreenVideoCapturer`.
  webrtc::MediaSourceInterface::SourceState state() const override;

  // Returns `false` since `ScreenVideoCapturer` is used to capture local
  // display surface.
  bool remote() const override;

  // A max width of the captured `VideoFrame`.
  size_t max_width_;

  // A max height of the captured `VideoFrame`.
  size_t max_height_;

  // Target frame capturing interval.
  int requested_frame_duration_;

  // The width of the captured `DesktopFrame`.
  size_t capture_width_;

  // The height of the captured `DesktopFrame`.
  size_t capture_height_;

  // A size of the previous captured `DesktopFrame`.
  webrtc::DesktopSize previous_frame_size_;

  // The last captured `DesktopFrame`.
  std::unique_ptr<webrtc::DesktopFrame> output_frame_;

  // The `PlatformThread` that does the actual frames capturing.
  rtc::PlatformThread capture_thread_;

  // `webrtc::DesktopCapturer` used to capture frames.
  std::unique_ptr<webrtc::DesktopCapturer> capturer_;

  // Flag that signals the `capture_thread_` to stop.
  std::atomic<bool> quit_;
};
