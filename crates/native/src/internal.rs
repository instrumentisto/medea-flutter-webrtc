// use crate::frame::Frame;

use cxx::{type_id, ExternType};

pub use internal::*;

#[allow(clippy::items_after_statements)]
#[allow(clippy::module_inception)]
#[cxx::bridge]
mod internal {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        type Frame = crate::frame::Frame;

        pub type OnFrameHandler;

        #[cxx_name = "OnFrame"]
        pub unsafe fn on_frame(
            self: Pin<&mut OnFrameHandler>,
            frame: *mut Frame,
        );
    }

    extern "Rust" {
        // This will trigger cxx to generate UniquePtrTarget for OnFrameHandler.
        fn _touch_unique_ptr_on_frame_handler(i: UniquePtr<OnFrameHandler>);
    }
}

fn _touch_unique_ptr_on_frame_handler(_: cxx::UniquePtr<OnFrameHandler>) {}

unsafe impl ExternType for crate::frame::Frame {
    type Id = type_id!("Frame");
    type Kind = cxx::kind::Opaque;
}
