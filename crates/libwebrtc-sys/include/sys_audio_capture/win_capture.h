#ifndef SYS_AUDIO_CAPTURE_WIN_CAPTURE_H
#define SYS_AUDIO_CAPTURE_WIN_CAPTURE_H

#define WIN32_LEAN_AND_MEAN

#include <mutex>
#include <vector>

#include <audioclient.h>
#include <audioclientactivationparams.h>
#include <mfapi.h>
#include <mmdeviceapi.h>
#include <windows.h>
#include <wrl/implements.h>

#include <third_party/wil/com.h>
#include <third_party/wil/result.h>

#include "libwebrtc-sys/include/audio_recorder.h"

using namespace Microsoft::WRL;

class AudioClientActivationHandler final
    : public RuntimeClass<RuntimeClassFlags<ClassicCom>,
                          FtmBase,
                          IActivateAudioInterfaceCompletionHandler> {
 public:
  HRESULT ActivateCompleted(
      IActivateAudioInterfaceAsyncOperation* activateOperation) override;

  // Result of the activation attempt. Set by ActivateCompleted().
  // Defaults to E_UNEXPECTED until activation completes.
  HRESULT activate_result = E_UNEXPECTED;

  // Event that is signaled when activation completes.
  wil::unique_event_nothrow activate_completed;

  // The activated `IAudioClient` interface. Set only if activation succeeded.
  wil::com_ptr_nothrow<IAudioClient> audio_client;

  // Used to poll data from the `audio_client`.
  wil::com_ptr_nothrow<IAudioCaptureClient> capture_client;
};

class SysAudioSource final : public AudioRecorder {
 public:
  SysAudioSource();

  // Captures a new batch of audio samples and propagates it to the inner
  // `bridge::LocalAudioSource`.
  bool ProcessRecordedPart(bool firstInCycle) override;

  // Stops audio capture freeing the captured device.
  void StopCapture() override;

  // Starts recording audio from the captured device.
  bool StartCapture() override;

  // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
  // writes the recorded audio to.
  webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() override;

 private:
  std::recursive_mutex mutex_;

  bool recording_ = false;
  bool recording_failed_ = false;

  webrtc::scoped_refptr<bridge::LocalAudioSource> source_;

  std::vector<int16_t> recorded_samples_;

  wil::com_ptr_nothrow<AudioClientActivationHandler>
      audio_client_activation_handler_;
};

#endif  // SYS_AUDIO_CAPTURE_WIN_CAPTURE_H
