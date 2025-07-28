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
#include <wil/com.h>
#include <wil/result.h>
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
    explicit AudioDisplayRecorder(webrtc::scoped_refptr<webrtc::AudioProcessing> ap);

    // Captures a new batch of audio samples and propagates it to the inner
    // `bridge::LocalAudioSource`.
    bool ProcessRecordedPart(bool firstInCycle) override;

    // Stops audio capture freeing the captured device.
    void StopCapture() override;

    // Starts recording audio from the captured device.
    void StartCapture() override;

    // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
    // writes the recorded audio to.
    webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() override;

private:
    webrtc::scoped_refptr<bridge::LocalAudioSource> _source;
    BYTE *_buffer = nullptr;
    bool _recording = false;
    bool _recordingFailed = false;

    int _recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
    std::vector<int16_t> *_recordedSamples =
            new std::vector<int16_t>(_recordBufferSize, 0);

    std::recursive_mutex _mutex;

    wil::com_ptr_nothrow<AudioClientActivationHandler> _audioClientActivationHandler;
};

#endif //AUDIO_DISPLAY_RECORDER_H

#endif // WEBRTC_WIN
