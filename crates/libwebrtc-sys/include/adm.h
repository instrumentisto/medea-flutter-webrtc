#ifndef BRIDGE_ADM_H_
#define BRIDGE_ADM_H_

#define WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE 1

#include <iostream>
#include <memory>
#include <mutex>

#include <AL/al.h>
#include <AL/alc.h>

#include "api/audio/audio_frame.h"
#include "api/audio/audio_mixer.h"
#include "api/media_stream_interface.h"
#include "api/sequence_checker.h"
#include "api/task_queue/task_queue_factory.h"
#include "modules/audio_device/audio_device_buffer.h"
#include "modules/audio_device/audio_device_generic.h"
#include "modules/audio_device/audio_device_impl.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/audio_device/include/audio_device_defines.h"
#include "modules/audio_mixer/audio_mixer_impl.h"
#include "rtc_base/event.h"
#include "rtc_base/platform_thread.h"
#include "rtc_base/synchronization/mutex.h"
#include "rtc_base/thread.h"
#include "rtc_base/thread_annotations.h"
#include <chrono>

#if defined(WEBRTC_USE_X11)
#include <X11/Xlib.h>
#endif

class OpenALAudioDeviceModule : public webrtc::AudioDeviceModuleImpl {
 public:
  OpenALAudioDeviceModule(AudioLayer audio_layer,
                   webrtc::TaskQueueFactory* task_queue_factory);
  ~OpenALAudioDeviceModule();

  static rtc::scoped_refptr<OpenALAudioDeviceModule> Create(
      AudioLayer audio_layer,
      webrtc::TaskQueueFactory* task_queue_factory);

  static rtc::scoped_refptr<OpenALAudioDeviceModule> CreateForTest(
      AudioLayer audio_layer,
      webrtc::TaskQueueFactory* task_queue_factory);

  // Main initialization and termination.
  int32_t Init() override;

  // Playout control.
  int16_t PlayoutDevices() override;
  int32_t SetPlayoutDevice(uint16_t index) override;
  int32_t SetPlayoutDevice(WindowsDeviceType device) override;
  int32_t PlayoutDeviceName(uint16_t index,
                            char name[webrtc::kAdmMaxDeviceNameSize],
                            char guid[webrtc::kAdmMaxGuidSize]) override;
  int32_t InitPlayout() override;
  bool PlayoutIsInitialized() const override;
  int32_t StartPlayout() override;
  int32_t StopPlayout() override;
  bool Playing() const override;
  int32_t InitSpeaker() override;
  bool SpeakerIsInitialized() const override;
  int32_t StereoPlayoutIsAvailable(bool* available) const override;
  int32_t SetStereoPlayout(bool enable) override;
  int32_t StereoPlayout(bool* enabled) const override;
  int32_t PlayoutDelay(uint16_t* delayMS) const override;

  int32_t SpeakerVolumeIsAvailable(bool* available) override;
  int32_t SetSpeakerVolume(uint32_t volume) override;
  int32_t SpeakerVolume(uint32_t* volume) const override;
  int32_t MaxSpeakerVolume(uint32_t* maxVolume) const override;
  int32_t MinSpeakerVolume(uint32_t* minVolume) const override;

  int32_t SpeakerMuteIsAvailable(bool* available) override;
  int32_t SetSpeakerMute(bool enable) override;
  int32_t SpeakerMute(bool* enabled) const override;
  int32_t RegisterAudioCallback(webrtc::AudioTransport* audioCallback) override;

  // Caprute control.
  int16_t RecordingDevices() override;
  int32_t RecordingDeviceName(uint16_t index,
                              char name[webrtc::kAdmMaxDeviceNameSize],
                              char guid[webrtc::kAdmMaxGuidSize]) override;
	int32_t SetRecordingDevice(uint16_t index) override;
	int32_t SetRecordingDevice(WindowsDeviceType device) override;
  int32_t RecordingIsAvailable(bool* available) override;
  int32_t InitRecording() override;
  bool RecordingIsInitialized() const override;
  int32_t StartRecording() override;
  int32_t StopRecording() override;
  bool Recording() const override;
  int32_t InitMicrophone() override;
  bool MicrophoneIsInitialized() const override;

  int32_t MicrophoneVolumeIsAvailable(bool* available) override;
  int32_t SetMicrophoneVolume(uint32_t volume) override;
  int32_t MicrophoneVolume(uint32_t* volume) const override;
  int32_t MaxMicrophoneVolume(uint32_t* maxVolume) const override;
  int32_t MinMicrophoneVolume(uint32_t* minVolume) const override;

  int32_t MicrophoneMuteIsAvailable(bool* available) override;
  int32_t SetMicrophoneMute(bool enable) override;
  int32_t MicrophoneMute(bool* enabled) const override;

  int32_t StereoRecordingIsAvailable(bool* available) const override;
  int32_t SetStereoRecording(bool enable) override;
  int32_t StereoRecording(bool* enabled) const override;

 private:
  struct Data;

  bool _initialized = false;
  std::unique_ptr<Data> _data;

  bool quit = false;

 private:
  int restartPlayout();
  void openPlayoutDevice();

  void startPlayingOnThread();
  void ensureThreadStarted();
  void closePlayoutDevice();
  bool validatePlayoutDeviceId();

  void clearProcessedBuffers();
  bool clearProcessedBuffer();

  void unqueueAllBuffers();

  bool processPlayout();

  // NB! closePlayoutDevice should be called after this, so that next time
  // we start playing, we set the thread local context and event callback.
  void stopPlayingOnThread();

  void processPlayoutQueued();

  void startCaptureOnThread();
  void stopCaptureOnThread();
	int restartRecording();
	void openRecordingDevice();
  void closeRecordingDevice();
  void processRecordingData();
  bool processRecordedPart(bool firstInCycle);
  std::chrono::milliseconds countExactQueuedMsForLatency(
      std::chrono::time_point<std::chrono::steady_clock> now,
      bool playing);
  std::chrono::milliseconds queryRecordingLatencyMs();
  void restartRecordingQueued();
  bool validateRecordingDeviceId();
  void processRecordingQueued();

  rtc::Thread* _thread = nullptr;
  std::string _playoutDeviceId;
  bool _playoutInitialized = false;
  bool _playoutFailed = false;
  int _playoutChannels = 2;
  bool _speakerInitialized = false;
  ALCcontext* _playoutContext = nullptr;
  ALCdevice* _playoutDevice = nullptr;

  ALCdevice *_recordingDevice = nullptr;
	std::string _recordingDeviceId;
	std::chrono::milliseconds _recordingLatency = std::chrono::milliseconds(0);
  std::chrono::milliseconds _playoutLatency = std::chrono::milliseconds(0);
	bool _recordingInitialized = false;
	bool _recordingFailed = false;

	bool _microphoneInitialized = false;

  std::recursive_mutex _playout_mutex;
  std::recursive_mutex _record_mutex;
};

#endif // BRIDGE_ADM_H_
