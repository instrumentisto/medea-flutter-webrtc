#[cxx::bridge(namespace = "WEBRTC")]
pub mod webrtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;
        type AudioDeviceModule;
        type VideoDeviceInfo;

        pub fn create_default_task_queue_factory()
            -> UniquePtr<TaskQueueFactory>;

        pub fn create_audio_device_module(
            task_queue_factory: UniquePtr<TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        pub fn init_audio_device_module(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        );

        pub fn playout_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;

        pub fn recording_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;

        pub fn get_playout_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        pub fn get_recording_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        pub fn number_of_video_devices(
            device_info: &UniquePtr<VideoDeviceInfo>,
        ) -> u32;

        pub fn get_video_device_name(
            device_info: &UniquePtr<VideoDeviceInfo>,
            index: u32,
        ) -> Vec<String>;
    }
}
