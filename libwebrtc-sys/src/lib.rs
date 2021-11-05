#[cxx::bridge(namespace = "rtc")]
mod rtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/bridge.h");

        pub fn SystemTimeMillis() -> UniquePtr<CxxString>;
    }
}

pub fn run() -> String {
    ffi::getSystemTime().to_string()
}
