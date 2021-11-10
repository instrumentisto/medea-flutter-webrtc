#include <memory>
#include <string>

#include "../bridge.h"
#include "rtc_base/time_utils.h"
#include "api/task_queue/default_task_queue_factory.h"
#include "modules/audio_device/include/audio_device_factory.h"
#include "modules/audio_processing/include/audio_processing.h"
#include "api/create_peerconnection_factory.h"

namespace RTC {
    std::unique_ptr<std::string> SystemTimeMillis() {
        long long a = rtc::SystemTimeMillis();
        std::string b = std::to_string(a);

        return std::make_unique<std::string>(b);
    }

    void customGetSource() {
        std::unique_ptr<webrtc::TaskQueueFactory> a = webrtc::CreateDefaultTaskQueueFactory();
        webrtc::TaskQueueFactory *b = a.release();

        rtc::scoped_refptr<webrtc::AudioDeviceModule> adm = webrtc::CreateWindowsCoreAudioAudioDeviceModule(b);
        webrtc::AudioDeviceModule *adm_rel = adm.release();
        adm_rel->Init();
        int16_t countPl = adm_rel->PlayoutDevices();
        int16_t countRc = adm_rel->RecordingDevices();
        std::string count = std::to_string(countPl + countRc);

        printf(count.c_str(), "\n");
        printf(std::to_string(countPl).c_str(), "\n");
        printf(std::to_string(countRc).c_str(), "\n");

        char strNameUTF8[128];
        char strGuidUTF8[128];

        auto aaa = adm_rel->PlayoutDeviceName(0, strNameUTF8, strGuidUTF8);

        printf(strNameUTF8);
        printf(strGuidUTF8);
    }
}
