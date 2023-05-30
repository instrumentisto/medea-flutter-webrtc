/*
 *  Copyright (c) 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include <iostream>

#include <chrono>
#include <thread>
#include "adm.h"
#include "api/make_ref_counted.h"
#include "common_audio/wav_file.h"
#include "modules/audio_device/include/test_audio_device.h"
#include "rtc_base/checks.h"
#include "rtc_base/logging.h"
#include "rtc_base/platform_thread.h"
#ifdef WEBRTC_WIN
#include "webrtc/win/webrtc_loopback_adm_win.h"
#endif // WEBRTC_WIN

constexpr auto kRecordingFrequency = 48000;
constexpr auto kPlayoutFrequency = 48000;
constexpr auto kRecordingChannels = 1;
constexpr auto kBufferSizeMs = crl::time(10);
constexpr auto kPlayoutPart = (kPlayoutFrequency * kBufferSizeMs + 999)
                              / 1000;
constexpr auto kRecordingPart = (kRecordingFrequency * kBufferSizeMs + 999)
                                / 1000;
constexpr auto kRecordingBufferSize = kRecordingPart * sizeof(int16_t)
                                      * kRecordingChannels;
constexpr auto kRestartAfterEmptyData = 50; // Half a second with no data.
constexpr auto kProcessInterval = crl::time(10);

constexpr auto kBuffersFullCount = 7;
constexpr auto kBuffersKeepReadyCount = 5;

constexpr auto kDefaultRecordingLatency = crl::time(20);
constexpr auto kDefaultPlayoutLatency = crl::time(20);
constexpr auto kQueryExactTimeEach = 20;

constexpr auto kALMaxValues = 6;
auto kAL_EVENT_CALLBACK_FUNCTION_SOFT = ALenum();
auto kAL_EVENT_CALLBACK_USER_PARAM_SOFT = ALenum();
auto kAL_EVENT_TYPE_BUFFER_COMPLETED_SOFT = ALenum();
auto kAL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT = ALenum();
auto kAL_EVENT_TYPE_DISCONNECTED_SOFT = ALenum();
auto kAL_SAMPLE_OFFSET_CLOCK_SOFT = ALenum();
auto kAL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT = ALenum();

auto kALC_DEVICE_LATENCY_SOFT = ALenum();

using AL_INT64_TYPE = std::int64_t;

using ALEVENTPROCSOFT = void(*)(
    ALenum eventType,
    ALuint object,
    ALuint param,
    ALsizei length,
    const ALchar *message,
    void *userParam);
using ALEVENTCALLBACKSOFT = void(*)(
    ALEVENTPROCSOFT callback,
    void *userParam);
using ALCSETTHREADCONTEXT = ALCboolean(*)(ALCcontext *context);
using ALGETSOURCEI64VSOFT = void(*)(
    ALuint source,
    ALenum param,
    AL_INT64_TYPE *values);
using ALCGETINTEGER64VSOFT = void(*)(
    ALCdevice *device,
    ALCenum pname,
    ALsizei size,
    AL_INT64_TYPE *values);

ALEVENTCALLBACKSOFT alEventCallbackSOFT/* = nullptr*/;
ALCSETTHREADCONTEXT alcSetThreadContext/* = nullptr*/;
ALGETSOURCEI64VSOFT alGetSourcei64vSOFT/* = nullptr*/;
ALCGETINTEGER64VSOFT alcGetInteger64vSOFT/* = nullptr*/;

struct CustomAudioDeviceModule::Data {
	Data() {
		_playoutThread = rtc::Thread::Create();
	}

	std::unique_ptr<rtc::Thread> _playoutThread;

//	QByteArray playoutSamples;
	ALuint source = 0;
	int queuedBuffersCount = 0;
	std::array<ALuint, kBuffersFullCount> buffers = { { 0 } };
	std::array<bool, kBuffersFullCount> queuedBuffers = { { false } };
	int64_t exactDeviceTimeCounter = 0;
	int64_t lastExactDeviceTime = 0;
	crl::time lastExactDeviceTimeWhen = 0;
	bool playing = false;
};

// Main initializaton and termination
int32_t CustomAudioDeviceModule::Init() {
  RTC_LOG(LS_ERROR) << "Initializing AudioDeviceModule 1";
  if (webrtc::AudioDeviceModuleImpl::Init() != 0) {
    return -1;
  }

  if (_initialized) {
    return 0;
  }
  alcSetThreadContext = (ALCSETTHREADCONTEXT)alcGetProcAddress(
      nullptr,
      "alcSetThreadContext");
  if (!alcSetThreadContext) {
    return -1;
  }
  alEventCallbackSOFT = (ALEVENTCALLBACKSOFT)alcGetProcAddress(
      nullptr,
      "alEventCallbackSOFT");

  alGetSourcei64vSOFT = (ALGETSOURCEI64VSOFT)alcGetProcAddress(
      nullptr,
      "alGetSourcei64vSOFT");

  alcGetInteger64vSOFT = (ALCGETINTEGER64VSOFT)alcGetProcAddress(
      nullptr,
      "alcGetInteger64vSOFT");

#define RESOLVE_ENUM(ENUM) k##ENUM = alcGetEnumValue(nullptr, #ENUM)
  RESOLVE_ENUM(AL_EVENT_CALLBACK_FUNCTION_SOFT);
  RESOLVE_ENUM(AL_EVENT_CALLBACK_FUNCTION_SOFT);
  RESOLVE_ENUM(AL_EVENT_CALLBACK_USER_PARAM_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_BUFFER_COMPLETED_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_SOURCE_STATE_CHANGED_SOFT);
  RESOLVE_ENUM(AL_EVENT_TYPE_DISCONNECTED_SOFT);
  RESOLVE_ENUM(AL_SAMPLE_OFFSET_CLOCK_SOFT);
  RESOLVE_ENUM(AL_SAMPLE_OFFSET_CLOCK_EXACT_SOFT);
  RESOLVE_ENUM(ALC_DEVICE_LATENCY_SOFT);
#undef RESOLVE_ENUM
  RTC_LOG(LS_ERROR) << "Initializing AudioDeviceModule 2";

  _initialized = true;
  RTC_LOG(LS_ERROR) << "Initializing AudioDeviceModule 3";

  return audio_recorder->Init();
};

int32_t CustomAudioDeviceModule::Terminate() {
  quit = true;
  return 0;
}

CustomAudioDeviceModule::~CustomAudioDeviceModule() {
  Terminate();
}

rtc::scoped_refptr<CustomAudioDeviceModule> CustomAudioDeviceModule::Create(
    AudioLayer audio_layer,
    webrtc::TaskQueueFactory* task_queue_factory) {
  return CustomAudioDeviceModule::CreateForTest(audio_layer,
                                                task_queue_factory);
}

int32_t CustomAudioDeviceModule::SetRecordingDevice(uint16_t index) {
  return audio_recorder->SetRecordingDevice(index);
}

int32_t CustomAudioDeviceModule::InitMicrophone() {
  return audio_recorder->InitMicrophone();
}

bool CustomAudioDeviceModule::MicrophoneIsInitialized() const {
  return audio_recorder->MicrophoneIsInitialized();
}

rtc::scoped_refptr<AudioSource> CustomAudioDeviceModule::CreateSystemSource() {
  // TODO implement system sound capture.
  return nullptr;
}

rtc::scoped_refptr<AudioSource>
CustomAudioDeviceModule::CreateMicrophoneSource() {
  auto microphone = audio_recorder->CreateSource();
  return microphone;
}

void CustomAudioDeviceModule::AddSource(
    rtc::scoped_refptr<AudioSource> source) {
  {
    std::unique_lock<std::mutex> lock(source_mutex);
    sources.push_back(source);
  }
  cv.notify_all();
  mixer->AddSource(source.get());
}

void CustomAudioDeviceModule::RemoveSource(
    rtc::scoped_refptr<AudioSource> source) {
  {
    std::unique_lock<std::mutex> lock(source_mutex);
    for (int i = 0; i < sources.size(); ++i) {
      if (sources[i] == source) {
        sources.erase(sources.begin() + i);
        break;
      }
    }
  }
  mixer->RemoveSource(source.get());
}

// Microphone mute control
int32_t CustomAudioDeviceModule::MicrophoneVolumeIsAvailable(bool* available) {
  return audio_recorder->MicrophoneVolumeIsAvailable(available);
}
int32_t CustomAudioDeviceModule::SetMicrophoneVolume(uint32_t volume) {
  return audio_recorder->SetMicrophoneVolume(volume);
}
int32_t CustomAudioDeviceModule::MicrophoneVolume(uint32_t* volume) const {
  return audio_recorder->MicrophoneVolume(volume);
}
int32_t CustomAudioDeviceModule::MaxMicrophoneVolume(
    uint32_t* maxVolume) const {
  return audio_recorder->MaxMicrophoneVolume(maxVolume);
}
int32_t CustomAudioDeviceModule::MinMicrophoneVolume(
    uint32_t* minVolume) const {
  return audio_recorder->MinMicrophoneVolume(minVolume);
}
int32_t CustomAudioDeviceModule::MicrophoneMuteIsAvailable(bool* available) {
  return audio_recorder->MicrophoneMuteIsAvailable(available);
}
int32_t CustomAudioDeviceModule::SetMicrophoneMute(bool enable) {
  return audio_recorder->SetMicrophoneMute(enable);
}
int32_t CustomAudioDeviceModule::MicrophoneMute(bool* enabled) const {
  return audio_recorder->MicrophoneMute(enabled);
}

// Audio device module delegates StartRecording to `audio_recorder`.
int32_t CustomAudioDeviceModule::StartRecording() {
  return 0;
}

rtc::scoped_refptr<CustomAudioDeviceModule>
CustomAudioDeviceModule::CreateForTest(
    AudioLayer audio_layer,
    webrtc::TaskQueueFactory* task_queue_factory) {
  // The "AudioDeviceModule::kWindowsCoreAudio2" audio layer has its own
  // dedicated factory method which should be used instead.
  if (audio_layer == AudioDeviceModule::kWindowsCoreAudio2) {
    return nullptr;
  }

  // Create the generic reference counted (platform independent) implementation.
  auto audio_device = rtc::make_ref_counted<CustomAudioDeviceModule>(
      audio_layer, task_queue_factory);

  // Ensure that the current platform is supported.
  if (audio_device->CheckPlatform() == -1) {
    return nullptr;
  }

  // Create the platform-dependent implementation.
  if (audio_device->CreatePlatformSpecificObjects() == -1) {
    return nullptr;
  }

  // Ensure that the generic audio buffer can communicate with the platform
  // specific parts.
  if (audio_device->AttachAudioBuffer() == -1) {
    return nullptr;
  }

  audio_device->RecordProcess();

  return audio_device;
}

CustomAudioDeviceModule::CustomAudioDeviceModule(
    AudioLayer audio_layer,
    webrtc::TaskQueueFactory* task_queue_factory)
    : webrtc::AudioDeviceModuleImpl(audio_layer, task_queue_factory),
      _audioDeviceBuffer(task_queue_factory),
      audio_recorder(std::move(std::unique_ptr<MicrophoneModuleInterface>(new MicrophoneModule()))) {
}

void CustomAudioDeviceModule::RecordProcess() {
  const auto attributes =
      rtc::ThreadAttributes().SetPriority(rtc::ThreadPriority::kRealtime);

  recordingThread = rtc::PlatformThread::SpawnJoinable(
      [this] {
        webrtc::AudioFrame frame;
        auto cb = GetAudioDeviceBuffer();
        while (!quit) {
          {
            std::unique_lock<std::mutex> lock(source_mutex);
            cv.wait(lock, [&]() { return sources.size() > 0; });
          }

          mixer->Mix(audio_recorder->RecordingChannels(), &frame);
          cb->SetRecordingChannels(frame.num_channels());
          cb->SetRecordingSampleRate(frame.sample_rate_hz());
          cb->SetRecordedBuffer(frame.data(), frame.sample_rate_hz() / 100);
          cb->DeliverRecordedData();
        }
      },
      "audio_device_module_rec_thread", attributes);
}

template <typename Callback>
void EnumerateDevices(ALCenum specifier, Callback &&callback) {
  auto devices = alcGetString(nullptr, specifier);
  while (*devices != 0) {
    callback(devices);
    while (*devices != 0) {
      ++devices;
    }
    ++devices;
  }
}

[[nodiscard]] int DevicesCount(ALCenum specifier) {
  auto result = 0;
  EnumerateDevices(specifier, [&](const char *device) {
    ++result;
  });
  return result;
}

[[nodiscard]] std::string ComputeDefaultDeviceId(ALCenum specifier) {
    const auto device = alcGetString(nullptr, specifier);
    return device ? std::string(device) : std::string();
}

[[nodiscard]] int DeviceName(
    ALCenum specifier,
    int index,
    std::string *name,
    std::string *guid) {
  EnumerateDevices(specifier, [&](const char *device) {
    if (index < 0) {
      return;
    } else if (index > 0) {
      --index;
      return;
    }

    auto string = std::string(device);
    if (name) {
      if (guid) {
        *guid = string;
      }
      const auto prefix = std::string("OpenAL Soft on ");
      if (string.rfind(prefix, 0) == 0) {
        string = string.substr(prefix.size());
      }
      *name = std::move(string);
    } else if (guid) {
      *guid = std::move(string);
    }
    index = -1;
  });
  return (index > 0) ? -1 : 0;
}

void SetStringToArray(const std::string &string, char *array, int size) {
  const auto length = std::min(int(string.size()), size - 1);
  if (length > 0) {
    memcpy(array, string.data(), length);
  }
  array[length] = 0;
}

[[nodiscard]] int DeviceName(
    ALCenum specifier,
    int index,
    char name[webrtc::kAdmMaxDeviceNameSize],
    char guid[webrtc::kAdmMaxGuidSize]) {
    auto sname = std::string();
    auto sguid = std::string();
    const auto result = DeviceName(specifier, index, &sname, &sguid);
    if (result) {
      return result;
    }
    SetStringToArray(sname, name, webrtc::kAdmMaxDeviceNameSize);
    SetStringToArray(sguid, guid, webrtc::kAdmMaxGuidSize);
  return 0;
}

int32_t CustomAudioDeviceModule::SetPlayoutDevice(uint16_t index) {
  const auto result = DeviceName(
      ALC_ALL_DEVICES_SPECIFIER,
      index,
      nullptr,
      &_playoutDeviceId);
  return result ? result : restartPlayout();
}

int32_t CustomAudioDeviceModule::SetPlayoutDevice(WindowsDeviceType /*device*/) {
  _playoutDeviceId = ComputeDefaultDeviceId(ALC_DEFAULT_DEVICE_SPECIFIER);
  return _playoutDeviceId.empty() ? -1 : restartPlayout();
}

int CustomAudioDeviceModule::restartPlayout() {
  if (!_data || !_data->playing) {
    return 0;
  }
  stopPlayingOnThread();
  closePlayoutDevice();
  if (!validatePlayoutDeviceId()) {
    _data->_playoutThread->Invoke<void>(RTC_FROM_HERE, [this] {
        _data->playing = true;
        _playoutFailed = true;
    });
    return 0;
  }
  _playoutFailed = false;
  RTC_LOG(LS_ERROR) << "restartPlayout 1";
  openPlayoutDevice();
  startPlayingOnThread();

  return 0;
}

int16_t CustomAudioDeviceModule::PlayoutDevices() {
  return DevicesCount(ALC_ALL_DEVICES_SPECIFIER);
}

int32_t CustomAudioDeviceModule::PlayoutDeviceName(
    uint16_t index,
    char name[webrtc::kAdmMaxDeviceNameSize],
    char guid[webrtc::kAdmMaxGuidSize]) {
  return DeviceName(ALC_ALL_DEVICES_SPECIFIER, index, name, guid);
}

// TODO: 1111111111
int32_t CustomAudioDeviceModule::InitPlayout() {
  if (!_initialized) {
    return -1;
  } else if (_playoutInitialized) {
    return 0;
  }
  _playoutInitialized = true;

  RTC_LOG(LS_ERROR) << "InitPlayout 1";
  ensureThreadStarted();
  RTC_LOG(LS_ERROR) << "InitPlayout 2";
  openPlayoutDevice();
  RTC_LOG(LS_ERROR) << "InitPlayout 3";
  return 0;
}

bool CustomAudioDeviceModule::PlayoutIsInitialized() const {
  return _playoutInitialized;
}

// TODO: 222222222222
int32_t CustomAudioDeviceModule::StartPlayout() {
    RTC_LOG(LS_ERROR) << "StartPlayout 1";
  if (!_playoutInitialized) {
    return -1;
  } else if (Playing()) {
    return 0;
  }
  RTC_LOG(LS_ERROR) << "StartPlayout 2";
  if (_playoutFailed) {
    _playoutFailed = false;
    RTC_LOG(LS_ERROR) << "StartPlayout 3";
    openPlayoutDevice();
  }
  RTC_LOG(LS_ERROR) << "StartPlayout 4";
  _audioDeviceBuffer.SetPlayoutSampleRate(kPlayoutFrequency);
  _audioDeviceBuffer.SetPlayoutChannels(_playoutChannels);
  _audioDeviceBuffer.StartPlayout();
//  TODO: startPlayingOnThread();
  return 0;
}

int32_t CustomAudioDeviceModule::StopPlayout() {
  if (_data) {
    stopPlayingOnThread();
    _audioDeviceBuffer.StopPlayout();
    _data->_playoutThread->Stop();
    _data = nullptr;
  }
  closePlayoutDevice();
  _playoutInitialized = false;
  return 0;
}

bool CustomAudioDeviceModule::Playing() const {
  return _data && _data->playing;
}

int32_t CustomAudioDeviceModule::InitSpeaker() {
  _speakerInitialized = true;
  return 0;
}

bool CustomAudioDeviceModule::SpeakerIsInitialized() const {
  return _speakerInitialized;
}

int32_t CustomAudioDeviceModule::StereoPlayoutIsAvailable(bool *available) const {
  if (available) {
    *available = true;
  }
  return 0;
}

int32_t CustomAudioDeviceModule::SetStereoPlayout(bool enable) {
  if (Playing()) {
    return -1;
  }
  _playoutChannels = enable ? 2 : 1;
  return 0;
}

int32_t CustomAudioDeviceModule::StereoPlayout(bool *enabled) const {
  if (enabled) {
    *enabled = (_playoutChannels == 2);
  }
  return 0;
}

int32_t CustomAudioDeviceModule::PlayoutDelay(uint16_t *delayMS) const {
  if (delayMS) {
    *delayMS = 0;
  }
  return 0;
}

int32_t CustomAudioDeviceModule::SpeakerVolumeIsAvailable(bool *available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t CustomAudioDeviceModule::SetSpeakerVolume(uint32_t volume) {
  return -1;
}

int32_t CustomAudioDeviceModule::SpeakerVolume(uint32_t *volume) const {
  return -1;
}

int32_t CustomAudioDeviceModule::MaxSpeakerVolume(uint32_t *maxVolume) const {
  return -1;
}

int32_t CustomAudioDeviceModule::MinSpeakerVolume(uint32_t *minVolume) const {
  return -1;
}

int32_t CustomAudioDeviceModule::SpeakerMuteIsAvailable(bool *available) {
  if (available) {
    *available = false;
  }
  return 0;
}

int32_t CustomAudioDeviceModule::SetSpeakerMute(bool enable) {
  return -1;
}

int32_t CustomAudioDeviceModule::SpeakerMute(bool *enabled) const {
  if (enabled) {
    *enabled = false;
  }
  return 0;
}

void CustomAudioDeviceModule::openPlayoutDevice() {
  RTC_LOG(LS_ERROR) << "openPlayoutDevice 1";
  if (_playoutDevice || _playoutFailed) {
    return;
  }
  _playoutDevice = alcOpenDevice(_playoutDeviceId.empty() ? nullptr : _playoutDeviceId.c_str());
  if (!_playoutDevice) {
    RTC_LOG(LS_ERROR)
        << "OpenAL Device open failed, deviceID: '"
        << _playoutDeviceId
        << "'";
    _playoutFailed = true;
    return;
  }
RTC_LOG(LS_ERROR) << "openPlayoutDevice 2";
  _playoutContext = alcCreateContext(_playoutDevice, nullptr);
  if (!_playoutContext) {
    RTC_LOG(LS_ERROR) << "OpenAL Context create failed.";
    _playoutFailed = true;
    closePlayoutDevice();
    return;
  }
 RTC_LOG(LS_ERROR) << "openPlayoutDevice 3";
      _data->_playoutThread->Invoke<void>(RTC_FROM_HERE, [this] {
      /*
        alcSetThreadContext(_playoutContext);
        if (alEventCallbackSOFT) {
            alEventCallbackSOFT([](
                ALenum eventType,
                ALuint object,
                ALuint param,
                ALsizei length,
                const ALchar *message,
                void *that) {
                     static_cast<CustomAudioDeviceModule*>(that)->handleEvent(
                       eventType,
                       object,
                       param,
                       length,
                       message);
               }, this);
           }
           */
      });
  RTC_LOG(LS_ERROR) << "openPlayoutDevice 4";
}

void CustomAudioDeviceModule::handleEvent(
		ALenum eventType,
		ALuint object,
		ALuint param,
		ALsizei length,
		const ALchar *message) {
	if (eventType == kAL_EVENT_TYPE_DISCONNECTED_SOFT && _thread) {
        /*
		const auto weak = QPointer<QObject>(&_data->context);
		_thread->PostTask([=] {
			if (weak) {
				// restartRecording();
			}
		});
		*/
	}
}

void CustomAudioDeviceModule::ensureThreadStarted() {
	if (_data) {
		return;
	}
	_thread = rtc::Thread::Current();
    if (_thread && !_thread->IsOwned()) {
    	_thread->UnwrapCurrent();
    	_thread = nullptr;
    }
    _data = std::make_unique<Data>();

    _data->_playoutThread->Start();
    _thread->AllowInvokesToThread(_data->_playoutThread.get());

	_data->_playoutThread->PostTask(
      [=] {
        // while (processPlayout()) { }
      });
/*
    if (_thread && !_thread->IsOwned()) {
		_thread->UnwrapCurrent();
		_thread = nullptr;
	}
	//	Assert(_thread != nullptr);
	//	Assert(_thread->IsOwned());

	_data = std::make_unique<Data>();
	_data->timer.setCallback([=] { processData(); });
	_data->thread.setObjectName("Webrtc OpenAL Thread");
	_data->thread.start(QThread::TimeCriticalPriority);
*/
}

[[nodiscard]] bool Failed(ALCdevice *device) {
	if (auto code = alcGetError(device); code != ALC_NO_ERROR) {
		RTC_LOG(LS_ERROR)
			<< "OpenAL Error "
			<< code
			<< ": "
			<< (const char *)alcGetString(device, code);
		return true;
	}
	return false;
}

bool CustomAudioDeviceModule::processPlayout() {
/*
	const auto playing = [&] {
		auto state = ALint(AL_INITIAL);
		alGetSourcei(_data->source, AL_SOURCE_STATE, &state);
		return (state == AL_PLAYING);
	};
	const auto wasPlaying = playing();

	if (wasPlaying) {
		clearProcessedBuffers();
	} else {
		unqueueAllBuffers();
	}

	const auto wereQueued = _data->queuedBuffers;
	while (_data->queuedBuffersCount < kBuffersKeepReadyCount) {
		const auto available = _audioDeviceBuffer.RequestPlayoutData(
			kPlayoutPart);
		if (available == kPlayoutPart) {
			_audioDeviceBuffer.GetPlayoutData(_data->playoutSamples.data());
		} else {
			//ranges::fill(_data->playoutSamples, 0);
			break;
		}
		const auto now = crl::now();
		_playoutLatency = countExactQueuedMsForLatency(now, wasPlaying);
		//RTC_LOG(LS_ERROR) << "PLAYOUT LATENCY: " << _playoutLatency << "ms";

		const auto i = std::range::find(_data->queuedBuffers, false);
		const auto index = int(i - std::begin(_data->queuedBuffers));
		alBufferData(
			_data->buffers[index],
			(_playoutChannels == 2) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16,
			_data->playoutSamples.data(),
			_data->playoutSamples.size(),
			kPlayoutFrequency);

#ifdef WEBRTC_WIN
		if (IsLoopbackCaptureActive() && _playoutChannels == 2) {
			LoopbackCapturePushFarEnd(
				now + _playoutLatency,
				_data->playoutSamples,
				kPlayoutFrequency,
				_playoutChannels);
		}
#endif // WEBRTC_WIN

		_data->queuedBuffers[index] = true;
		++_data->queuedBuffersCount;
		if (wasPlaying) {
			alSourceQueueBuffers(
				_data->source,
				1,
				_data->buffers.data() + index);
		}
	}
	if (!_data->queuedBuffersCount) {
		return;
	}
	if (!playing()) {
		if (wasPlaying) {
			// While we were queueing buffers the source stopped.
			// Now we can't unqueue only old buffers, so we unqueue all
			// of them and then re-queue the ones we queued right now.
			unqueueAllBuffers();
			for (auto i = 0; i != int(_data->buffers.size()); ++i) {
				if (!wereQueued[i] && _data->queuedBuffers[i]) {
					alSourceQueueBuffers(
						_data->source,
						1,
						_data->buffers.data() + i);
				}
			}
		} else {
			// We were not playing and had no buffers,
			// so queue them all at once.
			alSourceQueueBuffers(
				_data->source,
				_data->queuedBuffersCount,
				_data->buffers.data());
		}
		alSourcePlay(_data->source);
	}

	if (Failed(_playoutDevice)) {
		_playoutFailed = true;
	}

*/
    return true;
}

void CustomAudioDeviceModule::closePlayoutDevice() {
	if (_playoutContext) {
		alcDestroyContext(_playoutContext);
		_playoutContext = nullptr;
	}
	if (_playoutDevice) {
		alcCloseDevice(_playoutDevice);
		_playoutDevice = nullptr;
	}
}

bool CustomAudioDeviceModule::validatePlayoutDeviceId() {
	auto valid = false;
	EnumerateDevices(ALC_ALL_DEVICES_SPECIFIER, [&](const char *device) {
		if (!valid && _playoutDeviceId == std::string(device)) {
			valid = true;
		}
	});
	if (valid) {
		return true;
	}
	const auto defaultDeviceId = ComputeDefaultDeviceId(
		ALC_DEFAULT_DEVICE_SPECIFIER);
	if (!defaultDeviceId.empty()) {
		_playoutDeviceId = defaultDeviceId;
		return true;
	}
	RTC_LOG(LS_ERROR) << "Could not find any OpenAL devices.";
	return false;
}

void CustomAudioDeviceModule::startPlayingOnThread() {
  _data->_playoutThread->Invoke<void>(RTC_FROM_HERE, [this] {
        _data->playing = true;
		if (_playoutFailed) {
			return;
		}
		ALuint source = 0;
		alGenSources(1, &source);
		if (source) {
			alSourcef(source, AL_PITCH, 1.f);
			alSource3f(source, AL_POSITION, 0, 0, 0);
			alSource3f(source, AL_VELOCITY, 0, 0, 0);
			alSourcei(source, AL_LOOPING, 0);
			alSourcei(source, AL_SOURCE_RELATIVE, 1);
			alSourcei(source, AL_ROLLOFF_FACTOR, 0);
			if (alIsExtensionPresent("AL_SOFT_direct_channels_remix")) {
				alSourcei(
					source,
					alGetEnumValue("AL_DIRECT_CHANNELS_SOFT"),
					alGetEnumValue("AL_REMIX_UNMATCHED_SOFT"));
			}
			_data->source = source;
			alGenBuffers(_data->buffers.size(), _data->buffers.data());

			_data->exactDeviceTimeCounter = 0;
			_data->lastExactDeviceTime = 0;
			_data->lastExactDeviceTimeWhen = 0;

			const auto bufferSize = kPlayoutPart * sizeof(int16_t)
				* _playoutChannels;

			// _data->playoutSamples = QByteArray(bufferSize, 0);

			// if (!_data->timer.isActive()) {
			//	_data->timer.callEach(kProcessInterval);
			// }
		}
  });
}

void CustomAudioDeviceModule::stopPlayingOnThread() {
	//Expects(_data != nullptr);
 /*
	sync([&] {
		const auto guard = gsl::finally([&] {
			if (alEventCallbackSOFT) {
				alEventCallbackSOFT(nullptr, nullptr);
			}
			alcSetThreadContext(nullptr);
		});
		if (!_data->playing) {
			return;
		}
		_data->playing = false;
		if (_playoutFailed) {
			return;
		}
		if (!_data->recording) {
			_data->timer.cancel();
		}
		if (_data->source) {
			alSourceStop(_data->source);
			unqueueAllBuffers();
			alDeleteBuffers(_data->buffers.size(), _data->buffers.data());
			alDeleteSources(1, &_data->source);
			_data->source = 0;
			ranges::fill(_data->buffers, ALuint(0));
		}
	});
	*/
}
