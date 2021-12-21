use libwebrtc_sys::{
    AudioDeviceModule, AudioLayer, TaskQueueFactory, VideoDeviceInfo,
};

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
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

/// Enumerates all the available media devices.
pub fn enumerate_devices() -> Vec<ffi::MediaDeviceInfo> {
    let mut audio_playout = audio_devices_info(AudioKind::Playout);
    let mut audio_recording = audio_devices_info(AudioKind::Recording);
    let mut video = video_devices_info();

    audio_playout.append(&mut audio_recording);
    audio_playout.append(&mut video);

    audio_playout
}

fn audio_devices_info(playout: bool) -> Vec<ffi::MediaDeviceInfo> {
    let task_queue = TaskQueueFactory::create_default_task_queue_factory();
    let adm =
        AudioDeviceModule::create(AudioLayer::kWindowsCoreAudio, &task_queue);
    adm.init();

    let count = if playout {
        adm.playout_devices()
    } else {
        adm.recording_devices()
    };
    debug_assert!(count >= 0, "audio device count is less than `0`");

    let mut result = Vec::with_capacity(count as usize);

    for i in 0..count {
        let info = if playout {
            adm.playout_device_name(i);
        } else {
            adm.recording_device_name(i);
        };

        let kind = if playout {
            ffi::MediaDeviceKind::kAudioOutput
        } else {
            ffi::MediaDeviceKind::kAudioInput
        };

        result.push(ffi::MediaDeviceInfo {
            device_id: info.0,
            kind,
            label: info.1,
        });
    }

    result
}

fn video_devices_info() -> Vec<ffi::MediaDeviceInfo> {
    let vdi = VideoDeviceInfo::create_device_info();
    let count = vdi.number_of_devices();
    let mut result = Vec::with_capacity(count as usize);

    for i in 0..count {
        let info = vdi.get_device_name(i);

        result.push(ffi::MediaDeviceInfo {
            device_id: info.0,
            kind: ffi::MediaDeviceKind::kVideoInput,
            label: info.1,
        });
    }

    result
}
