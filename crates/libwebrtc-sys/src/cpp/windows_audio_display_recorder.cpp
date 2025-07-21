#include <windows.h>
#include <audioclient.h>

#include "libwebrtc-sys/include/windows_audio_display_recorder.h"

const CLSID CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const IID IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const IID IID_IAudioClient = __uuidof(IAudioClient);
const IID IID_IAudioCaptureClient = __uuidof(IAudioCaptureClient);

AudioDisplayRecorder::AudioDisplayRecorder() {
    _source = bridge::LocalAudioSource::Create(
        webrtc::AudioOptions(),
        webrtc::scoped_refptr<webrtc::AudioProcessing>(nullptr)
    );
}

void AudioDisplayRecorder::StartCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (_recording || _recordingFailed) {
        return;
    }

    _device = GetDefaultDevice();

    if (_device == nullptr) {
        _recordingFailed = true;
        goto Cleanup;
    }

    IAudioClient *pAudioClient = nullptr;

    HRESULT hr = _device->Activate(IID_IAudioCaptureClient, CLSCTX_ALL, nullptr,
                                   reinterpret_cast<void **>(&pAudioClient));

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    _audioClient = pAudioClient;

    WAVEFORMATEXTENSIBLE wFormat = GetWaveFormat();

    REFERENCE_TIME defaultPeriod = 0;
    REFERENCE_TIME minPeriod = 0;

    hr = _audioClient->GetDevicePeriod(&defaultPeriod, &minPeriod);

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    hr = _audioClient->Initialize(AUDCLNT_SHAREMODE_SHARED, AUDCLNT_STREAMFLAGS_LOOPBACK, minPeriod, 0,
                                  &wFormat.Format,
                                  nullptr);

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    UINT32 bufferFrameCount = 0;

    hr = _audioClient->GetBufferSize(&bufferFrameCount);

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    hr = _audioClient->GetService(IID_IAudioCaptureClient, reinterpret_cast<void **>(&_captureClient));

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    _hnsActualDuration = static_cast<double>(minPeriod) * bufferFrameCount / kRecordingFrequency;

    hr = _audioClient->Start();

    if (FAILED(hr)) {
        _recordingFailed = true;
        goto Cleanup;
    }

    _recording = true;

    return;

Cleanup:
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

void AudioDisplayRecorder::StopCapture() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);

    if (!_recording) {
        return;
    }

    if (_audioClient != nullptr) {
        // We are already cleaning up here so just ignore result.
        static_cast<void>(_audioClient->Stop());
        _audioClient->Release();
        _audioClient = nullptr;
    }

    if (_device != nullptr) {
        _device->Release();
        _device = nullptr;
    }

    if (_captureClient != nullptr) {
        _captureClient->Release();
        _captureClient = nullptr;
    }
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
        return false;
    }

    for (int i = 0; i < numFramesAvailable; ++i) {
        _recordedSamples->push_back(_buffer[i]);
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
        kRecordingFrequency * 10 / 1000
    );

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

WAVEFORMATEXTENSIBLE AudioDisplayRecorder::GetWaveFormat() {
    WAVEFORMATEXTENSIBLE wFormat;

    wFormat.Format.wFormatTag = WAVE_FORMAT_EXTENSIBLE;
    wFormat.Format.nChannels = kRecordingChannels;
    wFormat.Format.nSamplesPerSec = kRecordingFrequency;
    wFormat.Format.nAvgBytesPerSec = kRecordingFrequency * kRecordingChannels;
    wFormat.Format.nBlockAlign = kBlockAlign;
    wFormat.Format.wBitsPerSample = kBitsPerSample;
    wFormat.Format.cbSize = 22;
    // Setting a bit for each channel.
    wFormat.dwChannelMask = (1 << kRecordingChannels) - 1;
    wFormat.Samples.wValidBitsPerSample = kBitsPerSample;
    wFormat.SubFormat = KSDATAFORMAT_SUBTYPE_IEEE_FLOAT;

    return wFormat;
}
