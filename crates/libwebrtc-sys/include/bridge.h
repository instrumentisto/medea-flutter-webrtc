#pragma once

#include <memory>
#include <string>
#include <iostream>

#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "rust/cxx.h"

namespace bridge {
    template <class T>
    class RefCounted {
     public:
      typedef T element_type;
      RefCounted(rtc::scoped_refptr<T> p) : ptr_(p.release()) { }
      ~RefCounted() {
        ptr_->Release();
      }
      T* ptr() const {
        return ptr_;
      }
      T* operator -> () const {
        return ptr_;
      }
     protected:
      T* ptr_;
    };

    using TaskQueueFactory = webrtc::TaskQueueFactory;
    using AudioDeviceModule = RefCounted<webrtc::AudioDeviceModule>;
    using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
    using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;

    std::unique_ptr<AudioDeviceModule> create_audio_device_module(
      AudioLayer audio_layer,
      const webrtc::TaskQueueFactory &task_queue_factory
    );

    void init_audio_device_module(const AudioDeviceModule &audio_device_module);

    int16_t playout_devices(const AudioDeviceModule &audio_device_module);

    int16_t recording_devices(const AudioDeviceModule &audio_device_module);

    rust::Vec<rust::String> playout_device_name(
      const AudioDeviceModule &audio_device_module,
      int16_t index
    );

    rust::Vec<rust::String> recording_device_name(const AudioDeviceModule &audio_device_module, int16_t index);

    std::unique_ptr<webrtc::VideoCaptureModule::DeviceInfo> create_video_device_info();

    uint32_t number_of_video_devices(const webrtc::VideoCaptureModule::DeviceInfo &device_info);

    rust::Vec<rust::String> video_device_name(const webrtc::VideoCaptureModule::DeviceInfo &device_info, uint32_t index);
}
