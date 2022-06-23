pub mod cpp_api;

pub use frame_handler::FrameHandler;

#[cfg(feature = "renderer_cpp_api")]
mod frame_handler {
    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    use crate::renderer::cpp_api;

    pub struct FrameHandler(UniquePtr<cpp_api::OnFrameCallbackInterface>);

    impl FrameHandler {
        pub fn new(handler: *mut cpp_api::OnFrameCallbackInterface) -> Self {
            unsafe { Self(UniquePtr::from_raw(handler)) }
        }

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

#[cfg(feature = "renderer_c_api")]
mod frame_handler {
    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    pub struct FrameHandler(*const ());

    impl Drop for FrameHandler {
        fn drop(&mut self) {
            unsafe { drop_handler(self.0) };
        }
    }

    #[repr(C)]
    pub struct Frame {
        pub height: usize,
        pub width: usize,
        pub rotation: i32,
        pub buffer_size: usize,
        pub frame: *mut u8,
    }

    impl FrameHandler {
        pub fn new(handler: *const ()) -> Self {
            log::debug!("FrameHandler::new");
            Self(handler)
        }

        pub fn on_frame(&self, frame: UniquePtr<sys::VideoFrame>) {
            log::debug!("FrameHandler::on_frame 1");

            let height = frame.height()as usize;
            let width = frame.width() as usize;
            let buffer_size = width * height * 4;

            let mut buffer = vec![0; buffer_size].into_boxed_slice();
            let buffer_ptr = buffer.as_mut_ptr();
            // std::mem::forget(buffer);

            unsafe {
                libwebrtc_sys::video_frame_to_abgr(&frame, buffer_ptr);
                on_frame_caller(self.0, Frame {
                    height,
                    width,
                    buffer_size,
                    rotation: frame.rotation().repr,
                    frame: buffer_ptr,
                });
            }
            drop(buffer);
        }
    }

    extern "C" {
        pub fn on_frame_caller(handler: *const (), frame: Frame);
        pub fn drop_handler(handler: *const ());
    }
}
