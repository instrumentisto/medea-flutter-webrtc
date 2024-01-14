/*
 * This file is modified version of the one from Desktop App Toolkit, a set of
 * libraries for developing nice desktop applications.
 * https://github.com/desktop-app/lib_webrtc/blob/openal/webrtc/details/webrtc_openal_adm.h
 *
 * Copyright (c) 2014-2023 The Desktop App Toolkit Authors.
 *
 * Desktop App Toolkit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * It is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * In addition, as a special exception, the copyright holders give permission
 * to link the code of portions of this program with the OpenSSL library.
 *
 * Full license: https://github.com/desktop-app/legal/blob/master/LICENSE
 */

#ifndef BRIDGE_ADM_H_
#define BRIDGE_ADM_H_

#define WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE 1

#include <chrono>
#include <iostream>
#include <memory>
#include <mutex>
#include <unordered_map>

#include <AL/al.h>
#include <AL/alc.h>

#include "api/audio/audio_frame.h"
#include "api/audio/audio_mixer.h"
#include "api/media_stream_interface.h"
#include "api/sequence_checker.h"
#include "api/task_queue/task_queue_factory.h"
#include "libwebrtc-sys/include/local_audio_source.h"
#include "libwebrtc-sys/include/audio_device_recorder.h"
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

#if defined(WEBRTC_USE_X11)
#include <X11/Xlib.h>
#endif

// TODO(review): segfault in loopback sample
// (audio_device_buffer.cc:66): AudioDeviceBuffer::ctor
// (audio_device_impl.cc:120): AudioDeviceModuleImpl
// (audio_device_buffer.cc:192): SetPlayoutSampleRate(48000)
// (audio_device_buffer.cc:212): SetPlayoutChannels(2)
// (audio_device_impl.cc:135): CheckPlatform
// (audio_device_impl.cc:146): current platform is Linux
// (audio_device_impl.cc:168): CreatePlatformSpecificObjects
// (audio_device_impl.cc:905): PlatformAudioLayer
// (audio_device_impl.cc:226): PulseAudio support is enabled.
// (audio_mixer_manager_pulse_linux.cc:57): AudioMixerManagerLinuxPulse created
// (audio_device_pulse_linux.cc:82): AudioDeviceLinuxPulse created
// (audio_device_impl.cc:231): Linux PulseAudio APIs will be utilized
// (audio_device_impl.cc:272): AttachAudioBuffer
// (audio_device_buffer.cc:186): SetRecordingSampleRate(0)
// (audio_device_buffer.cc:192): SetPlayoutSampleRate(0)
// (audio_device_buffer.cc:206): SetRecordingChannels(0)
// (audio_device_buffer.cc:212): SetPlayoutChannels(0)
// (audio_device_impl.cc:292): Init
// #
// # Fatal error in: ../../webrtc/src/modules/audio_device/linux/audio_device_pulse_linux.cc, line 138
// # last system error: 0
// # Check failed: thread_checker_.IsCurrent()

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

  rtc::scoped_refptr<bridge::LocalAudioSource> CreateAudioSource(uint32_t device_index);
  void DisposeAudioSource(std::string device_id);

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

  // Capture control.
  int16_t RecordingDevices() override;
  int32_t RecordingDeviceName(uint16_t index,
                              char name[webrtc::kAdmMaxDeviceNameSize],
                              char guid[webrtc::kAdmMaxGuidSize]) override;
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
  std::chrono::milliseconds countExactQueuedMsForLatency(
      std::chrono::time_point<std::chrono::steady_clock> now,
      bool playing);
  void processRecordingQueued();

  rtc::Thread* _thread = nullptr;

  // TODO(review): isnt this supposed to be inside AudioDeviceRecorder? what is this
  //               _recordingDevice right now, when we can have multiple recording devices?
  std::recursive_mutex _recording_mutex;
  std::string _recordingDeviceId;
  bool _recordingInitialized = false;
  bool _microphoneInitialized = false;
  bool _recordingFailed = false;
  ALCdevice *_recordingDevice = nullptr;

  std::recursive_mutex _playout_mutex;
  std::string _playoutDeviceId;
  bool _playoutInitialized = false;
  bool _speakerInitialized = false;
  bool _playoutFailed = false;
  ALCdevice* _playoutDevice = nullptr;
  std::chrono::milliseconds _playoutLatency = std::chrono::milliseconds(0);
  ALCcontext* _playoutContext = nullptr;
  int _playoutChannels = 2;

  // TODO(review): unused?
  bridge::LocalAudioSource* _source;

  // TODO(review): why dont AudioDeviceRecorder lives in LocalAudioSource?
  //               any reason for this to be raw ptr and not unique/shared?
  //               i dont see AudioDeviceRecorder being removed from the map and device being
  //               released anywhere
  std::unordered_map<std::string, AudioDeviceRecorder*> _recorders;
};

#endif // BRIDGE_ADM_H_
