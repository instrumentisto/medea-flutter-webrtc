#pragma once

#include <memory>
#include <string>
#include <iostream>

#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "rust/cxx.h"

namespace RTC {
    using TaskQueueFactory = webrtc::TaskQueueFactory;
    using AudioDeviceModule = webrtc::AudioDeviceModule;
    using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;

    std::unique_ptr<std::string> SystemTimeMillis();

    std::unique_ptr<webrtc::TaskQueueFactory> CreateDefaultTaskQueueFactory();

    webrtc::AudioDeviceModule* CreateAudioDeviceModule(std::unique_ptr<webrtc::TaskQueueFactory> TaskQueueFactory);
    void InitAudioDeviceModule(webrtc::AudioDeviceModule* AudioDeviceModule);
    int16_t PlayoutDevices(webrtc::AudioDeviceModule* AudioDeviceModule);
    int16_t RecordingDevices(webrtc::AudioDeviceModule* AudioDeviceModule);
    rust::Vec<rust::String> getPlayoutAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index);
    rust::Vec<rust::String> getRecordingAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index);
    void dropAudioDeviceModule(webrtc::AudioDeviceModule* AudioDeviceModule);

    webrtc::VideoCaptureModule::DeviceInfo* CreateVideoDeviceInfo();
    uint32_t NumberOfVideoDevices(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo);
    rust::Vec<rust::String> GetVideoDeviceName(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo, uint32_t index);
    void dropVideoDeviceInfo(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo);

    void customGetSource();
}
