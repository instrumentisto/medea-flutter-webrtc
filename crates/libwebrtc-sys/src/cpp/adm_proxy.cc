#include "adm_proxy.h"

namespace webrtc {

AudioDeviceModuleCustomProxy::AudioDeviceModuleCustomProxy(
    rtc::scoped_refptr<webrtc::AudioDeviceModule> proxied_adm,
    rtc::scoped_refptr<OpenALAudioDeviceModule> adm
  ) {
  _proxied_adm = proxied_adm;
  _adm = adm;
}

AudioDeviceModuleCustomProxy::AudioDeviceModuleCustomProxy(
  rtc::scoped_refptr<webrtc::AudioDeviceModule> proxied_adm
) {
  _proxied_adm = proxied_adm;
  _adm = nullptr;
}

int32_t AudioDeviceModuleCustomProxy::Init() {
  return _proxied_adm->Init();
}

rtc::scoped_refptr<webrtc::AudioDeviceModule> AudioDeviceModuleCustomProxy::GetProxiedAdm() {
  return _proxied_adm;
}

rtc::scoped_refptr<bridge::LocalAudioSource> AudioDeviceModuleCustomProxy::CreateAudioSource(uint32_t device_index) {
  if (_adm == nullptr) {
    return nullptr;
  } else {
    return _adm->CreateAudioSource(device_index);
  }
}

void AudioDeviceModuleCustomProxy::DisposeAudioSource(std::string device_id) {
  if (_adm != nullptr) {
    return _adm->DisposeAudioSource(device_id);
  }
}
int16_t AudioDeviceModuleCustomProxy::PlayoutDevices() {
  return _proxied_adm->PlayoutDevices();
}
int32_t AudioDeviceModuleCustomProxy::SetPlayoutDevice(uint16_t index) {
  return _proxied_adm->SetPlayoutDevice(index);
}
int32_t AudioDeviceModuleCustomProxy::SetPlayoutDevice(AudioDeviceModule::WindowsDeviceType device) {
  return _proxied_adm->SetPlayoutDevice(device);
}
int32_t AudioDeviceModuleCustomProxy::PlayoutDeviceName(uint16_t index,
                          char name[webrtc::kAdmMaxDeviceNameSize],
                          char guid[webrtc::kAdmMaxGuidSize]) {
  return _proxied_adm->PlayoutDeviceName(index, name, guid);
}
int32_t AudioDeviceModuleCustomProxy::InitPlayout() {
  return _proxied_adm->InitPlayout();
}
bool AudioDeviceModuleCustomProxy::PlayoutIsInitialized() const {
  return _proxied_adm->PlayoutIsInitialized();
}
int32_t AudioDeviceModuleCustomProxy::StartPlayout() {
  return _proxied_adm->StartPlayout();
}
int32_t AudioDeviceModuleCustomProxy::StopPlayout() {
  return _proxied_adm->StopPlayout();
}
bool AudioDeviceModuleCustomProxy::Playing() const {
  return _proxied_adm->Playing();
}
int32_t AudioDeviceModuleCustomProxy::InitSpeaker() {
  return _proxied_adm->InitSpeaker();
}
bool AudioDeviceModuleCustomProxy::SpeakerIsInitialized() const {
  return _proxied_adm->SpeakerIsInitialized();
}
int32_t AudioDeviceModuleCustomProxy::StereoPlayoutIsAvailable(bool* available) const {
  return _proxied_adm->StereoPlayoutIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetStereoPlayout(bool enable) {
  return _proxied_adm->SetStereoPlayout(enable);
}
int32_t AudioDeviceModuleCustomProxy::StereoPlayout(bool* enabled) const {
  return _proxied_adm->StereoPlayout(enabled);
}
int32_t AudioDeviceModuleCustomProxy::PlayoutDelay(uint16_t* delayMS) const {
  return _proxied_adm->PlayoutDelay(delayMS);
}
int32_t AudioDeviceModuleCustomProxy::SpeakerVolumeIsAvailable(bool* available) {
  return _proxied_adm->SpeakerVolumeIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetSpeakerVolume(uint32_t volume) {
  return _proxied_adm->SetSpeakerVolume(volume);
}
int32_t AudioDeviceModuleCustomProxy::SpeakerVolume(uint32_t* volume) const {
  return _proxied_adm->SpeakerVolume(volume);
}
int32_t AudioDeviceModuleCustomProxy::MaxSpeakerVolume(uint32_t* maxVolume) const {
  return _proxied_adm->MaxSpeakerVolume(maxVolume);
}
int32_t AudioDeviceModuleCustomProxy::MinSpeakerVolume(uint32_t* minVolume) const {
  return _proxied_adm->MinSpeakerVolume(minVolume);
}
int32_t AudioDeviceModuleCustomProxy::SpeakerMuteIsAvailable(bool* available) {
  return _proxied_adm->SpeakerMuteIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetSpeakerMute(bool enable) {
  return _proxied_adm->SetSpeakerMute(enable);
}
int32_t AudioDeviceModuleCustomProxy::SpeakerMute(bool* enabled) const {
  return _proxied_adm->SpeakerMute(enabled);
}
int32_t AudioDeviceModuleCustomProxy::RegisterAudioCallback(webrtc::AudioTransport* audioCallback) {
  return _proxied_adm->RegisterAudioCallback(audioCallback);
}
int16_t AudioDeviceModuleCustomProxy::RecordingDevices() {
  return _proxied_adm->RecordingDevices();
}
int32_t AudioDeviceModuleCustomProxy::RecordingDeviceName(uint16_t index,
                            char name[webrtc::kAdmMaxDeviceNameSize],
                            char guid[webrtc::kAdmMaxGuidSize]) {
  return _proxied_adm->RecordingDeviceName(index, name, guid);
}
int32_t AudioDeviceModuleCustomProxy::RecordingIsAvailable(bool* available) {
  return _proxied_adm->RecordingIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::InitRecording() {
  return _proxied_adm->InitRecording();
}
bool AudioDeviceModuleCustomProxy::RecordingIsInitialized() const {
  return _proxied_adm->RecordingIsInitialized();
}
int32_t AudioDeviceModuleCustomProxy::StartRecording() {
  return _proxied_adm->StartRecording();
}
int32_t AudioDeviceModuleCustomProxy::StopRecording() {
  return _proxied_adm->StopRecording();
}
bool AudioDeviceModuleCustomProxy::Recording() const {
  return _proxied_adm->Recording();
}
int32_t AudioDeviceModuleCustomProxy::InitMicrophone() {
  return _proxied_adm->InitMicrophone();
}
bool AudioDeviceModuleCustomProxy::MicrophoneIsInitialized() const {
  return _proxied_adm->MicrophoneIsInitialized();
}
int32_t AudioDeviceModuleCustomProxy::MicrophoneVolumeIsAvailable(bool* available) {
  return _proxied_adm->MicrophoneVolumeIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetMicrophoneVolume(uint32_t volume) {
  return _proxied_adm->SetMicrophoneVolume(volume);
}
int32_t AudioDeviceModuleCustomProxy::MicrophoneVolume(uint32_t* volume) const {
  return _proxied_adm->MicrophoneVolume(volume);
}
int32_t AudioDeviceModuleCustomProxy::MaxMicrophoneVolume(uint32_t* maxVolume) const {
  return _proxied_adm->MaxMicrophoneVolume(maxVolume);
}
int32_t AudioDeviceModuleCustomProxy::MinMicrophoneVolume(uint32_t* minVolume) const {
  return _proxied_adm->MinMicrophoneVolume(minVolume);
}
int32_t AudioDeviceModuleCustomProxy::MicrophoneMuteIsAvailable(bool* available) {
  return _proxied_adm->MicrophoneMuteIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetMicrophoneMute(bool enable) {
  return _proxied_adm->SetMicrophoneMute(enable);
}
int32_t AudioDeviceModuleCustomProxy::MicrophoneMute(bool* enabled) const {
  return _proxied_adm->MicrophoneMute(enabled);
}
int32_t AudioDeviceModuleCustomProxy::StereoRecordingIsAvailable(bool* available) const {
  return _proxied_adm->StereoRecordingIsAvailable(available);
}
int32_t AudioDeviceModuleCustomProxy::SetStereoRecording(bool enable) {
  return _proxied_adm->SetStereoRecording(enable);
}
int32_t AudioDeviceModuleCustomProxy::StereoRecording(bool* enabled) const {
  return _proxied_adm->StereoRecording(enabled);
}

}

