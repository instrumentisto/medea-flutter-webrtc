#include "rtc_base/logging.h"

#include "libwebrtc-sys/include/sys_audio_capture/win_capture.h"

const auto CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const auto IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const auto IID_IAudioClient = __uuidof(IAudioClient);
const auto IID_IAudioCaptureClient = __uuidof(IAudioCaptureClient);

#define BITS_PER_BYTE 8

// 10ms in 100ns units.
#define TEN_MS 100000

// 1s in ms.
#define ONE_SECOND 1000

HRESULT AudioClientActivationHandler::ActivateCompleted(
    IActivateAudioInterfaceAsyncOperation* activateOperation) {
  wil::com_ptr_nothrow<IUnknown> punkAudioInterface;

  HRESULT hr = activateOperation->GetActivateResult(&activate_result,
                                                    &punkAudioInterface);

  if (FAILED(hr)) {
    activate_result = hr;
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to get activation"
                      << " result. OS error: " << hr << ".";
    return hr;
  }

  if (FAILED(activate_result)) {
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to activate audio"
                      << " interface. OS error: " << activate_result << ".";
    return activate_result;
  }

  hr = punkAudioInterface.copy_to(&audio_client);

  if (FAILED(hr)) {
    activate_result = hr;
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to copy audio"
                      << " client. OS error: " << hr << ".";
    return hr;
  }

  WAVEFORMATEX format{};
  format.wFormatTag = WAVE_FORMAT_PCM;
  format.nChannels = kRecordingChannels;
  format.nSamplesPerSec = kRecordingFrequency;
  format.wBitsPerSample = kBitsPerSample;
  format.nBlockAlign = format.nChannels * format.wBitsPerSample / BITS_PER_BYTE;
  format.nAvgBytesPerSec = format.nSamplesPerSec * format.nBlockAlign;

  hr = audio_client->Initialize(
      AUDCLNT_SHAREMODE_SHARED,
      (AUDCLNT_STREAMFLAGS_LOOPBACK | AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM),
      TEN_MS, 0, &format, nullptr);

  if (FAILED(hr)) {
    activate_result = hr;
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to initialize audio"
                      << " client. OS error: " << hr << ".";
    return hr;
  }

  hr = audio_client->GetService(IID_IAudioCaptureClient,
                                reinterpret_cast<void**>(&capture_client));

  if (FAILED(hr)) {
    activate_result = hr;
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to get"
                      << " IAudioCaptureClient. OS error: " << hr << ".";
    return hr;
  }

  hr = audio_client->Start();

  if (FAILED(hr)) {
    activate_result = hr;
    activate_completed.SetEvent();
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to start audio"
                      << " client. OS error: " << hr << ".";
    return hr;
  }

  activate_result = S_OK;
  activate_completed.SetEvent();

  return S_OK;
}

SysAudioSource::SysAudioSource() {
  recorded_samples_.reserve(kRecordingPart * kRecordingChannels);
  source_ = bridge::LocalAudioSource::Create(webrtc::AudioOptions(), nullptr);
  audio_client_activation_handler_ = Make<AudioClientActivationHandler>();
}

bool SysAudioSource::StartCapture() {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (recording_ || recording_failed_) {
    return false;
  }

  HRESULT hr = audio_client_activation_handler_->activate_completed.create(
      wil::EventOptions::None);

  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to create audio"
                      << " client activation event handler. OS error: " << hr
                      << ".";
    recording_failed_ = true;
    return false;
  }

  AUDIOCLIENT_ACTIVATION_PARAMS audioclientActivationParams = {};
  audioclientActivationParams.ActivationType =
      AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK;
  audioclientActivationParams.ProcessLoopbackParams.ProcessLoopbackMode =
      PROCESS_LOOPBACK_MODE_EXCLUDE_TARGET_PROCESS_TREE;
  audioclientActivationParams.ProcessLoopbackParams.TargetProcessId =
      GetCurrentProcessId();

  PROPVARIANT activateParams = {};
  activateParams.vt = VT_BLOB;
  activateParams.blob.cbSize = sizeof(audioclientActivationParams);
  activateParams.blob.pBlobData =
      reinterpret_cast<BYTE*>(&audioclientActivationParams);

  wil::com_ptr_nothrow<IActivateAudioInterfaceAsyncOperation> asyncOp;

  hr = ActivateAudioInterfaceAsync(
      VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK, __uuidof(IAudioClient),
      &activateParams, audio_client_activation_handler_.get(), &asyncOp);

  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to start"
                      << " AudioClient activation. OS error: " << hr << ".";
    recording_failed_ = true;
    return false;
  }

  // Ignore result.
  static_cast<void>(
      audio_client_activation_handler_->activate_completed.wait(ONE_SECOND));

  recording_ = !FAILED(audio_client_activation_handler_->activate_result);

  return true;
}

void SysAudioSource::StopCapture() {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (!recording_) {
    return;
  }

  if (audio_client_activation_handler_->audio_client) {
    // We are already cleaning up here so just ignore result.
    static_cast<void>(audio_client_activation_handler_->audio_client->Stop());
    audio_client_activation_handler_->audio_client.reset();
  }

  if (audio_client_activation_handler_->capture_client) {
    audio_client_activation_handler_->capture_client.reset();
  }

  recording_ = false;
}

bool SysAudioSource::ProcessRecordedPart(bool firstInCycle) {
  std::lock_guard<std::recursive_mutex> lock(mutex_);

  if (!recording_) {
    return false;
  }

  UINT32 packetLength = 0;
  HRESULT hr =
      audio_client_activation_handler_->capture_client->GetNextPacketSize(
          &packetLength);

  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to get next audio"
                      << " packet size. OS error: " << hr << ".";
    return false;
  }

  if (packetLength == 0) {
    return false;
  }

  UINT32 numFramesAvailable = 0;
  DWORD flags = 0;
  BYTE* buffer = nullptr;

  hr = audio_client_activation_handler_->capture_client->GetBuffer(
      &buffer, &numFramesAvailable, &flags, nullptr, nullptr);

  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to get audio"
                      << " buffer. OS error: " << hr << ".";
    return false;
  }

  if (flags & AUDCLNT_BUFFERFLAGS_DATA_DISCONTINUITY) {
    RTC_LOG(LS_WARNING) << "SysAudioSource: "
                        << "AUDCLNT_BUFFERFLAGS_DATA_DISCONTINUITY.";
  }
  if (flags & AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR) {
    RTC_LOG(LS_WARNING) << "SysAudioSource: "
                        << "AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR.";
  }

  const int16_t* res_data = nullptr;
  if (flags & AUDCLNT_BUFFERFLAGS_SILENT) {
    // Fill the provided number of frames in the vec with silence.
    recorded_samples_.insert(recorded_samples_.end(), numFramesAvailable, 0);
    res_data = recorded_samples_.data();
  } else {
    const auto audioData = reinterpret_cast<const int16_t*>(buffer);

    if (recorded_samples_.empty() && numFramesAvailable == kRecordingPart) {
      // Skip intermediate buffer and write directly from the GetBuffer
      // result.
      res_data = audioData;
    } else {
      recorded_samples_.insert(
          recorded_samples_.end(), audioData,
          audioData + numFramesAvailable);

      if (recorded_samples_.size() < kRecordingPart) {
        static_cast<void>(
          audio_client_activation_handler_->capture_client->ReleaseBuffer(
            numFramesAvailable));

        // Not enough data for 10 milliseconds.
        return false;
      }

      res_data = recorded_samples_.data();
    }
  }

  source_->OnData(res_data, kBitsPerSample, kRecordingFrequency,
                  kRecordingChannels, kRecordingPart);

  if (!recorded_samples_.empty()) {
    recorded_samples_.erase(
      recorded_samples_.begin(),
      recorded_samples_.begin() + kRecordingPart);
  }

  hr = audio_client_activation_handler_->capture_client->ReleaseBuffer(
      numFramesAvailable);

  if (FAILED(hr)) {
    RTC_LOG(LS_ERROR) << "SysAudioSource: Failed to release audio"
                      << " buffer. OS error: " << hr << ".";
    return false;
  }

  return true;
}

webrtc::scoped_refptr<bridge::LocalAudioSource> SysAudioSource::GetSource() {
  return source_;
}
