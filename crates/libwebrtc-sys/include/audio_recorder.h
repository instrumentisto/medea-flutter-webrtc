#ifndef BRIDGE_AUDIO_RECORDER_H_
#define BRIDGE_AUDIO_RECORDER_H_

#include <chrono>

#include "api/media_stream_interface.h"
#include "libwebrtc-sys/include/local_audio_source.h"
#include "rtc_base/thread.h"

constexpr auto kPlayoutFrequency = 48000;
constexpr auto kRecordingFrequency = 48000;
constexpr auto kBitsPerSample = 16;
constexpr auto kRecordingChannels = 1;
constexpr auto kBlockAlign = kRecordingFrequency * kRecordingChannels / 8;
constexpr std::int64_t kBufferSizeMs = 10;
constexpr auto kProcessInterval = 10;
constexpr auto kALMaxValues = 6;
constexpr auto kQueryExactTimeEach = 20;
constexpr auto kDefaultPlayoutLatency = std::chrono::duration<double>(20.0);
constexpr auto kDefaultRecordingLatency = std::chrono::milliseconds(20);
constexpr auto kRestartAfterEmptyData = 200; // Two seconds with no data.
constexpr auto kPlayoutPart = (kPlayoutFrequency * kBufferSizeMs + 999) / 1000;
constexpr auto kBuffersFullCount = 7;
constexpr auto kBuffersKeepReadyCount = 5;
constexpr auto kRecordingPart =
        (kRecordingFrequency * kBufferSizeMs + 999) / 1000;

// Uniform interface for recording audio.
class AudioRecorder {
public:
    // Captures a new batch of audio samples and propagates it to the inner
    // `bridge::LocalAudioSource`.
    virtual bool ProcessRecordedPart(bool firstInCycle) = 0;

    // Stops audio capture freeing the captured device.
    virtual void StopCapture() = 0;

    // Starts recording audio from the captured device.
    virtual void StartCapture() = 0;

    // Returns the `bridge::LocalAudioSource` that this `AudioDeviceRecorder`
    // writes the recorded audio to.
    virtual webrtc::scoped_refptr<bridge::LocalAudioSource> GetSource() = 0;

    virtual ~AudioRecorder() = default;
};

#endif  // BRIDGE_AUDIO_RECORDER_H_
