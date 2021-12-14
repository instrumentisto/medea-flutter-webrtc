use libwebrtc_sys::system_time_millis;

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    extern "Rust" {
        #[cxx_name = "SystemTimeMillis"]
        fn system_time_millis() -> i64;
    }
}
