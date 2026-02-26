#ifndef SYS_AUDIO_CAPTURE_CAPTURE_H
#define SYS_AUDIO_CAPTURE_CAPTURE_H

#if defined(WEBRTC_MAC)
#include "mac_capture.h"
#elif defined(WEBRTC_WIN)
#include "win_capture.h"
#elif defined(WEBRTC_LINUX)
#include "linux_capture.h"
#endif

inline bool SysAudioCaptureIsAvailable() {
#if defined(WEBRTC_WIN)
  return true;
#elif defined(WEBRTC_LINUX)
  // TODO: Support weak-linking pipewire and runtime availability check.
  return true;
#elif defined(WEBRTC_MAC)
  return IsSysAudioCaptureAvailable();
#else
  static_assert(false, "unknown platform");
#endif
}

inline std::unique_ptr<AudioRecorder> CreateDefaultSysAudioSource() {
  if (!SysAudioCaptureIsAvailable()) {
    return nullptr;
  }
  auto recorder = std::make_unique<SysAudioSource>();
  if (!recorder->StartCapture()) {
    return nullptr;
  }
  return recorder;
}

#endif  // SYS_AUDIO_CAPTURE_CAPTURE_H
