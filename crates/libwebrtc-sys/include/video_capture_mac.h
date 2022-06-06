#pragma once

#include "modules/video_capture/video_capture_impl.h"
#include "modules/video_capture/video_capture_defines.h"
#include <functional>
#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/task_queue/default_task_queue_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"
#include "api/video_track_source_proxy_factory.h"
#include "device_video_capturer.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "pc/audio_track.h"
#include "pc/local_audio_source.h"
#include "pc/video_track_source.h"
#include "peer_connection.h"
#include "rust/cxx.h"
#include "screen_video_capturer.h"
#include "video_sink.h"

#include "adm_proxy.h"

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

class VideoCaptureMac : public webrtc::videocapturemodule::VideoCaptureImpl {
public:
    VideoCaptureMac();
    ~VideoCaptureMac() override;
    int32_t Init(const char* deviceUniqueId);
    int32_t StartCapture(const webrtc::VideoCaptureCapability& capability) override;
    int32_t StopCapture() override;
    bool CaptureStarted() override;
    int32_t CaptureSettings(webrtc::VideoCaptureCapability& settings) override;
private:
    AVCaptureDevice *device;
};
#endif

rtc::scoped_refptr<webrtc::VideoCaptureModule> create_video_capture_mac(const char* deviceUniqueId);
rtc::scoped_refptr<webrtc::VideoTrackSourceInterface> create_video_track_source(
        rtc::Thread& worker_thread,
        rtc::Thread& signaling_thread,
        size_t width,
        size_t height,
        size_t fps,
        uint32_t device
);
