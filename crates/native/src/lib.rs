use libwebrtc_sys::*;

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    struct DeviceInfo {
        deviceId: String,
        kind: String,
        label: String,
    }

    extern "Rust" {
        fn enumerate_devices() -> Vec<DeviceInfo>;
    }
}

enum AudioKind {
    Playout,
    Recording,
}

fn audio_devices_info(kind: AudioKind) -> Vec<ffi::DeviceInfo> {
    let task_queue = create_default_task_queue_factory();
    let audio_device_module = create_audio_device_module(task_queue);
    init_audio_device_module(&audio_device_module);
    let audio_device_count = if let AudioKind::Playout = kind {
        count_audio_playout_devices(&audio_device_module)
    } else {
        count_audio_recording_devices(&audio_device_module)
    };

    let mut list = vec![];

    for i in 0..audio_device_count {
        let audio_device_info = if let AudioKind::Playout = kind {
            get_audio_playout_device_info(&audio_device_module, i)
        } else {
            get_audio_recording_device_info(&audio_device_module, i)
        };

        let device_info = ffi::DeviceInfo {
            deviceId: audio_device_info.0,
            kind: if let AudioKind::Playout = kind {
                "audiooutput".to_string()
            } else {
                "audioinput".to_string()
            },
            label: audio_device_info.1,
        };

        list.push(device_info);
    }

    list
}

fn video_devices_info() -> Vec<ffi::DeviceInfo> {
    let video_device_module = create_video_device_module();
    let video_device_count = count_video_devices(&video_device_module);
    let mut list = vec![];

    for i in 0..video_device_count {
        let video_device_info = get_video_device_info(&video_device_module, i);

        let device_info = ffi::DeviceInfo {
            deviceId: video_device_info.0,
            kind: "videoinput".to_string(),
            label: video_device_info.1,
        };

        list.push(device_info);
    }

    list
}

/// Enumerates all the available media devices.
pub fn enumerate_devices() -> Vec<ffi::DeviceInfo> {
    let iters = audio_devices_info(AudioKind::Playout)
        .into_iter()
        .chain(audio_devices_info(AudioKind::Recording).into_iter())
        .chain(video_devices_info().into_iter());

    iters.collect()
}
