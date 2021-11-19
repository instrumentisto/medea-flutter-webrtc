#[cxx::bridge(namespace = "WEBRTC")]
pub mod webrtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;
        type AudioDeviceModule;
        type VideoDeviceInfo;

        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;

        pub fn create_audio_device_module(
            task_queue_factory: UniquePtr<TaskQueueFactory>,
        ) -> *mut AudioDeviceModule;
        pub unsafe fn init_audio_device_module(
            audio_device_module: *mut AudioDeviceModule,
        );
        pub unsafe fn playout_devices(
            audio_device_module: *mut AudioDeviceModule,
        ) -> i16;
        pub unsafe fn recording_devices(
            audio_device_module: *mut AudioDeviceModule,
        ) -> i16;
        pub unsafe fn get_playout_audio_info(
            audio_device_module: *mut AudioDeviceModule,
            index: i16,
        ) -> Vec<String>;
        pub unsafe fn get_recording_audio_info(
            audio_device_module: *mut AudioDeviceModule,
            index: i16,
        ) -> Vec<String>;
        pub unsafe fn drop_audio_device_module(
            audio_device_module: *mut AudioDeviceModule,
        );

        pub fn create_video_device_info() -> *mut VideoDeviceInfo;
        pub unsafe fn number_of_video_devices(
            device_info: *mut VideoDeviceInfo,
        ) -> u32;
        pub unsafe fn get_video_device_name(
            device_info: *mut VideoDeviceInfo,
            index: u32,
        ) -> Vec<String>;
        pub unsafe fn drop_video_device_info(device_info: *mut VideoDeviceInfo);
    }
}
