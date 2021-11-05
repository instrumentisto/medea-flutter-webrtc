#[cxx::bridge(namespace = "bridge")]
mod ffi {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/bridge.h");

        pub fn getSystemTime() -> UniquePtr<CxxString>;
    }
}

pub fn run() -> String {
    ffi::getSystemTime().to_string()
}
