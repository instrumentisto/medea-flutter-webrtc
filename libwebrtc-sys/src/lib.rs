#[cxx::bridge(namespace = "RTC")]
mod RTC {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/bridge.h");

        pub fn SystemTimeMillis() -> UniquePtr<CxxString>;
    }
}

pub fn system_time_millis() -> String {
    RTC::SystemTimeMillis().to_string()
}
