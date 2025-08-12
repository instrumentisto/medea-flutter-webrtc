#ifdef WEBRTC_WIN

#ifndef AUDIO_DISPLAY_RECORDER_H
#define AUDIO_DISPLAY_RECORDER_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <audioclientactivationparams.h>
#include <mfapi.h>
#include <wrl/implements.h>
#include <third_party/wil/com.h>
#include <third_party/wil/result.h>
#include <rtc_base/win/scoped_com_initializer.h>
#include <vector>
#include <mutex>

#include "libwebrtc-sys/include/audio_recorder.h"

using namespace Microsoft::WRL;

class AudioClientActivationHandler final : public RuntimeClass<RuntimeClassFlags<ClassicCom>, FtmBase,
            IActivateAudioInterfaceCompletionHandler> {
public:
    HRESULT ActivateCompleted(IActivateAudioInterfaceAsyncOperation *activateOperation) override;

    HRESULT activateResult = E_UNEXPECTED;
    wil::unique_event_nothrow hActivateCompleted;
    wil::com_ptr_nothrow<IAudioClient> audioClient;
    wil::com_ptr_nothrow<IAudioCaptureClient> captureClient;
    WAVEFORMATEX wFormat{};
};

class AudioDisplayRecorder final : public AudioRecorder {
public:
    AudioDisplayRecorder();

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
    webrtc::scoped_refptr<bridge::LocalAudioSource> source_;
    bool recording_ = false;
    bool recording_failed_ = false;

    std::vector<int16_t> recorded_samples_;

    std::recursive_mutex mutex_;

    wil::com_ptr_nothrow<AudioClientActivationHandler> audio_client_activation_handler_;

    webrtc::ScopedCOMInitializer com_initializer_;
};

#endif //AUDIO_DISPLAY_RECORDER_H

#endif // WEBRTC_WIN
