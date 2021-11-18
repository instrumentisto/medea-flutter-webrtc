use libwebrtc_sys::*;

#[cxx::bridge]
mod ffi {
    struct FinalDeviceInfo {
        pub deviceId: String,
        pub kind: String,
        pub label: String,
    }

    extern "Rust" {
        fn video_info_test() -> FinalDeviceInfo;
    }
}

pub fn video_info_test() -> ffi::FinalDeviceInfo {
    let video_device_module = init_video_device_module();
    let video_device_info = get_video_device_info(video_device_module, 0);
    drop_video_device_module(video_device_module);

    let kind: String;

    match video_device_info.kind {
        DeviceKind::AudioInput => kind = String::from("audioinput"),
        DeviceKind::AudioOutput => kind = String::from("audiooutput"),
        DeviceKind::VideoInput => kind = String::from("videoinput"),
    }

    ffi::FinalDeviceInfo {
        deviceId: video_device_info.id,
        kind: kind,
        label: video_device_info.name,
    }
}
