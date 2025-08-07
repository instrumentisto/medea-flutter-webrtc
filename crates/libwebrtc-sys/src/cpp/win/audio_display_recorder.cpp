#ifdef WEBRTC_WIN

#include "libwebrtc-sys/include/win/audio_display_recorder.h"
#include "rtc_base/logging.h"

const auto CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const auto IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const auto IID_IAudioClient = __uuidof(IAudioClient);
const auto IID_IAudioCaptureClient = __uuidof(IAudioCaptureClient);

#define BITS_PER_BYTE 8
#define TEN_MS 100000

HRESULT AudioClientActivationHandler::ActivateCompleted(IActivateAudioInterfaceAsyncOperation *activateOperation) {
    HRESULT hrActivateResult = E_UNEXPECTED;
    wil::com_ptr_nothrow<IUnknown> punkAudioInterface;

    HRESULT hr = activateOperation->GetActivateResult(&hrActivateResult, &punkAudioInterface);

    if (FAILED(hrActivateResult)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to activate audio"
                          << " interface. OS error: " << hr << ".";
        return S_OK;
    }

    hr = punkAudioInterface.copy_to(&audioClient);

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to copy audio"
                          << " client. OS error: " << hr << ".";
        return S_OK;
    }

    wFormat.wFormatTag = WAVE_FORMAT_PCM;
    wFormat.nChannels = kRecordingChannels;
    wFormat.nSamplesPerSec = kRecordingFrequency;
    wFormat.wBitsPerSample = kBitsPerSample;
    wFormat.nBlockAlign = wFormat.nChannels * wFormat.wBitsPerSample / BITS_PER_BYTE;
    wFormat.nAvgBytesPerSec = wFormat.nSamplesPerSec * wFormat.nBlockAlign;

    hr = audioClient->Initialize(AUDCLNT_SHAREMODE_SHARED,
                                 (AUDCLNT_STREAMFLAGS_LOOPBACK | AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM), TEN_MS, 0,
                                 &wFormat,
                                 nullptr);

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to initialize audio"
                          << " client. OS error: " << hr << ".";
        return S_OK;
    }

    hr = audioClient->GetService(IID_IAudioCaptureClient, reinterpret_cast<void **>(&captureClient));

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get"
                          << " IAudioCaptureClient. OS error: " << hr << ".";
        return S_OK;
    }

    hr = audioClient->Start();

    if (FAILED(hr)) {
        activateResult = hr;
        hActivateCompleted.SetEvent();
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to start audio"
                          << " client. OS error: " << hr << ".";
        return S_OK;
    }

    activateResult = S_OK;
    hActivateCompleted.SetEvent();

    return S_OK;
}

AudioDisplayRecorder::AudioDisplayRecorder() {
    _source = bridge::LocalAudioSource::Create(
        webrtc::AudioOptions(),
        webrtc::scoped_refptr<webrtc::AudioProcessing>(nullptr)
    );
    _audioClientActivationHandler = Make<AudioClientActivationHandler>();
}

void AudioDisplayRecorder::StartCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (_recording || _recordingFailed) {
        return;
    }

    HRESULT hr = _audioClientActivationHandler->hActivateCompleted.create(wil::EventOptions::None);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to create audio"
                          << " client activation event handler. OS error:
                          << hr << ".";
        _recordingFailed = true;
        return;
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
        VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK, __uuidof(IAudioClient), &activateParams,
        _audioClientActivationHandler.get(), &asyncOp);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to start
                          << " AudioClient activation. OS error: "
                          << hr << ".";
        _recordingFailed = true;
        return;
    }

    // Ignore result.
    static_cast<void>(_audioClientActivationHandler->hActivateCompleted.wait());

    _recording = !FAILED(_audioClientActivationHandler->activateResult);
}

void AudioDisplayRecorder::StopCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (!_recording) {
        return;
    }

    if (_audioClientActivationHandler->audioClient != nullptr) {
        // We are already cleaning up here so just ignore result.
        static_cast<void>(_audioClientActivationHandler->audioClient->Stop());
    }

    _recording = false;
}

bool AudioDisplayRecorder::ProcessRecordedPart(bool firstInCycle) {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (!_recording) {
        return false;
    }

    UINT32 packetLength = 0;

    HRESULT hr = _audioClientActivationHandler->captureClient->GetNextPacketSize(&packetLength);

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

    hr = _audioClientActivationHandler->captureClient->GetBuffer(&_buffer, &numFramesAvailable, &flags, nullptr,
                                                                 nullptr);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to get audio"
                          << " buffer. OS error: " << hr << ".";
        return false;
    }

    if (flags & AUDCLNT_BUFFERFLAGS_SILENT) {
        // No-op if buffer can't be released.
        static_cast<void>(_audioClientActivationHandler->captureClient->ReleaseBuffer(numFramesAvailable));
        return false;
    }

    const auto buffer = reinterpret_cast<const int16_t *>(_buffer);

    for (int i = 0; i < numFramesAvailable; ++i) {
        _recordedSamples->push_back(buffer[i]);
    }

    hr = _audioClientActivationHandler->captureClient->ReleaseBuffer(numFramesAvailable);

    if (FAILED(hr)) {
        RTC_LOG(LS_ERROR) << "AudioDisplayRecorder: Failed to release audio"
                          << " buffer. OS error: " << hr << ".";
        return false;
    }

    if (_recordedSamples->size() < kRecordingPart) {
        // Not enough data for 10 milliseconds.
        return false;
    }

    _source->OnData(
        _recordedSamples->data(), // audio_data
        kBitsPerSample,
        kRecordingFrequency, // sample_rate
        kRecordingChannels,
        _recordedSamples->size()
    );
    _recordedSamples->clear();

    return true;
}

webrtc::scoped_refptr<bridge::LocalAudioSource> AudioDisplayRecorder::GetSource() {
    return _source;
}

#endif // WEBRTC_WIN
