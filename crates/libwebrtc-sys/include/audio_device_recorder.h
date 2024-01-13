#ifndef AUDIO_DEVICE_RECORDER_H_
#define AUDIO_DEVICE_RECORDER_H_

#include <AL/al.h>
#include <AL/alc.h>

#include "api/media_stream_interface.h"
#include "libwebrtc-sys/include/local_audio_source.h"
#include "rtc_base/thread.h"

class AudioDeviceRecorder {
  public:
    struct Data;

    AudioDeviceRecorder(std::string deviceId);
    int32_t StartRecording();
    int32_t StopRecording();
    bool IsRecording() const;
    bool ProcessRecordedPart(bool firstInCycle);
    void StopCapture();
    void StartCapture();
    rtc::scoped_refptr<bridge::LocalAudioSource> GetSource();

  private:
    void openRecordingDevice();
    bool checkDeviceFailed();
    void closeRecordingDevice();
    void restartRecording();
    bool validateRecordingDeviceId();

    rtc::scoped_refptr<bridge::LocalAudioSource> _source;
    ALCdevice* _device;
    std::string _deviceId;
    std::unique_ptr<Data> _data;
    std::recursive_mutex _mutex;
    bool _recordingFailed = false;
    bool _recording = false;
};

#endif // AUDIO_RECORDER_H_
