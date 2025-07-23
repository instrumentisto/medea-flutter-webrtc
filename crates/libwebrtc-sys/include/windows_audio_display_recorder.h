#ifdef WEBRTC_WIN

#ifndef AUDIO_DISPLAY_RECORDER_H
#define AUDIO_DISPLAY_RECORDER_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <vector>
#include <mutex>

#include "libwebrtc-sys/include/audio_recorder.h"

class AudioDisplayRecorder final : public AudioRecorder {
public:
    AudioDisplayRecorder();

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
    // Returns default rendering audio device.
    static IMMDevice *GetDefaultDevice();
    void CleanupResources();

    WAVEFORMATEX *_wFormat = nullptr;
    webrtc::scoped_refptr<bridge::LocalAudioSource> _source;
    BYTE *_buffer = nullptr;
    bool _recording = false;
    bool _recordingFailed = false;
    IMMDevice *_device = nullptr;
    IAudioClient *_audioClient = nullptr;
    IAudioCaptureClient *_captureClient = nullptr;

    int _recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
    std::vector<int16_t> *_recordedSamples =
            new std::vector<int16_t>(_recordBufferSize, 0);

    std::recursive_mutex _mutex;
};

#endif //AUDIO_DISPLAY_RECORDER_H

#endif // WEBRTC_WIN
