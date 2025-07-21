#ifdef WEBRTC_WIN

#ifndef AUDIO_DISPLAY_RECORDER_H
#define AUDIO_DISPLAY_RECORDER_H

#include <windows.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <mmreg.h>
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

    // Returns currently used deviceId for capturing system audio.
    [[nodiscard]] std::string GetDeviceId() const;

private:
    // Returns default rendering audio device.
    IMMDevice *GetDefaultDevice();

    WAVEFORMATEXTENSIBLE GetWaveFormat();

    webrtc::scoped_refptr<bridge::LocalAudioSource> _source;
    BYTE *_buffer = nullptr;
    bool _recording = false;
    bool _recordingFailed = false;
    IMMDevice *_device = nullptr;
    IAudioClient *_audioClient = nullptr;
    IAudioCaptureClient *_captureClient = nullptr;
    double _hnsActualDuration = 0.0;

    int _recordBufferSize = kRecordingPart * sizeof(int16_t) * kRecordingChannels;
    std::vector<char> *_recordedSamples =
            new std::vector<char>(_recordBufferSize, 0);

    std::recursive_mutex _mutex;
};

#endif //AUDIO_DISPLAY_RECORDER_H

#endif // WEBRTC_WIN
