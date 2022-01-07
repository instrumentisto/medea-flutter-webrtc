#include "device_video_capturer.h"
#include <modules/video_capture/video_capture_factory.h>
#include <rtc_base/checks.h>
#include <rtc_base/logging.h>
#include <stdint.h>
#include <memory>

DeviceVideoCapturer::DeviceVideoCapturer()
    : AdaptedVideoTrackSource(4), vcm_(nullptr) {}

DeviceVideoCapturer::~DeviceVideoCapturer() {
  Destroy();
}

bool DeviceVideoCapturer::Init(size_t width,
                               size_t height,
                               size_t target_fps,
                               size_t capture_device_index) {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> device_info(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  char device_name[256];
  char unique_name[256];
  if (device_info->GetDeviceName(static_cast<uint32_t>(capture_device_index),
                                 device_name, sizeof(device_name), unique_name,
                                 sizeof(unique_name)) != 0) {
    Destroy();
    return false;
  }

  vcm_ = webrtc::VideoCaptureFactory::Create(unique_name);
  if (!vcm_) {
    return false;
  }
  vcm_->RegisterCaptureDataCallback(this);

  device_info->GetCapability(vcm_->CurrentDeviceName(), 0, capability_);

  capability_.width = static_cast<int32_t>(width);
  capability_.height = static_cast<int32_t>(height);
  capability_.maxFPS = static_cast<int32_t>(target_fps);
  capability_.videoType = webrtc::VideoType::kI420;

  if (vcm_->StartCapture(capability_) != 0) {
    Destroy();
    return false;
  }

  RTC_CHECK(vcm_->CaptureStarted());

  return true;
}

rtc::scoped_refptr<DeviceVideoCapturer> DeviceVideoCapturer::Create(
    size_t width,
    size_t height,
    size_t target_fps,
    uint32_t device_index) {
  rtc::scoped_refptr<DeviceVideoCapturer> capturer(
      new rtc::RefCountedObject<DeviceVideoCapturer>());

  if (!capturer->Init(width, height, target_fps, device_index)) {
    RTC_LOG(LS_WARNING) << "Failed to create DeviceVideoCapturer(w = " << width
                        << ", h = " << height << ", fps = " << target_fps
                        << ")";
    return nullptr;
  }

  return capturer;
}

void DeviceVideoCapturer::Destroy() {
  if (!vcm_)
    return;

  vcm_->StopCapture();
  vcm_->DeRegisterCaptureDataCallback();
  vcm_ = nullptr;
}

//void DeviceVideoCapturer::OnFrame(const webrtc::VideoFrame& frame) {
//  OnCapturedFrame(frame);
//}

bool DeviceVideoCapturer::is_screencast() const {
  return false;
}

absl::optional<bool> DeviceVideoCapturer::needs_denoising() const {
  return false;
}

webrtc::MediaSourceInterface::SourceState DeviceVideoCapturer::state()
const {
  return SourceState::kLive;
}

bool DeviceVideoCapturer::remote() const {
  return false;
}

//void DeviceVideoCapturer::OnCapturedFrame(const webrtc::VideoFrame& frame) {
//  const int64_t timestamp_us = frame.timestamp_us();
//  const int64_t translated_timestamp_us =
//      timestamp_aligner_.TranslateTimestamp(timestamp_us, rtc::TimeMicros());
//
//  rtc::scoped_refptr<webrtc::VideoFrameBuffer> buffer =
//      frame.video_frame_buffer();
//
//  OnFrame(webrtc::VideoFrame::Builder()
//              .set_video_frame_buffer(buffer)
//              .set_rotation(frame.rotation())
//              .set_timestamp_us(translated_timestamp_us)
//              .build());
//}
