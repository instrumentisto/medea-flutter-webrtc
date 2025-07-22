#ifdef WEBRTC_WIN

#include "libwebrtc-sys/include/windows_audio_display_recorder.h"

const CLSID CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const IID IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const IID IID_IAudioClient = __uuidof(IAudioClient);
const IID IID_IAudioCaptureClient = __uuidof(IAudioCaptureClient);

constexpr WORD stereoChannels = 2;
constexpr WORD BITS_IN_FLOAT = 32;

AudioDisplayRecorder::AudioDisplayRecorder() {
    _source = bridge::LocalAudioSource::Create(
        webrtc::AudioOptions(),
        webrtc::scoped_refptr<webrtc::AudioProcessing>(nullptr)
    );

    _recordedSamples->reserve(kRecordingPart);
}

void AudioDisplayRecorder::StartCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (_recording || _recordingFailed) {
        return;
    }

    _device = GetDefaultDevice();

    if (_device == nullptr) {
        _recordingFailed = true;
        return CleanupResources();
    }

    IAudioClient *pAudioClient = nullptr;

    HRESULT hr = _device->Activate(IID_IAudioClient, CLSCTX_ALL, nullptr,
                                   reinterpret_cast<void **>(&pAudioClient));

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    _audioClient = pAudioClient;

    hr = _audioClient->GetMixFormat(&_wFormat);

    if (FAILED(hr) || _wFormat->nChannels != stereoChannels || _wFormat->wBitsPerSample != BITS_IN_FLOAT) {
        // Unknown wave format. Stereo 32 bit is used for loopbacks in Windows.
        _recordingFailed = true;
        return CleanupResources();
    }

    REFERENCE_TIME defaultPeriod = 0;
    REFERENCE_TIME minPeriod = 0;

    hr = _audioClient->GetDevicePeriod(&defaultPeriod, &minPeriod);

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    hr = _audioClient->Initialize(AUDCLNT_SHAREMODE_SHARED, AUDCLNT_STREAMFLAGS_LOOPBACK, minPeriod, 0,
                                  _wFormat,
                                  nullptr);

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    UINT32 bufferFrameCount = 0;

    hr = _audioClient->GetBufferSize(&bufferFrameCount);

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    hr = _audioClient->GetService(IID_IAudioCaptureClient, reinterpret_cast<void **>(&_captureClient));

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    hr = _audioClient->Start();

    if (FAILED(hr)) {
        _recordingFailed = true;
        return CleanupResources();
    }

    _recording = true;
}

void AudioDisplayRecorder::StopCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (!_recording) {
        return;
    }

    if (_audioClient != nullptr) {
        // We are already cleaning up here so just ignore result.
        static_cast<void>(_audioClient->Stop());
    }

    CleanupResources();
}

bool AudioDisplayRecorder::ProcessRecordedPart(bool firstInCycle) {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (!_recording) {
        return false;
    }

    UINT32 packetLength = 0;

    HRESULT hr = _captureClient->GetNextPacketSize(&packetLength);

    if (FAILED(hr) || packetLength == 0) {
        return false;
    }

    UINT32 numFramesAvailable = 0;
    DWORD flags = 0;

    hr = _captureClient->GetBuffer(&_buffer, &numFramesAvailable, &flags, nullptr, nullptr);

    if (FAILED(hr)) {
        return false;
    }

    if (flags & AUDCLNT_BUFFERFLAGS_SILENT) {
        // No-op if buffer can't be released.
        static_cast<void>(_captureClient->ReleaseBuffer(numFramesAvailable));
        return false;
    }

    const auto stereoBuffer = reinterpret_cast<const float *>(_buffer);

    for (int i = 0; i < numFramesAvailable; ++i) {
        // Convert stereo 32 bit to mono 16 bit by averaging channels.
        const float monoSample = (stereoBuffer[i * stereoChannels] + stereoBuffer[i * stereoChannels + 1]) * 0.5;

        // Scale float to 16 bit int.
        float min = std::numeric_limits<int16_t>::min();
        float max = std::numeric_limits<int16_t>::max();
        float scaled = monoSample * max;
        scaled = std::max(min, std::min(max, scaled));

        _recordedSamples->push_back(static_cast<int16_t>(scaled));
    }

    hr = _captureClient->ReleaseBuffer(numFramesAvailable);

    if (FAILED(hr)) {
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

std::string AudioDisplayRecorder::GetDeviceId() const {
    PWSTR pDeviceId = nullptr;

    if (_device == nullptr) {
        return "";
    }

    if (const HRESULT hr = _device->GetId(&pDeviceId); FAILED(hr)) {
        return "";
    }

    std::wstring w(pDeviceId);
    std::string deviceId(w.begin(), w.end());

    CoTaskMemFree(pDeviceId);

    return deviceId;
}

IMMDevice *AudioDisplayRecorder::GetDefaultDevice() {
    IMMDeviceEnumerator *pEnumerator = nullptr;

    HRESULT hr = CoCreateInstance(
        CLSID_MMDeviceEnumerator,
        nullptr,
        CLSCTX_ALL,
        IID_IMMDeviceEnumerator,
        reinterpret_cast<void **>(&pEnumerator)
    );

    if (FAILED(hr)) {
        return nullptr;
    }

    IMMDevice *pDevice = nullptr;

    // Using eRender to capture data from audio rendering device.
    hr = pEnumerator->GetDefaultAudioEndpoint(eRender, eConsole, &pDevice);
    pEnumerator->Release();

    if (FAILED(hr)) {
        return nullptr;
    }

    return pDevice;
}

void AudioDisplayRecorder::CleanupResources() {
    if (_wFormat != nullptr) {
        CoTaskMemFree(_wFormat);
        _wFormat = nullptr;
    }

    if (_device != nullptr) {
        _device->Release();
        _device = nullptr;
    }

    if (_audioClient != nullptr) {
        _audioClient->Release();
        _audioClient = nullptr;
    }

    if (_captureClient != nullptr) {
        _captureClient->Release();
        _captureClient = nullptr;
    }
}

#endif // WEBRTC_WIN