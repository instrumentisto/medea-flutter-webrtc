#include <cstdint>
#include <memory>
#include <string>

#include "libwebrtc-sys/include/bridge.h"
#include "rtc_base/win32.h"

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

VideoRenderer* c;

#define RAND_MAX 255

LRESULT CALLBACK DWProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  LRESULT result = 0;

  if (msg == WM_PAINT) {
    PAINTSTRUCT ps;
    BeginPaint(hwnd, &ps);

    RECT rc;
    GetClientRect(hwnd, &rc);

    HDC dc_mem = CreateCompatibleDC(ps.hdc);
    SetStretchBltMode(dc_mem, HALFTONE);

    HDC all_dc[] = {ps.hdc, dc_mem};

    if (c == nullptr) {
      printf("no img\n");
      return LRESULT(0);
    }

    const BITMAPINFO& bmi = c->bmi();
    int height = abs(bmi.bmiHeader.biHeight);
    int width = bmi.bmiHeader.biWidth;

    const uint8_t* image = c->image();
    if (image != NULL) {
      HDC dc_mem = ::CreateCompatibleDC(ps.hdc);
      SetStretchBltMode(dc_mem, HALFTONE);

      HDC all_dc[] = {ps.hdc, dc_mem};
      for (size_t i = 0; i < arraysize(all_dc); ++i) {
        SetMapMode(all_dc[i], MM_ISOTROPIC);
        SetWindowExtEx(all_dc[i], width, height, NULL);
        SetViewportExtEx(all_dc[i], rc.right, rc.bottom, NULL);
      }

      HBITMAP bmp_mem = CreateCompatibleBitmap(ps.hdc, rc.right, rc.bottom);
      HGDIOBJ bmp_old = SelectObject(dc_mem, bmp_mem);

      POINT logical_area = {rc.right, rc.bottom};
      DPtoLP(ps.hdc, &logical_area, 1);

      HBRUSH brush = CreateSolidBrush(RGB(0, 0, 0));
      RECT logical_rect = {0, 0, logical_area.x, logical_area.y};
      FillRect(dc_mem, &logical_rect, brush);
      DeleteObject(brush);

      int x = (logical_area.x / 2) - (width / 2);
      int y = (logical_area.y / 2) - (height / 2);

      StretchDIBits(dc_mem, x + width, y, -width, height, 0, 0, width, height,
                    image, &bmi, DIB_RGB_COLORS, SRCCOPY);

      BitBlt(ps.hdc, 0, 0, logical_area.x, logical_area.y, dc_mem, 0, 0,
             SRCCOPY);

      // Cleanup.
      SelectObject(dc_mem, bmp_old);
      DeleteObject(bmp_mem);
      DeleteDC(dc_mem);
    }

    EndPaint(hwnd, &ps);
  } else if (msg == WM_CLOSE) {
    exit(0);
  } else if (msg == WM_ERASEBKGND || msg == WM_SETFOCUS || msg == WM_SIZE ||
             msg == WM_CTLCOLORSTATIC || msg == WM_COMMAND) {
  } else {
    result = DefWindowProc(hwnd, msg, wp, lp);
  }

  return result;
}

void test() {
  auto worker = create_thread();
  worker.get()->Start();

  auto signal = create_thread();
  signal.get()->Start();
  auto pcf = create_peer_connection_factory(worker, signal);

  auto a = create_video_source(worker, signal, 640, 380, 30);
  auto b = create_video_track(pcf, a);

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

  c = new VideoRenderer(wnd, 640, 380, b.get()->getptr());

  ShowWindow(wnd, SW_SHOWNORMAL);
  UpdateWindow(wnd);

  DWORD d = GetLastError();
  printf("bridge %d\n", d);

  MSG Msg;

  while (GetMessage(&Msg, NULL, 0, 0) > 0) {
    TranslateMessage(&Msg);
    DispatchMessage(&Msg);
  }

  // system("PAUSE");
}

}  // namespace WEBRTC
