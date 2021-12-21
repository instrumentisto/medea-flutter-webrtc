use cxx::UniquePtr;

#[rustfmt::skip]
mod bridge;

pub use bridge::webrtc::{
    create_audio_device_module, create_default_task_queue_factory,
    init_audio_device_module, playout_devices, recording_devices, AudioLayer,
};

use bridge::webrtc;

/// Returns a tuple with an audio playout device information `(id, name)`.
pub fn get_audio_playout_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info = webrtc::get_playout_audio_info(audio_device_module, index);
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Returns a tuple with an audio recording device information `(id, name)`.
pub fn get_audio_recording_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
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
