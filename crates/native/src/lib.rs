use libwebrtc_sys::{
    AudioDeviceModule, AudioLayer, TaskQueueFactory, VideoDeviceInfo,
};

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    pub enum MediaDeviceKind {
        kAudioInput,
        kAudioOutput,
        kVideoInput,
    }

    /// The [MediaDeviceInfo] contains information that describes a single
    /// media input or output device.
    #[derive(Debug)]
    pub struct MediaDeviceInfo {
        /// Unique identifier for the represented device.
        pub device_id: String,

        /// This [MediaDeviceInfo] kind.
        pub kind: MediaDeviceKind,

        /// A label describing this device.
        pub label: String,
    }

    extern "Rust" {
        /// Returns a list of the available media input and output devices,
        /// such as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        fn enumerate_devices() -> Vec<MediaDeviceInfo>;
    }
}

use ffi::{MediaDeviceInfo, MediaDeviceKind};

/// Returns a list of the available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> Vec<MediaDeviceInfo> {
    let mut audio = audio_devices_info();
    let mut video = video_devices_info();

    audio.append(&mut video);

    audio
}

/// Returns a list of the available audio input and output devices.
fn audio_devices_info() -> Vec<MediaDeviceInfo> {
    let mut task_queue = TaskQueueFactory::create_default_task_queue_factory();
    let adm =
        AudioDeviceModule::create(AudioLayer::kWindowsCoreAudio, &mut task_queue);
    adm.init();

    let count_playout = adm.playout_devices();
    let count_recording = adm.recording_devices();
    debug_assert!(
        count_playout >= 0,
        "playout audio device count is less than `0`"
    );
    debug_assert!(
        count_recording >= 0,
        "recording audio device count is less than `0`"
    );

    let mut result =
        Vec::with_capacity((count_playout + count_recording) as usize);

    for kind in [MediaDeviceKind::kAudioOutput, MediaDeviceKind::kAudioInput] {
        let count = if let MediaDeviceKind::kAudioOutput = kind {
            count_playout
        } else {
            count_recording
        };

        for i in 0..count {
            let (device_id, label) = if let MediaDeviceKind::kAudioOutput = kind
            {
                adm.playout_device_name(i)
            } else {
                adm.recording_device_name(i)
            };

            result.push(MediaDeviceInfo {
                device_id,
                kind,
                label,
            });
        }
    }

    result
}

/// Returns a list of the available video input devices.
fn video_devices_info() -> Vec<MediaDeviceInfo> {
    let mut vdi = VideoDeviceInfo::create_device_info();
    let count = vdi.number_of_devices();
    let mut result = Vec::with_capacity(count as usize);

    for i in 0..count {
        let (device_id, label) = vdi.device_name(i);

        result.push(MediaDeviceInfo {
            device_id,
            kind: MediaDeviceKind::kVideoInput,
            label,
        });
    }

    result
}

mod test {
    use super::*;
    #[test]
    fn init_audio_device_module() {
        let devices = enumerate_devices();

        // panic!("{}",format!("{:?}", devices));
    }
}
