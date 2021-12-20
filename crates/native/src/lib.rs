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
        #[cxx_name = "SystemTimeMillis"]
        fn system_time_millis() -> i64;

        #[cxx_name = "ReturnRustVec"]
        fn return_rust_vec() -> Vec<u64>;
    }
}

// TODO: For demonstration purposes only, will be remove in the next PR.
fn return_rust_vec() -> Vec<u64> {
    vec![1, 2, 3]
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

#[no_mangle]
pub extern "C" fn SystemTimeMillis() -> i64 {
    system_time_millis()
}
