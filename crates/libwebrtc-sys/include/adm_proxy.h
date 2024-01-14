#ifndef BRIDGE_ADM_PROXY_H_
#define BRIDGE_ADM_PROXY_H_

#include "libwebrtc-sys/include/adm.h"
#include "modules/audio_device/include/audio_device.h"
#include "pc/proxy.h"

namespace webrtc {

class AudioDeviceModuleCustomProxy : public rtc::RefCountInterface {
 public:
  AudioDeviceModuleCustomProxy(
    rtc::scoped_refptr<webrtc::AudioDeviceModule> proxied_adm,
    rtc::scoped_refptr<OpenALAudioDeviceModule> adm
  );

  int32_t Init();

  rtc::scoped_refptr<bridge::LocalAudioSource> CreateAudioSource(uint32_t device_index);
  void DisposeAudioSource(std::string device_id);

  rtc::scoped_refptr<webrtc::AudioDeviceModule> GetProxiedAdm();

  int16_t PlayoutDevices();
  int32_t SetPlayoutDevice(uint16_t index);
  int32_t SetPlayoutDevice(AudioDeviceModule::WindowsDeviceType device);
  int32_t PlayoutDeviceName(uint16_t index,
                            char name[webrtc::kAdmMaxDeviceNameSize],
                            char guid[webrtc::kAdmMaxGuidSize]);
  int32_t InitPlayout();
  bool PlayoutIsInitialized() const;
  int32_t StartPlayout();
  int32_t StopPlayout();
  bool Playing() const;
  int32_t InitSpeaker();
  bool SpeakerIsInitialized() const;
  int32_t StereoPlayoutIsAvailable(bool* available) const;
  int32_t SetStereoPlayout(bool enable);
  int32_t StereoPlayout(bool* enabled) const;
  int32_t PlayoutDelay(uint16_t* delayMS) const;

  int32_t SpeakerVolumeIsAvailable(bool* available);
  int32_t SetSpeakerVolume(uint32_t volume);
  int32_t SpeakerVolume(uint32_t* volume) const;
  int32_t MaxSpeakerVolume(uint32_t* maxVolume) const;
  int32_t MinSpeakerVolume(uint32_t* minVolume) const;

  int32_t SpeakerMuteIsAvailable(bool* available);
  int32_t SetSpeakerMute(bool enable);
  int32_t SpeakerMute(bool* enabled) const;
  int32_t RegisterAudioCallback(webrtc::AudioTransport* audioCallback);

  // Capture control.
  int16_t RecordingDevices();
  int32_t RecordingDeviceName(uint16_t index,
                              char name[webrtc::kAdmMaxDeviceNameSize],
                              char guid[webrtc::kAdmMaxGuidSize]);
  int32_t RecordingIsAvailable(bool* available);
  int32_t InitRecording();
  bool RecordingIsInitialized() const;
  int32_t StartRecording();
  int32_t StopRecording();
  bool Recording() const;
  int32_t InitMicrophone();
  bool MicrophoneIsInitialized() const;

  int32_t MicrophoneVolumeIsAvailable(bool* available);
  int32_t SetMicrophoneVolume(uint32_t volume);
  int32_t MicrophoneVolume(uint32_t* volume) const;
  int32_t MaxMicrophoneVolume(uint32_t* maxVolume) const;
  int32_t MinMicrophoneVolume(uint32_t* minVolume) const;

  int32_t MicrophoneMuteIsAvailable(bool* available);
  int32_t SetMicrophoneMute(bool enable);
  int32_t MicrophoneMute(bool* enabled) const;

  int32_t StereoRecordingIsAvailable(bool* available) const;
  int32_t SetStereoRecording(bool enable);
  int32_t StereoRecording(bool* enabled) const;

 private:
  rtc::scoped_refptr<webrtc::AudioDeviceModule> _proxied_adm;
  rtc::scoped_refptr<OpenALAudioDeviceModule> _adm;
};

using AudioDeviceModuleInterface = AudioDeviceModule;

// Define proxy for `AudioDeviceModule`.
BEGIN_PRIMARY_PROXY_MAP(AudioDeviceModule)
PROXY_PRIMARY_THREAD_DESTRUCTOR()
PROXY_CONSTMETHOD1(int32_t, ActiveAudioLayer, AudioDeviceModule::AudioLayer*)
PROXY_METHOD1(int32_t, RegisterAudioCallback, AudioTransport*)
PROXY_METHOD0(int32_t, Init)
PROXY_METHOD0(int32_t, Terminate)
PROXY_CONSTMETHOD0(bool, Initialized)
PROXY_METHOD0(int16_t, PlayoutDevices)
PROXY_METHOD0(int16_t, RecordingDevices)
PROXY_METHOD3(int32_t, PlayoutDeviceName, uint16_t, char*, char*)
PROXY_METHOD3(int32_t, RecordingDeviceName, uint16_t, char*, char*)
PROXY_METHOD1(int32_t, SetPlayoutDevice, uint16_t)
PROXY_METHOD1(int32_t, SetPlayoutDevice, WindowsDeviceType)
PROXY_METHOD1(int32_t, SetRecordingDevice, uint16_t)
PROXY_METHOD1(int32_t, SetRecordingDevice, WindowsDeviceType)
PROXY_METHOD1(int32_t, PlayoutIsAvailable, bool*)
PROXY_METHOD0(int32_t, InitPlayout)
PROXY_CONSTMETHOD0(bool, PlayoutIsInitialized)
PROXY_METHOD1(int32_t, RecordingIsAvailable, bool*)
PROXY_METHOD0(int32_t, InitRecording)
PROXY_CONSTMETHOD0(bool, RecordingIsInitialized)
PROXY_METHOD0(int32_t, StartPlayout)
PROXY_METHOD0(int32_t, StopPlayout)
PROXY_CONSTMETHOD0(bool, Playing)
PROXY_METHOD0(int32_t, StartRecording)
PROXY_METHOD0(int32_t, StopRecording)
PROXY_CONSTMETHOD0(bool, Recording)
PROXY_METHOD0(int32_t, InitSpeaker)
PROXY_CONSTMETHOD0(bool, SpeakerIsInitialized)
PROXY_METHOD0(int32_t, InitMicrophone)
PROXY_CONSTMETHOD0(bool, MicrophoneIsInitialized)
PROXY_METHOD1(int32_t, SpeakerVolumeIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetSpeakerVolume, uint32_t)
PROXY_CONSTMETHOD1(int32_t, SpeakerVolume, uint32_t*)
PROXY_CONSTMETHOD1(int32_t, MaxSpeakerVolume, uint32_t*)
PROXY_CONSTMETHOD1(int32_t, MinSpeakerVolume, uint32_t*)
PROXY_METHOD1(int32_t, MicrophoneVolumeIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetMicrophoneVolume, uint32_t)
PROXY_CONSTMETHOD1(int32_t, MicrophoneVolume, uint32_t*)
PROXY_CONSTMETHOD1(int32_t, MaxMicrophoneVolume, uint32_t*)
PROXY_CONSTMETHOD1(int32_t, MinMicrophoneVolume, uint32_t*)
PROXY_METHOD1(int32_t, SpeakerMuteIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetSpeakerMute, bool)
PROXY_CONSTMETHOD1(int32_t, SpeakerMute, bool*)
PROXY_METHOD1(int32_t, MicrophoneMuteIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetMicrophoneMute, bool)
PROXY_CONSTMETHOD1(int32_t, MicrophoneMute, bool*)
PROXY_CONSTMETHOD1(int32_t, StereoPlayoutIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetStereoPlayout, bool)
PROXY_CONSTMETHOD1(int32_t, StereoPlayout, bool*)
PROXY_CONSTMETHOD1(int32_t, StereoRecordingIsAvailable, bool*)
PROXY_METHOD1(int32_t, SetStereoRecording, bool)
PROXY_CONSTMETHOD1(int32_t, StereoRecording, bool*)
PROXY_CONSTMETHOD1(int32_t, PlayoutDelay, uint16_t*)
PROXY_CONSTMETHOD0(bool, BuiltInAECIsAvailable)
PROXY_CONSTMETHOD0(bool, BuiltInAGCIsAvailable)
PROXY_CONSTMETHOD0(bool, BuiltInNSIsAvailable)
PROXY_METHOD1(int32_t, EnableBuiltInAEC, bool)
PROXY_METHOD1(int32_t, EnableBuiltInAGC, bool)
PROXY_METHOD1(int32_t, EnableBuiltInNS, bool)
PROXY_CONSTMETHOD0(int32_t, GetPlayoutUnderrunCount)
#if defined(WEBRTC_IOS)
  PROXY_CONSTMETHOD1(int, GetPlayoutAudioParameters, AudioParameters*)
  PROXY_CONSTMETHOD1(int, GetRecordAudioParameters, AudioParameters*)
#endif  // WEBRTC_IOS
END_PROXY_MAP(AudioDeviceModule)
}  // namespace webrtc

#endif // BRIDGE_ADM_PROXY_H_
