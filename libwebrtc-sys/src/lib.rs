#[cxx::bridge(namespace = "RTC")]
mod rtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/bridge.h");

        pub fn SystemTimeMillis() -> UniquePtr<CxxString>;
        // pub fn customGetSource();
    }
}

pub fn system_time_millis() -> String {
    // RTC::customGetSource();
    // It leaks, but thats ok for demonstration purposes.
    rtc::SystemTimeMillis().to_string()
}
