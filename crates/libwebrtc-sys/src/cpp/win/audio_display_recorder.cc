#ifdef WEBRTC_WIN

#include "libwebrtc-sys/include/win/audio_display_recorder.h"
#include "rtc_base/logging.h"
#include <algorithm>

const auto CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const auto IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const auto IID_IAudioClient = __uuidof(IAudioClient);
const auto IID_IAudioCaptureClient = __uuidof(IAudioCaptureClient);

#define BITS_PER_BYTE 8
#define TEN_MS 100000
#define WAIT_SECOND 1000

HRESULT AudioClientActivationHandler::ActivateCompleted(
    IActivateAudioInterfaceAsyncOperation *activateOperation) {
    wil::com_ptr_nothrow<IUnknown> punkAudioInterface;

    HRESULT hr = activateOperation->GetActivateResult(
        &activateResult,
        &punkAudioInterface
    );

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get activation"
                                 << " result. OS error: " << hr << ".";
        return hr;
    }

    if (FAILED(activateResult)) {
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to activate audio"
                          << " interface. OS error: " << activateResult << ".";
        return activateResult;
    }

    hr = punkAudioInterface.copy_to(&audioClient);

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to copy audio"
                          << " client. OS error: " << hr << ".";
        return hr;
    }

    wFormat.wFormatTag = WAVE_FORMAT_PCM;
    wFormat.nChannels = kRecordingChannels;
    wFormat.nSamplesPerSec = kRecordingFrequency;
    wFormat.wBitsPerSample = kBitsPerSample;
    wFormat.nBlockAlign = wFormat.nChannels * wFormat.wBitsPerSample / BITS_PER_BYTE;
    wFormat.nAvgBytesPerSec = wFormat.nSamplesPerSec * wFormat.nBlockAlign;

    hr = audioClient->Initialize(
        AUDCLNT_SHAREMODE_SHARED,
        (AUDCLNT_STREAMFLAGS_LOOPBACK | AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM),
        TEN_MS,
        0,
        &wFormat,
        nullptr
    );

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to initialize audio"
                          << " client. OS error: " << hr << ".";
        return hr;
    }

    hr = audioClient->GetService(
        IID_IAudioCaptureClient,
        reinterpret_cast<void **>(&captureClient)
    );

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get"
                          << " IAudioCaptureClient. OS error: " << hr << ".";
        return hr;
    }

    hr = audioClient->Start();

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to start audio"
                          << " client. OS error: " << hr << ".";
        return hr;
    }

    activateResult = S_OK;
    hActivateCompleted.SetEvent();

    return S_OK;
}

AudioDisplayRecorder::AudioDisplayRecorder() {
    recorded_samples_.reserve(
        kRecordingPart * sizeof(int16_t) * kRecordingChannels * 2);
    source_ = bridge::LocalAudioSource::Create(
        webrtc::AudioOptions(),
        webrtc::scoped_refptr<webrtc::AudioProcessing>(nullptr)
    );
    audio_client_activation_handler_ = Make<AudioClientActivationHandler>();
}

bool AudioDisplayRecorder::StartCapture() {
    std::lock_guard<std::recursive_mutex> lock(mutex_);

    if (recording_ || recording_failed_) {
        return false;
    }

    HRESULT hr = audio_client_activation_handler_
        ->hActivateCompleted.create(wil::EventOptions::None);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to create audio"
                          << " client activation event handler. OS error: "
                          << hr << ".";
        recording_failed_ = true;
        return false;
    }

    AUDIOCLIENT_ACTIVATION_PARAMS audioclientActivationParams = {};
    audioclientActivationParams.ActivationType = AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK;
    audioclientActivationParams.ProcessLoopbackParams.ProcessLoopbackMode =
            PROCESS_LOOPBACK_MODE_EXCLUDE_TARGET_PROCESS_TREE;
    audioclientActivationParams.ProcessLoopbackParams.TargetProcessId = GetCurrentProcessId();

    PROPVARIANT activateParams = {};
    activateParams.vt = VT_BLOB;
    activateParams.blob.cbSize = sizeof(audioclientActivationParams);
    activateParams.blob.pBlobData = reinterpret_cast<BYTE *>(&audioclientActivationParams);

    wil::com_ptr_nothrow<IActivateAudioInterfaceAsyncOperation> asyncOp;

    hr = ActivateAudioInterfaceAsync(
        VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK,
        __uuidof(IAudioClient),
        &activateParams,
        audio_client_activation_handler_.get(),
        &asyncOp
    );

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to start"
                          << " AudioClient activation. OS error: "
                          << hr << ".";
        recording_failed_ = true;
        return false;
    }

    // Ignore result.
    static_cast<void>(
        audio_client_activation_handler_
            ->hActivateCompleted.wait(WAIT_SECOND)
    );

    recording_ = !FAILED(audio_client_activation_handler_->activateResult);

    return true;
}

void AudioDisplayRecorder::StopCapture() {
    std::lock_guard<std::recursive_mutex> lock(mutex_);

    if (!recording_) {
        return;
    }

    if (audio_client_activation_handler_->audioClient != nullptr) {
        // We are already cleaning up here so just ignore result.
        static_cast<void>(
            audio_client_activation_handler_->audioClient->Stop()
        );
        audio_client_activation_handler_->audioClient.reset();
    }

    if (audio_client_activation_handler_->captureClient != nullptr) {
        audio_client_activation_handler_->captureClient.reset();
    }

    recording_ = false;
}

bool AudioDisplayRecorder::ProcessRecordedPart(bool firstInCycle) {
    std::lock_guard<std::recursive_mutex> lock(mutex_);

    if (!recording_) {
        return false;
    }

    UINT32 packetLength = 0;

    HRESULT hr = audio_client_activation_handler_
        ->captureClient
        ->GetNextPacketSize(&packetLength);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get next audio"
                          << " packet size. OS error: " << hr << ".";
        return false;
    }

    if (packetLength == 0) {
        return false;
    }

    UINT32 numFramesAvailable = 0;
    DWORD flags = 0;
    BYTE *buffer = nullptr;

    hr = audio_client_activation_handler_->captureClient->GetBuffer(
        &buffer,
        &numFramesAvailable,
        &flags,
        nullptr,
        nullptr
    );

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get audio"
                          << " buffer. OS error: " << hr << ".";
        return false;
    }

    if (flags & AUDCLNT_BUFFERFLAGS_DATA_DISCONTINUITY) {
        RTC_LOG(LS_WARNING) << "AudioDisplayRecorder: "
                            << "AUDCLNT_BUFFERFLAGS_DATA_DISCONTINUITY.";
    }

    if (flags & AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR) {
        RTC_LOG(LS_WARNING) << "AudioDisplayRecorder: "
                            << "AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR.";
    }

    const auto audioData = reinterpret_cast<const int16_t *>(buffer);
    const auto remainingSamples = std::max<UINT32>(
        kRecordingPart - recorded_samples_.size(),
        0
    );

    if (flags & AUDCLNT_BUFFERFLAGS_SILENT) {
        recorded_samples_.insert(
            recorded_samples_.end(),
            remainingSamples,
            0
        );
    } else {
        if (numFramesAvailable > remainingSamples) {
            RTC_LOG(LS_WARNING) << "AudioDisplayRecorder: Cropping data. "
                    << "Too many data for 10 milliseconds.";
        }

        recorded_samples_.insert(
           recorded_samples_.end(),
           audioData,
           audioData + std::min<UINT32>(remainingSamples, numFramesAvailable)
        );
    }

    hr = audio_client_activation_handler_
        ->captureClient
        ->ReleaseBuffer(numFramesAvailable);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to release audio"
                          << " buffer. OS error: " << hr << ".";
        return false;
    }

    if (recorded_samples_.size() < kRecordingPart) {
        RTC_LOG(LS_WARNING) << "AudioDisplayRecorder: "
                            << "Not enough data for 10 milliseconds.";
        return false;
    }

    source_->OnData(
        recorded_samples_.data(), // audio_data
        kBitsPerSample,
        kRecordingFrequency, // sample_rate
        kRecordingChannels,
        kRecordingPart
    );
    recorded_samples_.clear();

    return true;
}

webrtc::scoped_refptr<bridge::LocalAudioSource> AudioDisplayRecorder::GetSource() {
    return source_;
}

#endif // WEBRTC_WIN
