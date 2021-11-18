#[cxx::bridge(namespace = "RTC")]
pub mod rtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;
        type AudioDeviceModule;
        type VideoDeviceInfo;

        pub fn SystemTimeMillis() -> UniquePtr<CxxString>;

        pub fn CreateDefaultTaskQueueFactory() -> UniquePtr<TaskQueueFactory>;

        pub fn CreateAudioDeviceModule(
            TaskQueueFactory: UniquePtr<TaskQueueFactory>,
        ) -> *mut AudioDeviceModule;
        pub unsafe fn InitAudioDeviceModule(
            AudioDeviceModule: *mut AudioDeviceModule,
        );
        pub unsafe fn PlayoutDevices(
            AudioDeviceModule: *mut AudioDeviceModule,
        ) -> i16;
        pub unsafe fn RecordingDevices(
            AudioDeviceModule: *mut AudioDeviceModule,
        ) -> i16;
        pub unsafe fn getPlayoutAudioInfo(
            AudioDeviceModule: *mut AudioDeviceModule,
            index: i16,
        ) -> Vec<String>;
        pub unsafe fn getRecordingAudioInfo(
            AudioDeviceModule: *mut AudioDeviceModule,
            index: i16,
        ) -> Vec<String>;
        pub unsafe fn dropAudioDeviceModule(
            AudioDeviceModule: *mut AudioDeviceModule,
        );

        pub fn CreateVideoDeviceInfo() -> *mut VideoDeviceInfo;
        pub unsafe fn NumberOfVideoDevices(
            DeviceInfo: *mut VideoDeviceInfo,
        ) -> u32;
        pub unsafe fn GetVideoDeviceName(
            DeviceInfo: *mut VideoDeviceInfo,
            index: u32,
        ) -> Vec<String>;
        pub unsafe fn dropVideoDeviceInfo(DeviceInfo: *mut VideoDeviceInfo);
    }
}
