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

    pub struct MediaDeviceInfo {
        pub device_id: String,
        pub kind: MediaDeviceKind,
        pub label: String,
    }

    extern "Rust" {
        #[cxx_name = "EnumerateDevices"]
        fn enumerate_devices() -> Vec<MediaDeviceInfo>;
    }
}

use ffi::{MediaDeviceInfo, MediaDeviceKind};

/// Enumerates all the available media devices.
pub fn enumerate_devices() -> Vec<MediaDeviceInfo> {
    let mut audio = audio_devices_info();
    let mut video = video_devices_info();

    audio.append(&mut video);

    audio
}

fn audio_devices_info() -> Vec<MediaDeviceInfo> {
    let task_queue = TaskQueueFactory::create_default_task_queue_factory();
    let adm =
        AudioDeviceModule::create(AudioLayer::kWindowsCoreAudio, &task_queue);
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
        let count = if MediaDeviceKind::kAudioOutput = kind {
            count_playout
        } else {
            count_recording
        };

        for i in 0..count {
            let (device_id, label) = if MediaDeviceKind::kAudioOutput = kind {
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

fn video_devices_info() -> Vec<MediaDeviceInfo> {
    let vdi = VideoDeviceInfo::create_device_info();
    let count = vdi.number_of_devices();
    let mut result = Vec::with_capacity(count as usize);

    for i in 0..count {
        let (device_id, label) = vdi.get_device_name(i);

        result.push(MediaDeviceInfo {
            device_id,
            kind: MediaDeviceKind::kVideoInput,
            label,
        });
    }

    result
}
