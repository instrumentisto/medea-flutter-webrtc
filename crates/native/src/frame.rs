use crate::api;
use cxx::UniquePtr;
use libwebrtc_sys as sys;

/// [`sys::VideoFrame`] wrapper.
pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

impl Frame {
    /// Creates a new [`Frame`].
    pub fn create(sys_frame: UniquePtr<sys::VideoFrame>) -> Self {
        Self(Box::new(sys_frame))
    }

    /// Returns the [`Frame`]'s width.
    pub fn width(&self) -> i32 {
        self.0.width()
    }

    /// Returns the [`Frame`]'s height.
    pub fn height(&self) -> i32 {
        self.0.height()
    }

    /// Returns the [`Frame`]'s [`api::VideoRotation`].
    pub fn rotation(&self) -> api::VideoRotation {
        match self.0.rotation().repr {
            0 => api::VideoRotation::kVideoRotation_0,
            90 => api::VideoRotation::kVideoRotation_90,
            180 => api::VideoRotation::kVideoRotation_180,
            270 => api::VideoRotation::kVideoRotation_270,
            _ => Result::Err("Invalid value.").unwrap(),
        }
    }

    /// Returns the [`Frame`]'s size.
    pub fn buffer_size(&self) -> i32 {
        // TODO: what is 32???
        self.width() * self.height() * (32 >> 3)
    }

    /// Writes the [`Frame`]'s bytes to the given `buffer` as `ABGR buffer`.
    pub unsafe fn buffer(self: &Frame, bptr: *mut u8) {
        sys::convert_to_argb(self.0.as_ref(), bptr);
    }
}

/// Drops the [`Frame`] by the given `*mut Frame`.
pub unsafe fn delete_frame(frame_ptr: *mut Frame) {
    let _ = Box::from_raw(frame_ptr);
}
