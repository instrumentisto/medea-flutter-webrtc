use cxx::UniquePtr;

mod bridge;
use bridge::rtc;

pub fn system_time_millis() -> String {
    // It leaks, but thats ok for demonstration purposes.
    rtc::SystemTimeMillis().to_string()
}

pub enum DeviceKind {
    AudioInput,
    AudioOutput,
    VideoInput,
}

pub struct DeviceInfo {
    pub name: String,
    pub id: String,
    pub kind: DeviceKind,
}

pub fn create_default_task_queue_factory() -> UniquePtr<rtc::TaskQueueFactory> {
    rtc::CreateDefaultTaskQueueFactory()
}

pub fn init_audio_device_module(
    task_queue_factory: UniquePtr<rtc::TaskQueueFactory>,
) -> *mut rtc::AudioDeviceModule {
    rtc::InitAudioDeviceModule(task_queue_factory)
}

pub fn count_audio_playout_devices(
    audio_device_module: *mut rtc::AudioDeviceModule,
) -> i16 {
    unsafe { rtc::PlayoutDevices(audio_device_module) }
}

pub fn count_audio_recording_devices(
    audio_device_module: *mut rtc::AudioDeviceModule,
) -> i16 {
    unsafe { rtc::RecordingDevices(audio_device_module) }
}

pub fn get_audio_playout_device_info(
    audio_device_module: *mut rtc::AudioDeviceModule,
    index: i16,
) -> DeviceInfo {
    let info;
    unsafe {
        info = rtc::getPlayoutAudioInfo(audio_device_module, index);
    }
    let device_info = DeviceInfo {
        name: info[0].clone(),
        id: info[1].clone(),
        kind: DeviceKind::AudioOutput,
    };

    device_info
}

pub fn get_audio_recording_device_info(
    audio_device_module: *mut rtc::AudioDeviceModule,
    index: i16,
) -> DeviceInfo {
    let info;
    unsafe {
        info = rtc::getRecordingAudioInfo(audio_device_module, index);
    }
    let device_info = DeviceInfo {
        name: info[0].clone(),
        id: info[1].clone(),
        kind: DeviceKind::AudioInput,
    };

    device_info
}

pub fn drop_audio_device_module(
    audio_device_module: *mut rtc::AudioDeviceModule,
) {
    unsafe {
        rtc::dropAudioDeviceModule(audio_device_module);
    }
}

pub fn init_video_device_module() -> *mut rtc::VideoDeviceInfo {
    rtc::CreateVideoDeviceInfo()
}

pub fn count_video_devices(
    video_device_module: *mut rtc::VideoDeviceInfo,
) -> u32 {
    unsafe { rtc::NumberOfVideoDevices(video_device_module) }
}

pub fn get_video_device_info(
    video_device_module: *mut rtc::VideoDeviceInfo,
    index: u32,
) -> DeviceInfo {
    let info;
    unsafe {
        info = rtc::GetVideoDeviceName(video_device_module, index);
    }
    let device_info = DeviceInfo {
        name: info[0].clone(),
        id: info[1].clone(),
        kind: DeviceKind::VideoInput,
    };

    device_info
}

pub fn drop_video_device_module(
    video_device_module: *mut rtc::VideoDeviceInfo,
) {
    unsafe {
        rtc::dropVideoDeviceInfo(video_device_module);
    }
}
