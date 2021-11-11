#include <memory>
#include <string>

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

    void customGetSource() {
        // std::unique_ptr<webrtc::TaskQueueFactory> a = webrtc::CreateDefaultTaskQueueFactory();
        // webrtc::TaskQueueFactory *b = a.release();

        // rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::CreateWindowsCoreAudioAudioDeviceModule(b);
        // webrtc::AudioDeviceModule *adm_rel = adm.release();
        // adm_rel->Init();
        // int16_t countPl = adm_rel->PlayoutDevices();
        // int16_t countRc = adm_rel->RecordingDevices();

        // for (int i = 0; i < countPl; i++) {
        //     char strNameUTF8[128];
        //     char strGuidUTF8[128];

        //     adm_rel->PlayoutDeviceName(i, strNameUTF8, strGuidUTF8);

        //     printf(strNameUTF8);
        //     printf(strGuidUTF8);
        // }

        // for (int i = 0; i < countRc; i++) {
        //     char strNameUTF8[128];
        //     char strGuidUTF8[128];

        //     adm_rel->RecordingDeviceName(i, strNameUTF8, strGuidUTF8);

        //     printf(strNameUTF8);
        //     printf(strGuidUTF8);
        // }
        char device_name[256];
        char unique_name[256];
        const char * name;

        auto vcf = webrtc::VideoCaptureFactory::Create(name);
        // int vidc = name->GetDeviceName(0, device_name, 256, unique_name, 256);
        // rtc::scoped_refptr<webrtc::VideoCaptureModule> vid = webrtc::VideoCaptureFactory::Create(unique_name);
        // webrtc::VideoCaptureModule *vid_rel = vid.release();
    
        // printf(std::to_string(vidc).c_str());
    }
}
