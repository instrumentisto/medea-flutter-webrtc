#pragma once

#include <memory>
#include <string>
#include <iostream>

#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device.h"

namespace RTC {
    class TestCl
    {
        public:
        TestCl() {
            std::cout << "Constructor";
        }

        ~TestCl() {
            std::cout << "Destructor";
        }
    };

    using TaskQueueFactory = webrtc::TaskQueueFactory;
    using AudioDeviceModule = webrtc::AudioDeviceModule;

    std::unique_ptr<std::string> SystemTimeMillis();
    std::unique_ptr<webrtc::TaskQueueFactory> CreateDefaultTaskQueueFactory();
    webrtc::AudioDeviceModule* InitAudioDeviceModule(std::unique_ptr<webrtc::TaskQueueFactory> TaskQueueFactory);
    std::unique_ptr<TestCl> testclasses();
    // int16_t PlayoutDevices(std::unique_ptr<webrtc::AudioDeviceModule> AudioDeviceModule);
    // int16_t RecordingDevices(std::unique_ptr<webrtc::AudioDeviceModule> AudioDeviceModule);
    // std::unique_ptr<std::vector<char>> getAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index);

    void customGetSource();
}
