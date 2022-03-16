pub use cpp_api_bindings::*;

#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        pub type OnFrameCallbackInterface;

        type VideoFrame = crate::api_::VideoFrame;

        /// Calls C++ side `OnFrameCallbackInterface->OnFrame`.
        #[cxx_name = "OnFrame"]
        pub fn on_frame(self: Pin<&mut OnFrameCallbackInterface>, frame: VideoFrame);
    }

    // This will trigger `cxx` to generate `UniquePtrTarget` trait for the
    // mentioned types.
    extern "Rust" {
        fn _touch_unique_ptr_on_frame_handler(i: UniquePtr<OnFrameCallbackInterface>);
    }
}

fn _touch_unique_ptr_on_frame_handler(_: cxx::UniquePtr<OnFrameCallbackInterface>) {}
