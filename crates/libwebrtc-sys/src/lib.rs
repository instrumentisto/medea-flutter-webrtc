use cxx::UniquePtr;

mod bridge;
use bridge::webrtc;

/// Creates default libWebRTC Task Queue Factory.
pub fn create_default_task_queue_factory() -> UniquePtr<webrtc::TaskQueueFactory>
{
    webrtc::create_default_task_queue_factory()
}

/// Creates libWebRTC Audio Device Module with default Windows layout.
pub fn create_audio_device_module(
    task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
) -> *mut webrtc::AudioDeviceModule {
    webrtc::create_audio_device_module(task_queue_factory)
}

/// Initializes libWebRTC Audio Device Module.
pub fn init_audio_device_module(
    audio_device_module: *mut webrtc::AudioDeviceModule,
) {
    unsafe { webrtc::init_audio_device_module(audio_device_module) }
}

/// Returns count of audio playout devices.
pub fn count_audio_playout_devices(
    audio_device_module: *mut webrtc::AudioDeviceModule,
) -> i16 {
    unsafe { webrtc::playout_devices(audio_device_module) }
}

/// Returns count of audio recording devices.
pub fn count_audio_recording_devices(
    audio_device_module: *mut webrtc::AudioDeviceModule,
) -> i16 {
    unsafe { webrtc::recording_devices(audio_device_module) }
}

/// Returns a tuple with an audio playout device information `(name, id)`.
pub fn get_audio_playout_device_info(
    audio_device_module: *mut webrtc::AudioDeviceModule,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_playout_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Returns a tuple with an audio recording device information `(name, id)`.
pub fn get_audio_recording_device_info(
    audio_device_module: *mut webrtc::AudioDeviceModule,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_recording_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Drops libWebRTC Audio Device Module.
pub fn drop_audio_device_module(
    audio_device_module: *mut webrtc::AudioDeviceModule,
) {
    unsafe {
        webrtc::drop_audio_device_module(audio_device_module);
    }
}

/// Creates libWebRTC Video Device Info.
pub fn create_video_device_module() -> *mut webrtc::VideoDeviceInfo {
    webrtc::create_video_device_info()
}

/// Returns count of video recording devices.
pub fn count_video_devices(
    video_device_module: *mut webrtc::VideoDeviceInfo,
) -> u32 {
    unsafe { webrtc::number_of_video_devices(video_device_module) }
}

/// Returns a tuple with an video recording device information `(name, id)`.
pub fn get_video_device_info(
    video_device_module: *mut webrtc::VideoDeviceInfo,
    index: u32,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_video_device_name(video_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Drops libWebRTC Video Device Info.
pub fn drop_video_device_module(
    video_device_module: *mut webrtc::VideoDeviceInfo,
) {
    unsafe {
        webrtc::drop_video_device_info(video_device_module);
    }
}
