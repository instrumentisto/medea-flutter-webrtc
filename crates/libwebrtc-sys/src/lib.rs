use cxx::UniquePtr;

mod bridge;
use bridge::webrtc;

/// Creates default [libWebRTC Task Queue Factory].
///
/// [libWebRTC Task Queue Factory]: https://webrtc.googlesource.com/src/+/HEAD/g3doc/implementation_basics.md#threads
pub fn create_default_task_queue_factory() -> UniquePtr<webrtc::TaskQueueFactory>
{
    webrtc::create_default_task_queue_factory()
}

/// Creates [libWebRTC Audio Device Module] with default Windows layout.
///
/// [libWebRTC Audio Device Module]: https://webrtc.googlesource.com/src/+/HEAD/modules/audio_device/g3doc/audio_device_module.md
pub fn create_audio_device_module(
    task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
) -> UniquePtr<webrtc::AudioDeviceModule> {
    unsafe { webrtc::create_audio_device_module(task_queue_factory) }
}

/// Initializes [libWebRTC Audio Device Module].
///
/// [libWebRTC Audio Device Module]: https://webrtc.googlesource.com/src/+/HEAD/modules/audio_device/g3doc/audio_device_module.md
pub fn init_audio_device_module(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) {
    unsafe { webrtc::init_audio_device_module(audio_device_module) }
}

/// Returns count of audio playout devices.
pub fn count_audio_playout_devices(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) -> i16 {
    unsafe { webrtc::playout_devices(audio_device_module) }
}

/// Returns count of audio recording devices.
pub fn count_audio_recording_devices(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) -> i16 {
    unsafe { webrtc::recording_devices(audio_device_module) }
}

/// Returns a tuple with an audio playout device information `(id, name)`.
pub fn get_audio_playout_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_playout_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Returns a tuple with an audio recording device information `(id, name)`.
pub fn get_audio_recording_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_recording_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Creates libWebRTC Video Device Info.
pub fn create_video_device_module() -> UniquePtr<webrtc::VideoDeviceInfo> {
    webrtc::create_video_device_info()
}

/// Returns count of video recording devices.
pub fn count_video_devices(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
) -> u32 {
    unsafe { webrtc::number_of_video_devices(video_device_module) }
}

/// Returns a tuple with an video recording device information `(id, name)`.
pub fn get_video_device_info(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
    index: u32,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_video_device_name(video_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}
