//! Implementations and definitions of the renderers API for C and C++ APIs.

pub use frame_handler::FrameHandler;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(i32)]
/// Frame change events.
pub enum TextureEvent {
    /// The height, width, or rotation have changed.
    OnTextureChange = 0,
    /// First frame event.
    OnFirstFrameRendered = 1,
}

#[cfg(not(target_os = "macos"))]
/// Definitions and implementation of a handler for C++ API [`sys::VideoFrame`]s
/// renderer.
mod frame_handler {
    use cxx::UniquePtr;
    use dart_sys::{
        Dart_CObject, Dart_CObject_Type_Dart_CObject_kArray as DartCTypeArray,
        Dart_CObject_Type_Dart_CObject_kInt32 as DartCTypeI32,
        Dart_CObject_Type_Dart_CObject_kInt64 as DartCTypeI64, Dart_Port,
        Dart_PostCObject_DL, _Dart_CObject__bindgen_ty_1 as DartCValue,
        _Dart_CObject__bindgen_ty_1__bindgen_ty_3 as DartCArray,
    };
    use derive_more::From;
    use libwebrtc_sys as sys;

    pub use cpp_api_bindings::{OnFrameCallbackInterface, VideoFrame};

    use super::TextureEvent;
    use sys::VideoRotation;

    /// Handler for a [`sys::VideoFrame`]s renderer.
    pub struct FrameHandler {
        inner: UniquePtr<OnFrameCallbackInterface>,
        first_frame_rendered: bool,
        port: Dart_Port,
        texture_id: i64,
        width: i32,
        height: i32,
        rotation: VideoRotation,
    }

    impl FrameHandler {
        /// Returns new [`FrameHandler`] with the provided [`sys::VideoFrame`]s
        /// receiver.
        pub fn new(
            handler: *mut OnFrameCallbackInterface,
            port: Dart_Port,
            texture_id: i64,
        ) -> Self {
            unsafe {
                Self {
                    inner: UniquePtr::from_raw(handler),
                    first_frame_rendered: false,
                    port,
                    width: 0,
                    height: 0,
                    rotation: VideoRotation::kVideoRotation_0,
                    texture_id,
                }
            }
        }

        /// Passes provided [`sys::VideoFrame`] to the C++ side listener.
        pub fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
            if !self.first_frame_rendered {
                let mut value = Dart_CObject {
                    type_: DartCTypeArray,
                    value: DartCValue {
                        as_array: DartCArray {
                            length: 2,
                            values: &mut [
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32:
                                            TextureEvent::OnFirstFrameRendered
                                                as i32,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI64,
                                    value: DartCValue {
                                        as_int64: self.texture_id,
                                    },
                                } as *mut _,
                            ] as *mut _,
                        },
                    },
                };
                self.first_frame_rendered = true;
                #[allow(clippy::expect_used)]
                unsafe {
                    Dart_PostCObject_DL
                        .expect("dart_api_dl has not been initialized")(
                        self.port, &mut value,
                    )
                };
            }

            if self.height != frame.height()
                || self.height != frame.width()
                || self.rotation != frame.rotation()
            {
                let mut value = Dart_CObject {
                    type_: DartCTypeArray,
                    value: DartCValue {
                        as_array: DartCArray {
                            length: 5,
                            values: &mut [
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: TextureEvent::OnTextureChange
                                            as i32,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI64,
                                    value: DartCValue {
                                        as_int64: self.texture_id,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.rotation().repr,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.width(),
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.height(),
                                    },
                                } as *mut _,
                            ] as *mut _,
                        },
                    },
                };
                self.height = frame.height();
                self.width = frame.width();
                self.rotation = frame.rotation();

                #[allow(clippy::expect_used)]
                unsafe {
                    Dart_PostCObject_DL
                        .expect("dart_api_dl has not been initialized")(
                        self.port, &mut value,
                    )
                };
            }
            self.inner.pin_mut().on_frame(VideoFrame::from(frame));
        }
    }

    impl From<UniquePtr<sys::VideoFrame>> for VideoFrame {
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
                frame: Box::new(Frame::from(Box::new(frame))),
            }
        }
    }

    /// Wrapper around a [`sys::VideoFrame`] transferable via FFI.
    #[derive(From)]
    pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

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

            /// Converts this [`api::VideoFrame`] pixel data to `ABGR` scheme
            /// and outputs the result to the provided `buffer`.
            #[cxx_name = "GetABGRBytes"]
            unsafe fn get_abgr_bytes(self: &VideoFrame, buffer: *mut u8);
        }

        unsafe extern "C++" {
            include!("medea-flutter-webrtc-native/include/api.h");

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

    fn _touch_unique_ptr_on_frame_handler(
        _: cxx::UniquePtr<OnFrameCallbackInterface>,
    ) {
    }

    impl cpp_api_bindings::VideoFrame {
        /// Converts this [`api::VideoFrame`] pixel data to the `ABGR` scheme
        /// and outputs the result to the provided `buffer`.
        ///
        /// # Safety
        ///
        /// The provided `buffer` must be a valid pointer.
        pub unsafe fn get_abgr_bytes(&self, buffer: *mut u8) {
            libwebrtc_sys::video_frame_to_abgr(self.frame.0.as_ref(), buffer);
        }
    }
}

#[cfg(target_os = "macos")]
/// Definitions and implementation of a handler for C API [`sys::VideoFrame`]s
/// renderer.
///
/// cbindgen:ignore
mod frame_handler {
    use std::cell::RefCell;

    use cxx::UniquePtr;
    use libwebrtc_sys as sys;

    use dart_sys::{
        Dart_CObject, Dart_CObject_Type_Dart_CObject_kArray as DartCTypeArray,
        Dart_CObject_Type_Dart_CObject_kInt32 as DartCTypeI32,
        Dart_CObject_Type_Dart_CObject_kInt64 as DartCTypeI64, Dart_Port,
        Dart_PostCObject_DL, _Dart_CObject__bindgen_ty_1 as DartCValue,
        _Dart_CObject__bindgen_ty_1__bindgen_ty_3 as DartCArray,
    };

    use super::TextureEvent;
    use sys::VideoRotation;

    /// Handler for a [`sys::VideoFrame`]s renderer.
    pub struct FrameHandler {
        inner: *const (),
        first_frame_rendered: RefCell<bool>,
        port: Dart_Port,
        texture_id: i64,
        width: RefCell<i32>,
        height: RefCell<i32>,
        rotation: RefCell<VideoRotation>,
    }

    impl Drop for FrameHandler {
        fn drop(&mut self) {
            unsafe { drop_handler(self.inner) };
        }
    }

    /// [`sys::VideoFrame`] and metadata which will be passed to the C API
    /// renderer.
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
        pub fn new(
            handler: *const (),
            port: Dart_Port,
            texture_id: i64,
        ) -> Self {
            Self {
                inner: handler,
                first_frame_rendered: RefCell::new(false),
                port,
                width: RefCell::new(0),
                height: RefCell::new(0),
                rotation: RefCell::new(VideoRotation::kVideoRotation_0),
                texture_id,
            }
        }

        /// Passes the provided [`sys::VideoFrame`] to the C side listener.
        #[allow(clippy::cast_sign_loss, clippy::too_many_lines)]
        pub fn on_frame(&self, frame: UniquePtr<sys::VideoFrame>) {
            let height = frame.height();
            let width = frame.width();

            assert!(height >= 0, "VideoFrame has a negative height");
            assert!(width >= 0, "VideoFrame has a negative width");

            let buffer_size = width * height * 4;

            if !*self.first_frame_rendered.borrow() {
                let mut value = Dart_CObject {
                    type_: DartCTypeArray,
                    value: DartCValue {
                        as_array: DartCArray {
                            length: 2,
                            values: &mut [
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32:
                                            TextureEvent::OnFirstFrameRendered
                                                as i32,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI64,
                                    value: DartCValue {
                                        as_int64: self.texture_id,
                                    },
                                } as *mut _,
                            ] as *mut _,
                        },
                    },
                };
                *self.first_frame_rendered.borrow_mut() = true;
                #[allow(clippy::expect_used)]
                unsafe {
                    Dart_PostCObject_DL
                        .expect("dart_api_dl has not been initialized")(
                        self.port, &mut value,
                    )
                };
            }

            if *self.height.borrow() != frame.height()
                || *self.height.borrow() != frame.width()
                || *self.rotation.borrow() != frame.rotation()
            {
                let mut value = Dart_CObject {
                    type_: DartCTypeArray,
                    value: DartCValue {
                        as_array: DartCArray {
                            length: 5,
                            values: &mut [
                                &mut Dart_CObject {
                                    type_: DartCTypeI64,
                                    value: DartCValue {
                                        as_int64: TextureEvent::OnTextureChange
                                            as i64,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI64,
                                    value: DartCValue {
                                        as_int64: self.texture_id,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.rotation().repr,
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.width(),
                                    },
                                } as *mut _,
                                &mut Dart_CObject {
                                    type_: DartCTypeI32,
                                    value: DartCValue {
                                        as_int32: frame.height(),
                                    },
                                } as *mut _,
                            ] as *mut _,
                        },
                    },
                };
                *self.height.borrow_mut() = frame.height();
                *self.width.borrow_mut() = frame.width();
                *self.rotation.borrow_mut() = frame.rotation();

                #[allow(clippy::expect_used)]
                unsafe {
                    Dart_PostCObject_DL
                        .expect("dart_api_dl has not been initialized")(
                        self.port, &mut value,
                    )
                };
            }

            unsafe {
                on_frame_caller(
                    self.inner,
                    Frame {
                        height: height as usize,
                        width: width as usize,
                        buffer_size: buffer_size as usize,
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

    /// Converts the provided [`sys::VideoFrame`] pixel data to `ARGB` scheme
    /// and outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[no_mangle]
    unsafe extern "C" fn get_argb_bytes(
        frame: *mut sys::VideoFrame,
        argb_stride: i32,
        buffer: *mut u8,
    ) {
        libwebrtc_sys::video_frame_to_argb(
            frame.as_ref().unwrap(),
            argb_stride,
            buffer,
        );
    }

    /// Drops the provided [`sys::VideoFrame`].
    #[no_mangle]
    unsafe extern "C" fn drop_frame(frame: *mut sys::VideoFrame) {
        UniquePtr::from_raw(frame);
    }
}
