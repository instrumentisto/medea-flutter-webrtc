/*
 *  Copyright (c) 2019 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
#ifndef MAC_CAPTURER_H_
#define MAC_CAPTURER_H_

#include <memory>
#include <string>
#include <vector>

// WebRTC
#include <api/media_stream_interface.h>
#include <media/base/adapted_video_track_source.h>
#include <api/scoped_refptr.h>
#include <base/RTCMacros.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/thread.h>
#include <rtc_base/ref_counted_object.h>
#include <media/base/adapted_video_track_source.h>
#include <stddef.h>
#include <memory>
#include <vector>

#include <api/scoped_refptr.h>
#include <media/base/adapted_video_track_source.h>
#include <media/base/video_adapter.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/ref_counted_object.h>
#include <rtc_base/timestamp_aligner.h>

RTC_FWD_DECL_OBJC_CLASS(AVCaptureDevice);
RTC_FWD_DECL_OBJC_CLASS(RTCCameraVideoCapturer);
RTC_FWD_DECL_OBJC_CLASS(RTCVideoSourceAdapter);

class MacCapturer : public rtc::AdaptedVideoTrackSource, public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  static rtc::scoped_refptr<MacCapturer> Create(
      size_t width,
      size_t height,
      size_t target_fps,
      const std::string& specifiedVideoDevice);
  MacCapturer(size_t width,
              size_t height,
              size_t target_fps,
              AVCaptureDevice* device);
  virtual ~MacCapturer();

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

 private:
  void Destroy();

  static AVCaptureDevice* FindVideoDevice(
      const std::string& specifiedVideoDevice);

  RTCCameraVideoCapturer* capturer_;
  RTCVideoSourceAdapter* adapter_;
};

#endif  // MAC_CAPTURER_H_