pub use internal::*;

#[allow(clippy::items_after_statements)]
#[allow(clippy::module_inception)]
#[cxx::bridge]
mod internal {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        type VideoFrame = crate::api::VideoFrame;

        pub type OnFrameCallbackInterface;

        #[cxx_name = "OnFrame"]
        pub unsafe fn on_frame(
            self: Pin<&mut OnFrameCallbackInterface>,
            frame: VideoFrame,
        );
    }

    extern "Rust" {
        // This will trigger cxx to generate UniquePtrTarget for OnFrameCallbackInterface.
        fn _touch_unique_ptr_on_frame_handler(i: UniquePtr<OnFrameCallbackInterface>);
    }
}

fn _touch_unique_ptr_on_frame_handler(_: cxx::UniquePtr<OnFrameCallbackInterface>) {}

// unsafe impl ExternType for crate::frame::Frame {
//     type Id = type_id!("Frame");
//     type Kind = cxx::kind::Opaque;
// }
