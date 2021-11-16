#include <memory>
#include <string>
#include <iostream>

#include "../bridge.h"
#include "rtc_base/time_utils.h"

namespace RTC {
    std::unique_ptr<std::string> SystemTimeMillis() {
        long long a = rtc::SystemTimeMillis();
        std::string b = std::to_string(a);

        return std::make_unique<std::string>(b);
    }

    std::unique_ptr<webrtc::TaskQueueFactory> CreateDefaultTaskQueueFactory() {
        return webrtc::CreateDefaultTaskQueueFactory();
    }

    webrtc::AudioDeviceModule* InitAudioDeviceModule(std::unique_ptr<webrtc::TaskQueueFactory> TaskQueueFactory) {
        rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::AudioDeviceModule::Create(webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio, TaskQueueFactory.get());
        webrtc::AudioDeviceModule* adm_rel = adm.release();
        adm_rel->Init();

        return adm_rel;
    };

    void dropAudioDeviceModule(webrtc::AudioDeviceModule* AudioDeviceModule) {
        AudioDeviceModule->Release();
    };

    int16_t PlayoutDevices(webrtc::AudioDeviceModule* AudioDeviceModule) {
        return AudioDeviceModule->PlayoutDevices();
    };

    int16_t RecordingDevices(webrtc::AudioDeviceModule* AudioDeviceModule) {
        return AudioDeviceModule->RecordingDevices();
    };

    rust::Vec<rust::String> getPlayoutAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index) {
        char strNameUTF8[128];
        char strGuidUTF8[128];

        AudioDeviceModule->PlayoutDeviceName(index, strNameUTF8, strGuidUTF8);

        rust::String strname = strNameUTF8;
        rust::String strid = strGuidUTF8;

        rust::Vec<rust::String> info = { strname, strid };
        return info;
    };

    rust::Vec<rust::String> getRecordingAudioInfo(webrtc::AudioDeviceModule* AudioDeviceModule, int16_t index) {
        char strNameUTF8[128];
        char strGuidUTF8[128];

        AudioDeviceModule->RecordingDeviceName(index, strNameUTF8, strGuidUTF8);

        rust::String strname = strNameUTF8;
        rust::String strid = strGuidUTF8;

        rust::Vec<rust::String> info = { strname, strid };
        return info;
    };

    webrtc::VideoCaptureModule::DeviceInfo* CreateVideoDeviceInfo() {
        return webrtc::VideoCaptureFactory::CreateDeviceInfo();
    };

    uint32_t NumberOfVideoDevices(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo) {
        return DeviceInfo->NumberOfDevices();
    };

    rust::Vec<rust::String> GetVideoDeviceName(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo, uint32_t index) {
        char device_name[256];
        char unique_id[256];

        DeviceInfo->GetDeviceName(index, device_name, 256, unique_id, 256);

        rust::String strname = device_name;
        rust::String strid = unique_id;

        rust::Vec<rust::String> info = { strname, strid };
        return info;
    };

    void dropVideoDeviceInfo(webrtc::VideoCaptureModule::DeviceInfo* DeviceInfo) {
        delete DeviceInfo;
    };

    void customGetSource() {
        std::unique_ptr<webrtc::TaskQueueFactory> a = webrtc::CreateDefaultTaskQueueFactory();

        rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::AudioDeviceModule::Create(webrtc::AudioDeviceModule::AudioLayer::kWindowsCoreAudio, a.get());
        webrtc::AudioDeviceModule* adm_rel = adm.get();
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
        const char* name;

        webrtc::VideoCaptureModule::DeviceInfo* info = webrtc::VideoCaptureFactory::CreateDeviceInfo();
        uint32_t cnt = info->NumberOfDevices();
        info->GetDeviceName(0, device_name, 256, unique_id, 256, product_id, 256);
        uint32_t capcnt = info->NumberOfCapabilities(unique_id);
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
