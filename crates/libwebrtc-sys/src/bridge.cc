#include <memory>
#include <string>
#include <cstdint>

#include "libwebrtc-sys/include/bridge.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace bridge {


// Calls `AudioDeviceModule->Create()`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    AudioLayer audio_layer,
    TaskQueueFactory &task_queue_factory
) {
  auto adm = webrtc::AudioDeviceModule::Create(
      audio_layer,
      &task_queue_factory
  );

  if (adm == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioDeviceModule>(adm);
};

// Calls `AudioDeviceModule->Init()`.
int32_t init_audio_device_module(
    const AudioDeviceModule &audio_device_module) {
  return audio_device_module->Init();
}

// Calls `AudioDeviceModule->PlayoutDevices()`.
int16_t playout_devices(
    const AudioDeviceModule &audio_device_module) {
  return audio_device_module->PlayoutDevices();
};

// Calls `AudioDeviceModule->RecordingDevices()`.
int16_t recording_devices(
    const AudioDeviceModule &audio_device_module) {
  return audio_device_module->RecordingDevices();
};

// Calls `AudioDeviceModule->PlayoutDeviceName()` with the provided arguments.
int32_t playout_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid) {

  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result = audio_device_module->PlayoutDeviceName(index,
                                                                name_buff,
                                                                guid_buff);
  name = name_buff;
  guid = guid_buff;

  return result;
};

// Calls `AudioDeviceModule->RecordingDeviceName()` with the provided arguments.
int32_t recording_device_name(
    const AudioDeviceModule &audio_device_module,
    int16_t index,
    rust::String &name,
    rust::String &guid
) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->RecordingDeviceName(index, name_buff, guid_buff);

  name = name_buff;
  guid = guid_buff;

  return result;
};

// Calls `VideoCaptureFactory->CreateDeviceInfo()`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
};

// Calls `VideoDeviceInfo->GetDeviceName()` with the provided arguments.
int32_t video_device_name(
    VideoDeviceInfo &device_info,
    uint32_t index,
    rust::String &name,
    rust::String &guid
) {
  char name_buff[256];
  char guid_buff[256];

  const int32_t
      size = device_info.GetDeviceName(index, name_buff, 256, guid_buff, 256);

  name = name_buff;
  guid = guid_buff;

  return size;
};

/// Calls `Thread->Create()`.
std::unique_ptr<Thread> create_thread() {
  return rtc::Thread::Create();
}

/// Calls `Thread->Start()`.
bool start_thread(Thread& thread) {
  return thread.Start();
}

/// Calls 'CreateBuiltinAudioEncoderFactory'
std::unique_ptr<AudioEncoderFactory> create_builtin_audio_encoder_factory() {
  rtc::scoped_refptr<webrtc::AudioEncoderFactory> builtin_audio_encoder_factory = webrtc::CreateBuiltinAudioEncoderFactory();
  return std::make_unique<AudioEncoderFactory>(builtin_audio_encoder_factory);
}

/// Calls 'CreateBuiltinAudioDecoderFactory'
std::unique_ptr<AudioDecoderFactory> create_builtin_audio_decoder_factory() {
  rtc::scoped_refptr<webrtc::AudioDecoderFactory> builtin_audio_encoder_factory = webrtc::CreateBuiltinAudioDecoderFactory();
  return std::make_unique<AudioDecoderFactory>(builtin_audio_encoder_factory);
}

/// Creates 'NULL AudioDeviceModule'
std::unique_ptr<AudioDeviceModule> create_audio_device_module_null() {
  return std::unique_ptr<AudioDeviceModule>(nullptr);
}

/// Creates 'NULL AudioMixer'
std::unique_ptr<AudioMixer> create_audio_mixer_null() {
  return std::unique_ptr<AudioMixer>(nullptr);
}

/// Creates 'NULL AudioProcessing'
std::unique_ptr<AudioProcessing> create_audio_processing_null() {
  return std::unique_ptr<AudioProcessing>(nullptr);
}

/// Creates 'NULL AudioFrameProcessor'
std::unique_ptr<AudioFrameProcessor> create_audio_frame_processor_null() {
  return std::unique_ptr<AudioFrameProcessor>(nullptr);
}

/// Calls `CreatePeerConnectionFactory()`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    Thread* network_thread,
    Thread* worker_thread,
    Thread* signaling_thread,
    AudioDeviceModule* default_adm,
    AudioEncoderFactory& audio_encoder_factory,
    AudioDecoderFactory& audio_decoder_factory,
    std::unique_ptr<VideoEncoderFactory> video_encoder_factory,
    std::unique_ptr<VideoDecoderFactory> video_decoder_factory,
    AudioMixer* audio_mixer,
    AudioProcessing* audio_processing,
    AudioFrameProcessor* audio_frame_processor) {
  return std::make_unique<PeerConnectionFactoryInterface>(
      webrtc::CreatePeerConnectionFactory(
          network_thread, worker_thread, signaling_thread, nullptr,
          audio_encoder_factory.ptr(),
          audio_decoder_factory.ptr(),
          std::move(video_encoder_factory),
          std::move(video_decoder_factory), 
          nullptr, nullptr,
          audio_frame_processor));
}

/// Creates a new Peer Connection.
std::unique_ptr<RTCErrorOr> create_peer_connection_or_error(      
      PeerConnectionFactoryInterface& peer_connection_factory,
      const RTCConfiguration& configuration,
      std::unique_ptr<PeerConnectionDependencies> dependencies) {
        PeerConnectionDependencies pcd = std::move(*(dependencies.get()));
        RTCErrorOr peer_connection = 
          peer_connection_factory.ptr()->CreatePeerConnectionOrError(configuration, std::move(pcd));
        return std::make_unique<RTCErrorOr>(std::move(peer_connection));
      }

/// Creates default RTCConfiguration.      
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration() {
  RTCConfiguration config;
  return std::make_unique<RTCConfiguration>(config);
}

/// Get error from RTCErrorOr.      
std::unique_ptr<RTCError> move_error(RTCErrorOr& rtc_error_or) {
  return std::make_unique<RTCError>(rtc_error_or.MoveError());
}

/// Get PeerConnectionInterface from RTCErrorOr.      
std::unique_ptr<PeerConnectionInterface> move_value(RTCErrorOr& rtc_error_or) {
  return std::make_unique<PeerConnectionInterface>(std::move(rtc_error_or.MoveValue()));
}

/// Create MyObserver.   
std::unique_ptr<MyObserver> create_my_observer() {
  MyObserver obs;
  return std::make_unique<MyObserver>(obs);
}

/// Create PeerConnectionDependencies.      
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
  std::unique_ptr<MyObserver> observer) {
  PeerConnectionDependencies pcd(observer.release());
    return std::make_unique<PeerConnectionDependencies>(std::move(pcd));
}

/// Check RTCErrorOr. 
bool rtc_error_or_is_ok(RTCErrorOr& rtc) {
  return rtc.ok();
}

/// Get RTCError message. 
const char* rtc_error_or_message(RTCError& rtc) {
  return rtc.message();
}


/// Create RTCOfferAnswerOptions
std::unique_ptr<RTCOfferAnswerOptions> create_default_rtc_offer_answer_options() {
  return std::make_unique<RTCOfferAnswerOptions>(RTCOfferAnswerOptions());
}

/// Call CreateOffer
void create_offer(PeerConnectionInterface* peer_connection_interface,
  const RTCOfferAnswerOptions& options) {
    peer_connection_interface->ptr()->CreateOffer(nullptr, options);
  }

/// Call CreateAnswer
void create_answer(PeerConnectionInterface* peer_connection_interface,
  const RTCOfferAnswerOptions& options) {
  peer_connection_interface->ptr()->CreateAnswer(nullptr, options);
}

/// Call setLocalDescription
void set_local_description(PeerConnectionInterface& peer_connection_interface,
  std::unique_ptr<SessionDescriptionInterface> desc) {
    peer_connection_interface.ptr()->SetLocalDescription(nullptr, desc.get());
  }

/// Call setRemoteDescription
void set_remote_description(PeerConnectionInterface& peer_connection_interface,
  std::unique_ptr<SessionDescriptionInterface> desc) {
    peer_connection_interface.ptr()->SetRemoteDescription(nullptr, desc.get());
  }
}
