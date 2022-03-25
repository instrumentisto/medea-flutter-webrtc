#pragma once

#include "modules/audio_device/include/audio_device.h"
#include "pc/proxy.h"
#include "rtc_base/ref_count.h"
//rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver>
namespace webrtc {
class AudioDeviceModule_Interface : public rtc::RefCountedObject<AudioDeviceModule> {
  public:
    virtual void init_(webrtc::AudioDeviceModule::AudioLayer audio_layer,
             webrtc::TaskQueueFactory* task_queue_factory) = 0;
};

class AudioDeviceModule_ : public AudioDeviceModule_Interface {
 public:

  void init_(webrtc::AudioDeviceModule::AudioLayer audio_layer,
             webrtc::TaskQueueFactory* task_queue_factory) override {
    adm = AudioDeviceModule::Create(audio_layer, task_queue_factory);
  }

  // Retrieve the currently utilized audio layer
  int32_t ActiveAudioLayer(AudioDeviceModule::AudioLayer* audioLayer) const {
    return adm->ActiveAudioLayer(audioLayer);
  }

  // Full-duplex transportation of PCM audio
  int32_t RegisterAudioCallback(AudioTransport* audioCallback) {
    return adm->RegisterAudioCallback(audioCallback);
  }

  // Main initialization and termination
  int32_t Init() { return adm->Init(); }
  int32_t Terminate() { return adm->Terminate(); }
  bool Initialized() const { return adm->Initialized(); }

  // Device enumeration
  int16_t PlayoutDevices() { return adm->PlayoutDevices(); }
  int16_t RecordingDevices() { return adm->RecordingDevices(); }
  int32_t PlayoutDeviceName(uint16_t index,
                            char name[kAdmMaxDeviceNameSize],
                            char guid[kAdmMaxGuidSize]) {
    return adm->PlayoutDeviceName(index, name, guid);
  }
  int32_t RecordingDeviceName(uint16_t index,
                              char name[kAdmMaxDeviceNameSize],
                              char guid[kAdmMaxGuidSize]) {
    return adm->RecordingDeviceName(index, name, guid);
  }

  // Device selection
  int32_t SetPlayoutDevice(uint16_t index) {
    return adm->SetPlayoutDevice(index);
  }
  int32_t SetPlayoutDevice(AudioDeviceModule::WindowsDeviceType device) {
    return adm->SetPlayoutDevice(device);
  }
  int32_t SetRecordingDevice(uint16_t index) {
    return adm->SetRecordingDevice(index);
  }
  int32_t SetRecordingDevice(AudioDeviceModule::WindowsDeviceType device) {
    return adm->SetRecordingDevice(device);
  }

  // Audio transport initialization
  int32_t PlayoutIsAvailable(bool* available) {
    return adm->PlayoutIsAvailable(available);
  }
  int32_t InitPlayout() { return adm->InitPlayout(); }
  bool PlayoutIsInitialized() const { return adm->PlayoutIsInitialized(); }
  int32_t RecordingIsAvailable(bool* available) {
    return adm->RecordingIsAvailable(available);
  }
  int32_t InitRecording() { return adm->InitRecording(); }
  bool RecordingIsInitialized() const { return adm->RecordingIsInitialized(); }

  // Audio transport control
  int32_t StartPlayout() { return adm->StartPlayout(); }
  int32_t StopPlayout() { return adm->StopPlayout(); }
  bool Playing() const { return adm->Playing(); }
  int32_t StartRecording() { return adm->StartRecording(); }
  int32_t StopRecording() { return adm->StopRecording(); }
  bool Recording() const { return adm->Recording(); }

  // Audio mixer initialization
  int32_t InitSpeaker() { return adm->InitSpeaker(); }
  bool SpeakerIsInitialized() const { return adm->SpeakerIsInitialized(); }
  int32_t InitMicrophone() { return adm->InitMicrophone(); }
  bool MicrophoneIsInitialized() const {
    return adm->MicrophoneIsInitialized();
  }

  // Speaker volume controls
  int32_t SpeakerVolumeIsAvailable(bool* available) {
    return adm->SpeakerVolumeIsAvailable(available);
  }
  int32_t SetSpeakerVolume(uint32_t volume) {
    return adm->SetSpeakerVolume(volume);
  }
  int32_t SpeakerVolume(uint32_t* volume) const {
    return adm->SpeakerVolume(volume);
  }
  int32_t MaxSpeakerVolume(uint32_t* maxVolume) const {
    return adm->MaxSpeakerVolume(maxVolume);
  }
  int32_t MinSpeakerVolume(uint32_t* minVolume) const {
    return adm->MinSpeakerVolume(minVolume);
  }

  // Microphone volume controls
  int32_t MicrophoneVolumeIsAvailable(bool* available) {
    return adm->MicrophoneVolumeIsAvailable(available);
  }
  int32_t SetMicrophoneVolume(uint32_t volume) {
    return adm->SetMicrophoneVolume(volume);
  }
  int32_t MicrophoneVolume(uint32_t* volume) const {
    return adm->MicrophoneVolume(volume);
  }
  int32_t MaxMicrophoneVolume(uint32_t* maxVolume) const {
    return adm->MinMicrophoneVolume(maxVolume);
  }
  int32_t MinMicrophoneVolume(uint32_t* minVolume) const {
    return adm->MinMicrophoneVolume(minVolume);
  }

  // Speaker mute control
  int32_t SpeakerMuteIsAvailable(bool* available) {
    return adm->SpeakerMuteIsAvailable(available);
  }
  int32_t SetSpeakerMute(bool enable) { return adm->SetSpeakerMute(enable); }
  int32_t SpeakerMute(bool* enabled) const { return adm->SpeakerMute(enabled); }

  // Microphone mute control
  int32_t MicrophoneMuteIsAvailable(bool* available) {
    return adm->MicrophoneMuteIsAvailable(available);
  }
  int32_t SetMicrophoneMute(bool enable) {
    return adm->SetMicrophoneMute(enable);
  }
  int32_t MicrophoneMute(bool* enabled) const {
    return adm->MicrophoneMute(enabled);
  }

  // Stereo support
  int32_t StereoPlayoutIsAvailable(bool* available) const {
    return adm->StereoPlayoutIsAvailable(available);
  }
  int32_t SetStereoPlayout(bool enable) override {
    return adm->SetStereoPlayout(enable);
  }
  int32_t StereoPlayout(bool* enabled) const {
    return adm->StereoPlayout(enabled);
  }
  int32_t StereoRecordingIsAvailable(bool* available) const {
    return adm->StereoRecordingIsAvailable(available);
  }
  int32_t SetStereoRecording(bool enable) {
    return adm->SetStereoRecording(enable);
  }
  int32_t StereoRecording(bool* enabled) const {
    return adm->StereoRecording(enabled);
  }

  // Playout delay
  int32_t PlayoutDelay(uint16_t* delayMS) const {
    return adm->PlayoutDelay(delayMS);
  }

  // Only supported on Android.
  bool BuiltInAECIsAvailable() const { return adm->BuiltInAECIsAvailable(); }
  bool BuiltInAGCIsAvailable() const { return adm->BuiltInAGCIsAvailable(); }
  bool BuiltInNSIsAvailable() const { return adm->BuiltInNSIsAvailable(); }

  // Enables the built-in audio effects. Only supported on Android.
  int32_t EnableBuiltInAEC(bool enable) {
    return adm->EnableBuiltInAEC(enable);
  }
  int32_t EnableBuiltInAGC(bool enable) {
    return adm->EnableBuiltInAGC(enable);
  }
  int32_t EnableBuiltInNS(bool enable) { return adm->EnableBuiltInNS(enable); }

  int32_t GetPlayoutUnderrunCount() const { return adm->GetPlayoutUnderrunCount(); }

 private:
  rtc::scoped_refptr<AudioDeviceModule> adm;
};


  // // Retrieve the currently utilized audio layer
  // virtual int32_t ActiveAudioLayer(AudioLayer* audioLayer) const = 0;

  // // Full-duplex transportation of PCM audio
  // virtual int32_t RegisterAudioCallback(AudioTransport* audioCallback) = 0;

  // // Main initialization and termination
  // virtual int32_t Init() = 0;
  // virtual int32_t Terminate() = 0;
  // virtual bool Initialized() const = 0;







BEGIN_PROXY_MAP(AudioDeviceModule_)
PROXY_PRIMARY_THREAD_DESTRUCTOR()
PROXY_METHOD2(void, init_, AudioDeviceModule::AudioLayer, TaskQueueFactory*)
PROXY_CONSTMETHOD1(int32_t, ActiveAudioLayer, AudioDeviceModule::AudioLayer*)
PROXY_METHOD0(int32_t, Init)
PROXY_METHOD1(int32_t, RegisterAudioCallback, AudioTransport* )
PROXY_METHOD1(int32_t, SetMicrophoneMute, bool )
PROXY_METHOD1(int32_t, MicrophoneMuteIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetSpeakerMute, bool)
PROXY_METHOD1(int32_t, SpeakerMuteIsAvailable, bool*)
PROXY_CONSTMETHOD0(int32_t, GetPlayoutUnderrunCount)
PROXY_CONSTMETHOD1(int32_t, MicrophoneMute, bool*)
PROXY_CONSTMETHOD1(int32_t, SpeakerMute, bool*)

PROXY_CONSTMETHOD1(int32_t, SpeakerVolume, uint32_t* )
PROXY_CONSTMETHOD1(int32_t, MaxSpeakerVolume, uint32_t* )
PROXY_CONSTMETHOD1(int32_t, MinSpeakerVolume, uint32_t* )

PROXY_CONSTMETHOD0(bool, PlayoutIsInitialized)
PROXY_CONSTMETHOD0(bool, RecordingIsInitialized)

PROXY_METHOD0(int32_t, Terminate)
PROXY_CONSTMETHOD0(bool, Initialized)
PROXY_METHOD0(int32_t, StartPlayout)
PROXY_METHOD0(int32_t, StopPlayout)
PROXY_METHOD0(int32_t, StartRecording)
PROXY_METHOD0(int32_t, StopRecording)

PROXY_METHOD1(int32_t, PlayoutIsAvailable, bool*)
PROXY_METHOD0(int32_t, InitPlayout)
PROXY_METHOD1(int32_t, RecordingIsAvailable, bool*)
PROXY_METHOD0(int32_t, InitRecording)

PROXY_CONSTMETHOD0(bool, Playing)
PROXY_CONSTMETHOD0(bool, Recording)

PROXY_CONSTMETHOD0(bool, SpeakerIsInitialized)
PROXY_CONSTMETHOD0(bool, MicrophoneIsInitialized)

PROXY_METHOD0(int32_t, InitSpeaker)
PROXY_METHOD0(int32_t, InitMicrophone)

PROXY_METHOD0(int16_t, PlayoutDevices)
PROXY_METHOD0(int16_t, RecordingDevices)

PROXY_METHOD1(int32_t, SetSpeakerVolume, uint32_t)
PROXY_METHOD1(int32_t, SpeakerVolumeIsAvailable, bool*)

PROXY_METHOD1(int32_t, SetPlayoutDevice, uint16_t)
PROXY_METHOD1(int32_t, SetPlayoutDevice, WindowsDeviceType)
PROXY_METHOD1(int32_t, SetRecordingDevice, uint16_t)
PROXY_METHOD1(int32_t, SetRecordingDevice, WindowsDeviceType)

PROXY_METHOD3(int32_t, PlayoutDeviceName, uint16_t, char*, char*)
PROXY_METHOD3(int32_t, RecordingDeviceName, uint16_t, char*, char*)

PROXY_CONSTMETHOD1(int32_t, MicrophoneVolume, uint32_t* )
PROXY_CONSTMETHOD1(int32_t, MaxMicrophoneVolume, uint32_t* )
PROXY_CONSTMETHOD1(int32_t, MinMicrophoneVolume, uint32_t* )

PROXY_METHOD1(int32_t, MicrophoneVolumeIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetMicrophoneVolume, uint32_t)

PROXY_CONSTMETHOD1(int32_t, StereoPlayoutIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetStereoPlayout, bool)
PROXY_CONSTMETHOD1(int32_t, StereoPlayout, bool* )
PROXY_CONSTMETHOD1(int32_t, StereoRecordingIsAvailable, bool* )
PROXY_METHOD1(int32_t, SetStereoRecording, bool )
PROXY_CONSTMETHOD1(int32_t, StereoRecording, bool* )

PROXY_CONSTMETHOD1(int32_t, PlayoutDelay, uint16_t* )

PROXY_CONSTMETHOD0(bool, BuiltInAECIsAvailable)
PROXY_CONSTMETHOD0(bool, BuiltInAGCIsAvailable)
PROXY_CONSTMETHOD0(bool, BuiltInNSIsAvailable)

PROXY_METHOD1(int32_t, EnableBuiltInAEC, bool)
PROXY_METHOD1(int32_t, EnableBuiltInAGC, bool)
PROXY_METHOD1(int32_t, EnableBuiltInNS, bool)
END_PROXY_MAP(AudioDeviceModule_)
}  // namespace webrtc
