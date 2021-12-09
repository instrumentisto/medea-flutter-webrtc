use cxx::UniquePtr;

#[rustfmt::skip]
mod bridge;

use bridge::webrtc::{AudioDeviceModule, TaskQueueFactory};

/// Creates default libwebrtc [Task Queue Factory].
///
/// [Task Queue Factory]: https://tinyurl.com/doc-threads
pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory> {
    webrtc::create_default_task_queue_factory()
}

/// Creates libwebrtc [Audio Device Module] with default Windows layout.
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub fn create_audio_device_module(
    task_queue_factory: UniquePtr<TaskQueueFactory>,
) -> UniquePtr<AudioDeviceModule> {
    webrtc::create_audio_device_module(task_queue_factory)
}

/// Initializes libwebrtc [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub fn init_audio_device_module(
    audio_device_module: &UniquePtr<AudioDeviceModule>,
) {
    webrtc::init_audio_device_module(audio_device_module)
}

/// Returns count of audio playout devices.
pub fn count_audio_playout_devices(
    audio_device_module: &UniquePtr<AudioDeviceModule>,
) -> i16 {
    webrtc::playout_devices(audio_device_module)
}

/// Returns count of audio recording devices.
pub fn count_audio_recording_devices(
    audio_device_module: &UniquePtr<AudioDeviceModule>,
) -> i16 {
    webrtc::recording_devices(audio_device_module)
}

/// Returns a tuple with an audio playout device information `(id, name)`.
pub fn get_audio_playout_device_info(
    audio_device_module: &UniquePtr<AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info = webrtc::get_playout_audio_info(audio_device_module, index);
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Returns a tuple with an audio recording device information `(id, name)`.
pub fn get_audio_recording_device_info(
    audio_device_module: &UniquePtr<AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info = webrtc::get_recording_audio_info(audio_device_module, index);
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Creates libwebrtc Video Device Info.
pub fn create_video_device_module() -> UniquePtr<webrtc::VideoDeviceInfo> {
    webrtc::create_video_device_info()
}

/// Returns count of video recording devices.
pub fn count_video_devices(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
) -> u32 {
    webrtc::number_of_video_devices(video_device_module)
}

/// Returns a tuple with an video recording device information `(id, name)`.
pub fn get_video_device_info(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
    index: u32,
) -> (String, String) {
    let mut info = webrtc::get_video_device_name(video_device_module, index);
    (info.pop().unwrap(), info.pop().unwrap())
}
