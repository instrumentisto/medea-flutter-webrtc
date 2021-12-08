#include <cstdint>
#include <memory>
#include <string>

#include "examples/peerconnection/client/main_wnd.h"
#include "libwebrtc-sys/include/bridge.h"

namespace WEBRTC {
std::unique_ptr<webrtc::TaskQueueFactory> create_default_task_queue_factory() {
  return webrtc::CreateDefaultTaskQueueFactory();
}

std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    std::unique_ptr<webrtc::TaskQueueFactory> task_queue_factory) {
  rtc::scoped_refptr<webrtc::AudioDeviceModule> adm =
      webrtc::AudioDeviceModule::Create(
          webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio,
          task_queue_factory.get());

  return std::make_unique<AudioDeviceModule>(adm);
};

void init_audio_device_module(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  audio_device_module.get()->getptr()->Init();
};

int16_t playout_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  return audio_device_module.get()->getptr()->PlayoutDevices();
};

int16_t recording_devices(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module) {
  return audio_device_module.get()->getptr()->RecordingDevices();
};

rust::Vec<rust::String> get_playout_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->PlayoutDeviceName(index, strNameUTF8,
                                                         strGuidUTF8);

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

rust::Vec<rust::String> get_recording_audio_info(
    const std::unique_ptr<AudioDeviceModule>& audio_device_module,
    int16_t index) {
  char strNameUTF8[128];
  char strGuidUTF8[128];

  audio_device_module.get()->getptr()->RecordingDeviceName(index, strNameUTF8,
                                                           strGuidUTF8);

  rust::String strname = strNameUTF8;
  rust::String strid = strGuidUTF8;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>
create_video_device_info() {
  std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> unq_ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return unq_ptr;
};

uint32_t number_of_video_devices(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>&
        device_info) {
  return device_info.get()->NumberOfDevices();
};

rust::Vec<rust::String> get_video_device_name(
    const std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo>& device_info,
    uint32_t index) {
  char device_name[256];
  char unique_id[256];

  device_info.get()->GetDeviceName(index, device_name, 256, unique_id, 256);

  rust::String strname = device_name;
  rust::String strid = unique_id;

  rust::Vec<rust::String> info = {strname, strid};
  return info;
};

std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

void start_thread(const std::unique_ptr<rtc::Thread>& thread) {
  thread.get()->Start();
}

std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread) {
  return std::make_unique<PeerConnectionFactoryInterface>(
      webrtc::CreatePeerConnectionFactory(
          worker_thread.get(), worker_thread.get(), signaling_thread.get(),
          nullptr, webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr));
}

std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    const std::unique_ptr<rtc::Thread>& worker_thread,
    const std::unique_ptr<rtc::Thread>& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  return std::make_unique<VideoTrackSourceInterface>(
      webrtc::CreateVideoTrackSourceProxy(
          signaling_thread.get(), worker_thread.get(),
          DeviceVideoCapturer::Create(width, height, fps, 0)));
}

std::unique_ptr<AudioSourceInterface> create_audio_source(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory) {
  return std::make_unique<AudioSourceInterface>(
      peer_connection_factory.get()->getptr()->CreateAudioSource(
          cricket::AudioOptions()));
}

std::unique_ptr<VideoTrackInterface> create_video_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<VideoTrackSourceInterface>& video_source) {
  return std::make_unique<VideoTrackInterface>(
      peer_connection_factory.get()->getptr()->CreateVideoTrack(
          "video_track", video_source.get()->getptr()));
}

std::unique_ptr<AudioTrackInterface> create_audio_track(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory,
    const std::unique_ptr<AudioSourceInterface>& audio_source) {
  return std::make_unique<AudioTrackInterface>(
      peer_connection_factory.get()->getptr()->CreateAudioTrack(
          "audio_track", audio_source.get()->getptr()));
}

std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const std::unique_ptr<PeerConnectionFactoryInterface>&
        peer_connection_factory) {
  return std::make_unique<MediaStreamInterface>(
      peer_connection_factory.get()->getptr()->CreateLocalMediaStream(
          "local_stream"));
}

bool add_video_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<VideoTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool add_audio_track(const std::unique_ptr<MediaStreamInterface>& media_stream,
                     const std::unique_ptr<AudioTrackInterface>& track) {
  return media_stream.get()->getptr()->AddTrack(track.get()->getptr());
}

bool remove_video_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<VideoTrackInterface>& track) {
  return media_stream.get()->getptr()->RemoveTrack(track.get()->getptr());
}

bool remove_audio_track(
    const std::unique_ptr<MediaStreamInterface>& media_stream,
    const std::unique_ptr<AudioTrackInterface>& track) {
  return media_stream.get()->getptr()->RemoveTrack(track.get()->getptr());
}

void test() {
  class VideoRenderer : public rtc::VideoSinkInterface<webrtc::VideoFrame> {
   public:
    VideoRenderer(HWND wnd,
                  int width,
                  int height,
                  webrtc::VideoTrackInterface* track_to_render);
    virtual ~VideoRenderer();

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
    rtc::scoped_refptr<webrtc::VideoTrackInterface> rendered_track_;
  };

  // VideoRenderer::VideoRenderer(HWND wnd, int width, int height,
  //                              webrtc::VideoTrackInterface* track_to_render)
  //     : wnd_(wnd), rendered_track_(track_to_render) {
  //   ZeroMemory(&bmi_, sizeof(bmi_));
  //   bmi_.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
  //   bmi_.bmiHeader.biPlanes = 1;
  //   bmi_.bmiHeader.biBitCount = 32;
  //   bmi_.bmiHeader.biCompression = BI_RGB;
  //   bmi_.bmiHeader.biWidth = width;
  //   bmi_.bmiHeader.biHeight = -height;
  //   bmi_.bmiHeader.biSizeImage =
  //       width * height * (bmi_.bmiHeader.biBitCount >> 3);
  //   rendered_track_->AddOrUpdateSink(this, rtc::VideoSinkWants());
  // }

  // VideoRenderer::~VideoRenderer() { rendered_track_->RemoveSink(this); }

  // void VideoRenderer::SetSize(int width, int height) {
  //   if (width == bmi_.bmiHeader.biWidth && height == bmi_.bmiHeader.biHeight)
  //   {
  //     return;
  //   }

  //   bmi_.bmiHeader.biWidth = width;
  //   bmi_.bmiHeader.biHeight = -height;
  //   bmi_.bmiHeader.biSizeImage =
  //       width * height * (bmi_.bmiHeader.biBitCount >> 3);
  //   image_.reset(new uint8_t[bmi_.bmiHeader.biSizeImage]);
  // }

  // void VideoRenderer::OnFrame(const webrtc::VideoFrame& video_frame) {
  //   {
  //     rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
  //         video_frame.video_frame_buffer()->ToI420());
  //     if (video_frame.rotation() != webrtc::kVideoRotation_0) {
  //       buffer = webrtc::I420Buffer::Rotate(*buffer, video_frame.rotation());
  //     }

  //     SetSize(buffer->width(), buffer->height());

  //     RTC_DCHECK(image_.get() != NULL);
  //     libyuv::I420ToARGB(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
  //                        buffer->StrideU(), buffer->DataV(),
  //                        buffer->StrideV(), image_.get(),
  //                        bmi_.bmiHeader.biWidth * bmi_.bmiHeader.biBitCount /
  //                        8, buffer->width(), buffer->height());
  //   }
  //   InvalidateRect(wnd_, NULL, TRUE);
  // }

  auto worker = create_thread();
  worker.get()->Start();

  auto signal = create_thread();
  signal.get()->Start();
  auto pcf = create_peer_connection_factory(worker, signal);

  auto a = create_video_source(worker, signal, 640, 380, 30);
  auto b = create_video_track(pcf, a);

  system("PAUSE");
}

}  // namespace WEBRTC
