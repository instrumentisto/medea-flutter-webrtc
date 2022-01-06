#include <chrono>
#include <cstdint>
#include <memory>
#include <string>

#include <modules/desktop_capture/cropped_desktop_frame.h>
#include <modules/desktop_capture/desktop_and_cursor_composer.h>
#include <modules/desktop_capture/desktop_capture_options.h>
#include "libwebrtc-sys/include/bridge.h"

namespace bridge {

// Calls `AudioDeviceModule->Create()`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory& task_queue_factory) {
  auto adm =
      webrtc::AudioDeviceModule::Create(audio_layer, &task_queue_factory);

  if (adm == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioDeviceModule>(adm);
};

// Calls `AudioDeviceModule->Init()`.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->Init();
}

// Calls `AudioDeviceModule->PlayoutDevices()`.
int16_t playout_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->PlayoutDevices();
};

// Calls `AudioDeviceModule->RecordingDevices()`.
int16_t recording_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->RecordingDevices();
};

// Calls `AudioDeviceModule->PlayoutDeviceName()` with the provided arguments.
int32_t playout_device_name(const AudioDeviceModule& audio_device_module,
                            int16_t index,
                            rust::String& name,
                            rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->PlayoutDeviceName(index, name_buff, guid_buff);
  name = name_buff;
  guid = guid_buff;

  return result;
};

// Calls `AudioDeviceModule->RecordingDeviceName()` with the provided arguments.
int32_t recording_device_name(const AudioDeviceModule& audio_device_module,
                              int16_t index,
                              rust::String& name,
                              rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->RecordingDeviceName(index, name_buff, guid_buff);

  name = name_buff;
  guid = guid_buff;

  return result;
};

// Calls `VideoCaptureFactory->CreateDeviceInfo()`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
};

// Calls `VideoDeviceInfo->GetDeviceName()` with the provided arguments.
int32_t video_device_name(VideoDeviceInfo& device_info,
                          uint32_t index,
                          rust::String& name,
                          rust::String& guid) {
  char name_buff[256];
  char guid_buff[256];

  const int32_t size =
      device_info.GetDeviceName(index, name_buff, 256, guid_buff, 256);

  name = name_buff;
  guid = guid_buff;

  return size;
};

/// Calls `Thread->Create()`.
std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

/// Calls `Thread->Start()`.
bool start_thread(Thread& thread) {
  return thread.Start();
}

/// Calls `CreatePeerConnectionFactory()`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    Thread& worker_thread,
    Thread& signaling_thread) {
  return std::make_unique<PeerConnectionFactoryInterface>(
      webrtc::CreatePeerConnectionFactory(
          &worker_thread, &worker_thread, &signaling_thread, nullptr,
          webrtc::CreateBuiltinAudioEncoderFactory(),
          webrtc::CreateBuiltinAudioDecoderFactory(),
          webrtc::CreateBuiltinVideoEncoderFactory(),
          webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr));
}

/// Calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  return std::make_unique<VideoTrackSourceInterface>(
      webrtc::CreateVideoTrackSourceProxy(
          &signaling_thread, &worker_thread,
          DeviceVideoCapturer::Create(width, height, fps, 0)));
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioSource()`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  return std::make_unique<AudioSourceInterface>(
      peer_connection_factory->CreateAudioSource(cricket::AudioOptions()));
}

/// Calls `PeerConnectionFactoryInterface->CreateVideoTrack`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    const VideoTrackSourceInterface& video_source) {
  return std::make_unique<VideoTrackInterface>(
      peer_connection_factory->CreateVideoTrack("video_track",
                                                video_source.ptr()));
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioTrack`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    const AudioSourceInterface& audio_source) {
  return std::make_unique<AudioTrackInterface>(
      peer_connection_factory->CreateAudioTrack("audio_track",
                                                audio_source.ptr()));
}

/// Calls `MediaStreamInterface->CreateLocalMediaStream`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  return std::make_unique<MediaStreamInterface>(
      peer_connection_factory->CreateLocalMediaStream("local_stream"));
}

/// Calls `MediaStreamInterface->AddTrack`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track) {
  return media_stream->AddTrack(track.ptr());
}

/// Calls `MediaStreamInterface->AddTrack`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track) {
  return media_stream->AddTrack(track.ptr());
}

/// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track) {
  return media_stream->RemoveTrack(track.ptr());
}

/// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track) {
  return media_stream->RemoveTrack(track.ptr());
}

int32_t frame_width(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->width();
}

int32_t frame_height(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->height();
}

int32_t frame_rotation(const std::unique_ptr<VideoFrame>& frame) {
  return frame.get()->rotation();
}

std::unique_ptr<std::vector<uint8_t>> convert_to_argb(
    const std::unique_ptr<VideoFrame>& frame,
    const int32_t buffer_size) {
  auto video_frame = frame.get();
  // rust::Vec<uint8_t> image;

  printf(
      "Frame '%d' before creating std::vector<uint8_t> with `0` at: "
      "%d "
      "(libWebRTC)\n",
      frame.get()->id(),
      std::chrono::duration_cast<std::chrono::milliseconds>(
          std::chrono::system_clock::now().time_since_epoch())
          .count());

  std::vector<uint8_t> image(buffer_size, 0);
  // image.reserve(buffer_size);
  // std::fill(image.cbegin(), image.cend(), 0);

  // for (int i = 0; i < buffer_size; i++) {
  //   image.emplace_back((uint8_t)0);
  // }

  printf(
      "Frame '%d' after creating std::vector<uint8_t> with `0` at: "
      "%d "
      "(libWebRTC)\n",
      frame.get()->id(),
      std::chrono::duration_cast<std::chrono::milliseconds>(
          std::chrono::system_clock::now().time_since_epoch())
          .count());

  rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
      video_frame->video_frame_buffer()->ToI420());
  if (video_frame->rotation() != webrtc::kVideoRotation_0) {
    buffer = webrtc::I420Buffer::Rotate(*buffer, video_frame->rotation());
  }

  printf("Frame '%d' before converting to ABGR at: %d (libWebRTC)\n",
         frame.get()->id(),
         std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
             .count());

  libyuv::I420ToABGR(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
                     buffer->StrideU(), buffer->DataV(), buffer->StrideV(),
                     image.data(), video_frame->width() * 32 / 8,
                     buffer->width(), buffer->height());

  printf("Frame '%d' after converting to ABGR at: %d (libWebRTC)\n",
         frame.get()->id(),
         std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
             .count());

  return std::make_unique<std::vector<uint8_t>>(image);
}

/// testasdsassads
std::unique_ptr<VideoRenderer> get_video_renderer(
    rust::Fn<void(std::unique_ptr<VideoFrame>, size_t, uint16_t)> cb,
    size_t flutter_cb_ptr,
    const std::unique_ptr<VideoTrackInterface>& track_to_render) {
  return std::make_unique<VideoRenderer>(cb, flutter_cb_ptr,
                                         track_to_render.get()->ptr());
}

void set_renderer_no_track(
    const std::unique_ptr<VideoRenderer>& video_renderer) {
  video_renderer.get()->SetNoTrack();
}

/// Calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_screen_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  webrtc::DesktopCapturer::SourceList sourceList;
  ScreenVideoCapturer::GetSourceList(&sourceList);
  rtc::scoped_refptr<ScreenVideoCapturer> capturer(
      new rtc::RefCountedObject<ScreenVideoCapturer>(sourceList[0].id, width,
                                                     height, fps));

  return std::make_unique<VideoTrackSourceInterface>(
      webrtc::CreateVideoTrackSourceProxy(&signaling_thread, &worker_thread,
                                          capturer));
}

NativeVideoRenderer* c;

#define RAND_MAX 255

template <typename T>
class AutoLock {
 public:
  explicit AutoLock(T* obj) : obj_(obj) { obj_->Lock(); }
  ~AutoLock() { obj_->Unlock(); }

 protected:
  T* obj_;
};

LRESULT CALLBACK DWProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  LRESULT result = 0;

  if (msg == WM_PAINT) {
    PAINTSTRUCT ps;
    ::BeginPaint(hwnd, &ps);

    RECT rc;
    ::GetClientRect(hwnd, &rc);

    HDC dc_mem = ::CreateCompatibleDC(ps.hdc);
    ::SetStretchBltMode(dc_mem, HALFTONE);

    HDC all_dc[] = {ps.hdc, dc_mem};

    if (c == nullptr) {
      printf("no img\n");
      return LRESULT(0);
    }

    AutoLock<NativeVideoRenderer> local_lock(c);
    const BITMAPINFO& bmi = c->bmi();
    int height = abs(bmi.bmiHeader.biHeight);
    int width = bmi.bmiHeader.biWidth;

    const uint8_t* image = c->image();
    if (image != NULL) {
      HDC dc_mem = ::CreateCompatibleDC(ps.hdc);
      ::SetStretchBltMode(dc_mem, HALFTONE);

      HDC all_dc[] = {ps.hdc, dc_mem};
      for (size_t i = 0; i < arraysize(all_dc); ++i) {
        SetMapMode(all_dc[i], MM_ISOTROPIC);
        SetWindowExtEx(all_dc[i], width, height, NULL);
        SetViewportExtEx(all_dc[i], rc.right, rc.bottom, NULL);
      }

      HBITMAP bmp_mem = ::CreateCompatibleBitmap(ps.hdc, rc.right, rc.bottom);
      HGDIOBJ bmp_old = ::SelectObject(dc_mem, bmp_mem);

      POINT logical_area = {rc.right, rc.bottom};
      DPtoLP(ps.hdc, &logical_area, 1);

      HBRUSH brush = ::CreateSolidBrush(RGB(0, 0, 0));
      RECT logical_rect = {0, 0, logical_area.x, logical_area.y};
      ::FillRect(dc_mem, &logical_rect, brush);
      ::DeleteObject(brush);

      int x = (logical_area.x / 2) - (width / 2);
      int y = (logical_area.y / 2) - (height / 2);

      StretchDIBits(dc_mem, x, y, width, height, 0, 0, width, height, image,
                    &bmi, DIB_RGB_COLORS, SRCCOPY);

      BitBlt(ps.hdc, 0, 0, logical_area.x, logical_area.y, dc_mem, 0, 0,
             SRCCOPY);

      // Cleanup.
      ::SelectObject(dc_mem, bmp_old);
      ::DeleteObject(bmp_mem);
      ::DeleteDC(dc_mem);
    }

    // HBRUSH brush =
    //     ::CreateSolidBrush(RGB(std::rand(), std::rand(), std::rand()));
    // ::FillRect(ps.hdc, &rc, brush);
    // ::DeleteObject(brush);

    ::EndPaint(hwnd, &ps);
  } else if (msg == WM_CLOSE) {
    exit(0);
  } else if (msg == WM_ERASEBKGND) {
  } else if (msg == WM_SETFOCUS) {
  } else if (msg == WM_SIZE) {
  } else if (msg == WM_CTLCOLORSTATIC) {
  } else if (msg == WM_COMMAND) {
  } else {
    result = DefWindowProc(hwnd, msg, wp, lp);
  }

  return result;
}

void test() {
  auto work = rtc::Thread::Create();
  work.get()->Start();

  auto signal = rtc::Thread::Create();
  signal.get()->Start();

  auto pcf = webrtc::CreatePeerConnectionFactory(
      work.get(), work.get(), signal.get(), nullptr,
      webrtc::CreateBuiltinAudioEncoderFactory(),
      webrtc::CreateBuiltinAudioDecoderFactory(),
      webrtc::CreateBuiltinVideoEncoderFactory(),
      webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr);

  webrtc::DesktopCapturer::SourceList sourceList;
  ScreenVideoCapturer::GetSourceList(&sourceList);
  std::unique_ptr<ScreenVideoCapturer> capturer(
      new rtc::RefCountedObject<ScreenVideoCapturer>(sourceList[0].id, 1920,
                                                     1260, 30));

  // auto a = DeviceVideoCapturer::Create(640, 480, 30, 0);

  auto asd = pcf.get()->CreateVideoTrack(
      "asd", webrtc::CreateVideoTrackSourceProxy(signal.get(), work.get(),
                                                 capturer.get()));

  WNDCLASSEXW wcex = {sizeof(WNDCLASSEX)};
  wcex.style = CS_DBLCLKS;
  wcex.hInstance = GetModuleHandle(NULL);
  // wcex.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
  wcex.hCursor = ::LoadCursor(NULL, IDC_ARROW);
  // wcex.lpfnWndProc = DefWindowProc;
  wcex.lpfnWndProc = DWProc;
  wcex.lpszClassName = L"Test_Class";
  wcex.hbrBackground = CreateSolidBrush(RGB(0, 0, 0));
  ATOM wnd_class_ = ::RegisterClassExW(&wcex);

  HWND wnd =
      CreateWindowExW(WS_EX_OVERLAPPEDWINDOW, L"Test_Class", L"Test",
                      WS_OVERLAPPEDWINDOW | WS_VISIBLE | WS_CLIPCHILDREN,
                      CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
                      CW_USEDEFAULT, NULL, NULL, GetModuleHandle(NULL), NULL);

  c = new NativeVideoRenderer(wnd, 1920, 1260, asd.get());

  ShowWindow(wnd, SW_SHOWNORMAL);
  UpdateWindow(wnd);

  DWORD d = GetLastError();
  printf("bridge %d\n", d);

  MSG Msg;

  while (GetMessage(&Msg, NULL, 0, 0) > 0) {
    TranslateMessage(&Msg);
    DispatchMessage(&Msg);
  }
}

}  // namespace bridge
