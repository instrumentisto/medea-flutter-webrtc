#ifndef DEVICE_VIDEO_CAPTURER_H_
#define DEVICE_VIDEO_CAPTURER_H_

#include <memory>
#include <stddef.h>
#include <vector>

#include <api/scoped_refptr.h>
#include <media/base/adapted_video_track_source.h>
#include <media/base/video_adapter.h>
#include <modules/video_capture/video_capture.h>
#include <rtc_base/ref_counted_object.h>
#include <rtc_base/timestamp_aligner.h>

class DeviceVideoCapturer : public rtc::AdaptedVideoTrackSource,
                            public rtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  static rtc::scoped_refptr<DeviceVideoCapturer> Create(
      size_t width,
      size_t height,
      size_t target_fps,
      uint32_t device_index);

  /// Indicates that parameters suitable for screencasts should be automatically
  /// applied to RtpSenders.
  bool is_screencast() const override;

  /// Indicates that the encoder should denoise video before encoding it.
  /// If it is not set, the default configuration is used which is different
  /// depending on video codec.
  absl::optional<bool> needs_denoising() const override;

  /// Returns state of this `DeviceVideoCapturer`.
  webrtc::MediaSourceInterface::SourceState state() const override;

  /// Returns true since `DeviceVideoCapturer` is meant to source local devices.
  bool remote() const override;

 protected:
  DeviceVideoCapturer();
  ~DeviceVideoCapturer();

 private:
  bool Init(size_t width,
            size_t height,
            size_t target_fps,
            size_t capture_device_index);
  void Destroy();

  void OnFrame(const webrtc::VideoFrame& frame) override;

  rtc::scoped_refptr<webrtc::VideoCaptureModule> vcm_;
  webrtc::VideoCaptureCapability capability_;
  rtc::TimestampAligner timestamp_aligner_;
};

#endif
