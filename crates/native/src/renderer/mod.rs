//! Implementations and definitions of the renderers API for the C and C++ APIs.

pub mod cpp_api;

pub use frame_handler::FrameHandler;

/// Definitions and implementation of handler for the C++
/// API [`sys::VideoFrame`]s renderer.
#[cfg(feature = "renderer_cpp_api")]
mod frame_handler {
    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    use crate::renderer::cpp_api;

    /// Handler for the renderer [`sys::VideoFrame`]s.
    pub struct FrameHandler(UniquePtr<cpp_api::OnFrameCallbackInterface>);

    impl FrameHandler {
        /// Returns new [`FrameHandler`] with the provided [`sys::VideoFrame`]s
        /// receiver.
        pub fn new(handler: *mut cpp_api::OnFrameCallbackInterface) -> Self {
            unsafe { Self(UniquePtr::from_raw(handler)) }
        }

        /// Passes provided [`sys::VideoFrame`] to the C++ side listener.
        pub fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
            self.0.pin_mut().on_frame(cpp_api::VideoFrame::from(frame));
        }
    }

    impl From<UniquePtr<sys::VideoFrame>> for cpp_api::VideoFrame {
        #[allow(clippy::cast_sign_loss)]
        fn from(frame: UniquePtr<sys::VideoFrame>) -> Self {
            let height = frame.height();
            let width = frame.width();

            assert!(height >= 0, "VideoFrame has a negative height");
            assert!(width >= 0, "VideoFrame has a negative width");

            let buffer_size = width * height * 4;

            Self {
                height: height as usize,
                width: width as usize,
                buffer_size: buffer_size as usize,
                rotation: frame.rotation().repr,
                frame: Box::new(cpp_api::Frame::from(Box::new(frame))),
            }
        }
    }
}

/// Definitions and implementation of handler for the C API
/// [`sys::VideoFrame`]s renderer.
#[cfg(feature = "renderer_c_api")]
mod frame_handler {
    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    /// Handler for the renderer [`sys::VideoFrame`]s.
    pub struct FrameHandler(*const ());

    impl Drop for FrameHandler {
        fn drop(&mut self) {
            unsafe { drop_handler(self.0) };
        }
    }

    /// [`sys::VideoFrame`] and metadata which will be passed
    /// to the C API renderer.
    #[repr(C)]
    pub struct Frame {
        /// Height of the [`Frame`].
        pub height: usize,

        /// Width of the [`Frame`].
        pub width: usize,

        /// Rotation of the [`Frame`].
        pub rotation: i32,

        /// Size of the [`Frame`] buffer.
        pub buffer_size: usize,

        /// Actual [`sys::VideoFrame`].
        pub frame: *mut sys::VideoFrame,
    }

    impl FrameHandler {
        /// Returns new [`FrameHandler`] with the provided [`sys::VideoFrame`]s
        /// receiver.
        pub fn new(handler: *const ()) -> Self {
            Self(handler)
        }

        /// Passes provided [`sys::VideoFrame`] to the C side listener.
        pub fn on_frame(&self, frame: UniquePtr<sys::VideoFrame>) {
            #[allow(clippy::cast_sign_loss)]
            let height = frame.height() as usize;
            #[allow(clippy::cast_sign_loss)]
            let width = frame.width() as usize;
            let buffer_size = width * height * 4;

            unsafe {
                on_frame_caller(
                    self.0,
                    Frame {
                        height,
                        width,
                        buffer_size,
                        rotation: frame.rotation().repr,
                        frame: UniquePtr::into_raw(frame),
                    },
                );
            }
        }
    }

    extern "C" {
        /// C side function into which [`Frame`]s will be passed.
        pub fn on_frame_caller(handler: *const (), frame: Frame);

        /// Destructor for the C side renderer.
        pub fn drop_handler(handler: *const ());
    }

    /// Converts provided [`sys::VideoFrame`] pixel data to `ABGR` scheme and
    /// outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[no_mangle]
    unsafe extern "C" fn get_abgr_bytes(
        frame: *mut sys::VideoFrame,
        buffer: *mut u8,
    ) {
        libwebrtc_sys::video_frame_to_abgr(frame.as_ref().unwrap(), buffer);
    }

    /// Converts provided [`sys::VideoFrame`] pixel data to `ARGB` scheme and
    /// outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[no_mangle]
    unsafe extern "C" fn get_argb_bytes(
        frame: *mut sys::VideoFrame,
        buffer: *mut u8,
    ) {
        libwebrtc_sys::video_frame_to_argb(frame.as_ref().unwrap(), buffer);
    }

    /// Drops the provided [`sys::VideoFrame`].
    #[no_mangle]
    unsafe extern "C" fn drop_frame(frame: *mut sys::VideoFrame) {
        UniquePtr::from_raw(frame);
    }
}
