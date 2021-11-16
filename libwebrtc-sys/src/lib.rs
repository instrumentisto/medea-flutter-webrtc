#[cxx::bridge(namespace = "RTC")]
mod rtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/bridge.h");
        
        type TaskQueueFactory;
        type AudioDeviceModule;
        type Test;
        
        pub fn SystemTimeMillis() -> UniquePtr<CxxString>;
        pub fn CreateDefaultTaskQueueFactory() -> UniquePtr<TaskQueueFactory>;
        pub fn InitAudioDeviceModule(TaskQueueFactory: UniquePtr<TaskQueueFactory>) -> *mut AudioDeviceModule;
        pub fn testclasses() -> UniquePtr<Test>;
        // pub unsafe fn PlayoutDevices(AudioDeviceModule: UniquePtr<AudioDeviceModule>) -> i16;
        // pub unsafe fn RecordingDevices(AudioDeviceModule: UniquePtr<AudioDeviceModule>) -> i16;
        // pub unsafe fn getAudioInfo(AudioDeviceModule: *mut AudioDeviceModule, index: i16) -> UniquePtr<CxxVector<c_char>>;
        pub fn customGetSource();
    }
}

pub fn system_time_millis() -> String {
    rtc::customGetSource();
    let a = rtc::CreateDefaultTaskQueueFactory();
    let b = rtc::InitAudioDeviceModule(a);
    let c = rtc::testclasses();
    c.drop();
    // unsafe {
    //     println!("{}", rtc::PlayoutDevices(b));
    //     println!("{}", rtc::RecordingDevices(b));
    // }
    
    // It leaks, but thats ok for demonstration purposes.
    rtc::SystemTimeMillis().to_string()
}
