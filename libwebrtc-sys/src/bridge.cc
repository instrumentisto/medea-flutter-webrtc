#include <memory>
#include <string>
#include <iostream>

#include "../bridge.h"
#include "rtc_base/time_utils.h"
#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device_factory.h"
#include "modules/video_capture/video_capture_factory.h"
#include "api/create_peerconnection_factory.h"

namespace RTC {
    std::unique_ptr<std::string> SystemTimeMillis() {
        long long a = rtc::SystemTimeMillis();
        std::string b = std::to_string(a);

        return std::make_unique<std::string>(b);
    }

    std::unique_ptr<webrtc::TaskQueueFactory> CreateDefaultTaskQueueFactory() {
        return webrtc::CreateDefaultTaskQueueFactory();
    }

    // webrtc::AudioDeviceModule* InitAudioDeviceModule(std::unique_ptr<webrtc::TaskQueueFactory> TaskQueueFactory) {
    std::unique_ptr<webrtc::AudioDeviceModule> InitAudioDeviceModule(std::unique_ptr<webrtc::TaskQueueFactory> TaskQueueFactory) {
        rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::AudioDeviceModule::Create(webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio, TaskQueueFactory.get());
        webrtc::AudioDeviceModule *adm_rel = adm.release();
        adm_rel->Init();

        return std::make_unique<webrtc::AudioDeviceModule>(adm_rel);
        // return adm_rel;
    };

    // class Test
    // {
    //     public:
    //     Test()
    //     {
    //         std::cout << "Constructor called";
    //     }

    //     ~Test()
    //     {
    //         std::cout << "Destructor called";
    //     }
    // };

    // std::unique_ptr<Test> testclass() {
    //     Test examp;
        
    //     std::make_unique<Test>(examp);
    // }

    // int16_t PlayoutDevices(std::unique_ptr<webrtc::AudioDeviceModule> AudioDeviceModule) {
    //     return AudioDeviceModule->PlayoutDevices();
    // };

    // int16_t RecordingDevices(std::unique_ptr<webrtc::AudioDeviceModule> AudioDeviceModule) {
    //     return AudioDeviceModule->RecordingDevices();
    // };

    // std::unique_ptr<std::vector<char>> getPlayoutAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index) {
    //     char strNameUTF8[128];
    //     char strGuidUTF8[128];

    //     AudioDeviceModule->PlayoutDeviceName(index, strNameUTF8, strGuidUTF8);

    //     std::vector<char> info = { strNameUTF8, strGuidUTF8 };
    //     return std::make_unique<std::vector<char>>(info);
    // };

    void customGetSource() {
        std::unique_ptr<webrtc::TaskQueueFactory> a = webrtc::CreateDefaultTaskQueueFactory();

        rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::AudioDeviceModule::Create(webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio, a.get());
        webrtc::AudioDeviceModule *adm_rel = adm.get();
        adm_rel->Init();
        int16_t countPl = adm_rel->PlayoutDevices();
        int16_t countRc = adm_rel->RecordingDevices();

        for (int i = 0; i < countPl; i++) {
            char strNameUTF8[128];
            char strGuidUTF8[128];

            adm_rel->PlayoutDeviceName(i, strNameUTF8, strGuidUTF8);

            printf("%s\n", strNameUTF8);
            printf("%s\n", strGuidUTF8);
        }

        for (int i = 0; i < countRc; i++) {
            char strNameUTF8[128];
            char strGuidUTF8[128];

            adm_rel->RecordingDeviceName(i, strNameUTF8, strGuidUTF8);

            printf("%s\n", strNameUTF8);
            printf("%s\n", strGuidUTF8);
        }
        
        printf("++++++++++++++++++++++++++\n");

        char device_name[256];
        char unique_id[256];
        char product_id[256];
        const char * name;

        auto info = webrtc::VideoCaptureFactory::CreateDeviceInfo();
        auto cnt = info->NumberOfDevices();
        info->GetDeviceName(0, device_name, 256, unique_id, 256, product_id, 256);
        auto capcnt = info->NumberOfCapabilities(unique_id);
        printf("%s\n", device_name);
        printf("%s\n", unique_id);
        printf("%s\n", product_id);
        
        for (int i = 0; i < capcnt; i++) {
            webrtc::VideoCaptureCapability capability;

            info->GetCapability(unique_id, i, capability);
            
            printf("MaxFPS: %d.\nHeight: %d.\nWidth: %d.\nInterlaced: %s.\n============\n", capability.maxFPS, capability.height, capability.width, std::to_string(capability.interlaced));
        }
    }
}
