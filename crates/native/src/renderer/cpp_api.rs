use cxx::UniquePtr;
use derive_more::From;
use libwebrtc_sys as sys;

#[cfg(feature = "renderer_cpp_api")]
pub use cpp_api_bindings::{OnFrameCallbackInterface, VideoFrame};

/// Wrapper around a [`sys::VideoFrame`] transferable via FFI.
#[derive(From)]
pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

#[allow(target_os = "clippy::trait-duplication-in-bounds")]
#[cfg(feature = "renderer_cpp_api")]
#[cxx::bridge]
mod cpp_api_bindings {
    /// Single video `frame`.
    pub struct VideoFrame {
        /// Vertical count of pixels in this [`VideoFrame`].
        pub height: usize,

        /// Horizontal count of pixels in this [`VideoFrame`].
        pub width: usize,

        /// Rotation of this [`VideoFrame`] in degrees.
        pub rotation: i32,

        /// Size of the bytes buffer required for allocation of the
        /// [`VideoFrame::get_abgr_bytes()`] call.
        pub buffer_size: usize,

        /// Underlying Rust side frame.
        pub frame: Box<Frame>,
    }

    extern "Rust" {
        type Frame;

        /// Converts this [`api::VideoFrame`] pixel data to `ABGR` scheme and
        /// outputs the result to the provided `buffer`.
        #[cxx_name = "GetABGRBytes"]
        unsafe fn get_abgr_bytes(self: &VideoFrame, buffer: *mut u8);
    }

    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");

        pub type OnFrameCallbackInterface;

        /// Calls C++ side `OnFrameCallbackInterface->OnFrame`.
        #[cxx_name = "OnFrame"]
        pub fn on_frame(
            self: Pin<&mut OnFrameCallbackInterface>,
            frame: VideoFrame,
        );
    }

    // This will trigger `cxx` to generate `UniquePtrTarget` trait for the
    // mentioned types.
    extern "Rust" {
        fn _touch_unique_ptr_on_frame_handler(
            i: UniquePtr<OnFrameCallbackInterface>,
        );
    }
}

#[cfg(feature = "renderer_cpp_api")]
fn _touch_unique_ptr_on_frame_handler(
    _: cxx::UniquePtr<OnFrameCallbackInterface>,
) {
}

#[cfg(feature = "renderer_cpp_api")]
impl cpp_api_bindings::VideoFrame {
    /// Converts this [`api::VideoFrame`] pixel data to the `ABGR` scheme and
    /// outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    pub unsafe fn get_abgr_bytes(&self, buffer: *mut u8) {
        libwebrtc_sys::video_frame_to_abgr(self.frame.0.as_ref(), buffer);
    }
}
