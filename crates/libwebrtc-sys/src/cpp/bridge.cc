#include <cstdint>
#include <memory>
#include <string>

#include <winsock2.h>
#include <windows.h>
#include <dbt.h>
#include <strsafe.h>

#include "modules/audio_device/include/audio_device_factory.h"

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

/// Returns index of `Audio Device` in `ADM` by entered `Audio Device ID`.
uint32_t get_audio_device_index(const AudioDeviceModule& audio_device_module,
  rust::String& device) {
  uint32_t num_devices = audio_device_module.ptr()->RecordingDevices();

  if (device.empty() && num_devices > 0)
    return 0;

  for (uint32_t i = 0; i < num_devices; ++i) {
    const uint32_t kSize = 256;
    char name[kSize] = { 0 };
    char id[kSize] = { 0 };

    if (audio_device_module.ptr()->RecordingDeviceName(i, name, id) != -1) {
      if (std::string(id) == std::string(device)) {
        return i;
      }
    }
  }
  return -1;
}

/// Calls `AudioDeviceModule->SetRecordingDevice()` with the provided arguments.
int32_t set_audio_recording_device(const AudioDeviceModule& audio_device_module,
  uint16_t index) {
  return audio_device_module.ptr()->SetRecordingDevice(index);
}

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

/// Calls `CreatePeerConnectionFactory()`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
  Thread& worker_thread,
  Thread& signaling_thread) {
  auto factory = webrtc::CreatePeerConnectionFactory(
    &worker_thread, &worker_thread, &signaling_thread, nullptr,
    webrtc::CreateBuiltinAudioEncoderFactory(),
    webrtc::CreateBuiltinAudioDecoderFactory(),
    webrtc::CreateBuiltinVideoEncoderFactory(),
    webrtc::CreateBuiltinVideoDecoderFactory(), nullptr, nullptr);

  if (factory == nullptr) {
    return nullptr;
  }

  return std::make_unique<PeerConnectionFactoryInterface>(factory);
}

/// Calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_video_source(
  Thread& worker_thread,
  Thread& signaling_thread,
  size_t width,
  size_t height,
  size_t fps,
  uint32_t device) {
  auto src = webrtc::CreateVideoTrackSourceProxy(
    &signaling_thread, &worker_thread,
    DeviceVideoCapturer::Create(width, height, fps, device));

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(src);
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioSource()`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
  const PeerConnectionFactoryInterface& peer_connection_factory) {
  auto src = peer_connection_factory->CreateAudioSource(
    cricket::AudioOptions());

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioSourceInterface>(src);
}

/// Calls `PeerConnectionFactoryInterface->CreateVideoTrack`.
std::unique_ptr<VideoTrackInterface> create_video_track(
  const PeerConnectionFactoryInterface& peer_connection_factory,
  rust::String id,
  const VideoTrackSourceInterface& video_source) {
  auto track = peer_connection_factory->CreateVideoTrack(
    std::string(id), video_source.ptr());

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackInterface>(track);
}

/// Calls `PeerConnectionFactoryInterface->CreateAudioTrack`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
  const PeerConnectionFactoryInterface& peer_connection_factory,
  rust::String id,
  const AudioSourceInterface& audio_source) {
  auto track = peer_connection_factory->CreateAudioTrack(
    std::string(id), audio_source.ptr());

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioTrackInterface>(track);
}

/// Calls `MediaStreamInterface->CreateLocalMediaStream`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
  const PeerConnectionFactoryInterface& peer_connection_factory,
  rust::String id) {
  auto
    stream = peer_connection_factory->CreateLocalMediaStream(std::string(id));

  if (stream == nullptr) {
    return nullptr;
  }

  return std::make_unique<MediaStreamInterface>(stream);
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

LRESULT CALLBACK DWProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
  LRESULT result = 0;

  if (msg == WM_CLOSE) {
    exit(0);
  } else if (msg == WM_DEVICECHANGE) {
    if (DBT_DEVICEARRIVAL == wp) {
      printf("pupa\n");
    } else if (DBT_DEVICEREMOVECOMPLETE == wp) {
      printf("lupa\n");
    } else if (DBT_DEVNODES_CHANGED == wp) {
      printf("zupa\n");
    }
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
  CustomNotifier asd;

  system("PAUSE");
  // while (true);

  // const wchar_t winClass[] = L"MyNotifyWindow";
  // const wchar_t winTitle[] = L"WindowTitle";

  // WNDCLASSEXW wcex = { sizeof(WNDCLASSEX) };
  // wcex.lpfnWndProc = DWProc;
  // wcex.lpszClassName = L"MyNotifyWindow";
  // ATOM wnd_class_ = RegisterClassExW(&wcex);

  // HINSTANCE hInstance = GetModuleHandle(NULL);
  // HWND hwnd = CreateWindowW(winClass, winTitle, WS_ICONIC, 0, 0,
  //   CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);
  // ShowWindow(hwnd, SW_HIDE);

  // DEV_BROADCAST_DEVICEINTERFACE NotificationFilter;
  // ZeroMemory(&NotificationFilter, sizeof(NotificationFilter));

  // NotificationFilter.dbcc_size = sizeof(NotificationFilter);
  // NotificationFilter.dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE;
  // NotificationFilter.dbcc_reserved = 0;

  // HDEVNOTIFY hDevNotify = RegisterDeviceNotification(hwnd, &NotificationFilter, DEVICE_NOTIFY_SERVICE_HANDLE);

  // MSG Msg;

  // while (GetMessage(&Msg, NULL, 0, 0) > 0) {
  //   TranslateMessage(&Msg);
  //   DispatchMessage(&Msg);
  // }
}

}  // namespace bridge
