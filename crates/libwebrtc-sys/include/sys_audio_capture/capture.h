#ifndef SYS_AUDIO_CAPTURE_CAPTURE_H
#define SYS_AUDIO_CAPTURE_CAPTURE_H

#if defined(WEBRTC_MAC)
#include "mac_capture.h"
#elif defined(WEBRTC_WIN)
#include "win_capture.h"
#endif
#if defined(WEBRTC_LINUX)
#endif

inline std::unique_ptr<AudioRecorder> CreateDefaultSysAudioSource() {
#if defined(WEBRTC_WIN)
  auto recorder = std::make_unique<SysAudioSource>();

  if (!recorder->StartCapture()) {
    return nullptr;
  }

  return recorder;
#elif defined(WEBRTC_LINUX)
  // TODO: Implement for Linux.
  return nullptr;
#elif defined(WEBRTC_MAC)
  if (!IsSysAudioCaptureAvailable()) {
    return nullptr;
  }

  auto recorder = std::make_unique<SysAudioSource>();
  if (!recorder->StartCapture()) {
    return nullptr;
  }
  return recorder;
#else
  static_assert(false, "unknown platform");
#endif
}

#endif  // SYS_AUDIO_CAPTURE_CAPTURE_H
