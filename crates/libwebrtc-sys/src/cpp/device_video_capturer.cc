#include "device_video_capturer.h"
#include "modules/video_capture/video_capture_factory.h"
#include "rtc_base/logging.h"
#include "video_capture_mac.h"
#include "device_info_mac.h"
#include <iostream>

// MediaCodec wants resolution to be divisible by 2.
const int kRequiredResolutionAlignment = 2;

DeviceVideoCapturer::DeviceVideoCapturer()
    : AdaptedVideoTrackSource(kRequiredResolutionAlignment) {}

DeviceVideoCapturer::~DeviceVideoCapturer() {
  Destroy();
}

// Creates a new `DeviceVideoCapturer`.
rtc::scoped_refptr<DeviceVideoCapturer> DeviceVideoCapturer::Create(
    size_t width,
    size_t height,
    size_t max_fps,
    uint32_t device_index) {
    std::cout << "DeviceVideoCapturer::Create 1\n" << std::flush;
  rtc::scoped_refptr<DeviceVideoCapturer> capturer(
      new rtc::RefCountedObject<DeviceVideoCapturer>());
    std::cout << "DeviceVideoCapturer::Create 2\n" << std::flush;

  if (!capturer->Init(width, height, max_fps, device_index)) {
      std::cout << "DeviceVideoCapturer::Create 3\n" << std::flush;
    RTC_LOG(LS_ERROR) << "Failed to create DeviceVideoCapturer(w = " << width
                      << ", h = " << height << ", fps = " << max_fps << ")";
    return nullptr;
  }
    std::cout << "DeviceVideoCapturer::Create 4\n" << std::flush;

    return capturer;
}

// Initializes current `DeviceVideoCapturer`.
//
// Creates an underlying `VideoCaptureModule` and starts capturing media with
// specified constraints.
bool DeviceVideoCapturer::Init(size_t width,
                               size_t height,
                               size_t max_fps,
                               size_t capture_device_index) {
    std::cout << "DeviceVideoCapturer::Init 1\n";
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> device_info = create_device_info_mac();
    std::cout << "DeviceVideoCapturer::Init 2\n" << std::flush;

  char device_name[256];
  char unique_name[256];
    if (device_info->GetDeviceName(static_cast<uint32_t>(capture_device_index),
                                 device_name, sizeof(device_name), unique_name,
                                 sizeof(unique_name)) != 0) {
    Destroy();
    return false;
  }
    std::cout << "DeviceVideoCapturer::Init 3\n" << std::flush;

    vcm_ = create_video_capture_mac(unique_name);
    std::cout << "DeviceVideoCapturer::Init 4\n" << std::flush;
  if (!vcm_) {
      std::cout << "DeviceVideoCapturer::Init 5\n" << std::flush;
    return false;
  }
  vcm_->RegisterCaptureDataCallback(this);
    std::cout << "DeviceVideoCapturer::Init 6\n" << std::flush;

    device_info->GetCapability(vcm_->CurrentDeviceName(), 0, capability_);
    std::cout << "DeviceVideoCapturer::Init 7\n" << std::flush;
  capability_.width = static_cast<int32_t>(width);
  capability_.height = static_cast<int32_t>(height);
  capability_.maxFPS = static_cast<int32_t>(max_fps);
  capability_.videoType = webrtc::VideoType::kI420;
    std::cout << "DeviceVideoCapturer::Init 8\n" << std::flush;

  if (vcm_->StartCapture(capability_) != 0) {
      std::cout << "DeviceVideoCapturer::Init 9\n" << std::flush;
    Destroy();
    return false;
  }
    std::cout << "DeviceVideoCapturer::Init 10\n" << std::flush;

    RTC_CHECK(vcm_->CaptureStarted());

    std::cout << "DeviceVideoCapturer::Init 11\n" << std::flush;
  return true;
}

// Frees an underlying `VideoCaptureModule`.
void DeviceVideoCapturer::Destroy() {
  if (!vcm_)
    return;

  vcm_->StopCapture();
  vcm_->DeRegisterCaptureDataCallback();
  vcm_ = nullptr;
}

// Propagates a `VideoFrame` to the `AdaptedVideoTrackSource::OnFrame()`.
void DeviceVideoCapturer::OnFrame(const webrtc::VideoFrame& frame) {
  AdaptedVideoTrackSource::OnFrame(frame);
}

// Returns `false`.
bool DeviceVideoCapturer::is_screencast() const {
  return false;
}

// Returns `false`.
absl::optional<bool> DeviceVideoCapturer::needs_denoising() const {
  return false;
}

// Returns `SourceState::kLive`.
webrtc::MediaSourceInterface::SourceState DeviceVideoCapturer::state() const {
  return SourceState::kLive;
}

// Returns `false`.
bool DeviceVideoCapturer::remote() const {
  return false;
}
