use crate::api;
use cxx::UniquePtr;
use libwebrtc_sys as sys;

/// [`sys::VideoFrame`] wrapper.
pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

impl Frame {
    /// Creates a new [`Frame`].
    #[must_use]
    pub fn create(sys_frame: UniquePtr<sys::VideoFrame>) -> Self {
        Self(Box::new(sys_frame))
    }

    /// Returns the [`Frame`]'s width.
    #[must_use]
    pub fn width(&self) -> i32 {
        self.0.width()
    }

    /// Returns the [`Frame`]'s height.
    #[must_use]
    pub fn height(&self) -> i32 {
        self.0.height()
    }

    /// Returns the [`Frame`]'s [`api::VideoRotation`].
    #[must_use]
    pub fn rotation(&self) -> api::VideoRotation {
        match self.0.rotation().repr {
            90 => api::VideoRotation::kVideoRotation_90,
            180 => api::VideoRotation::kVideoRotation_180,
            270 => api::VideoRotation::kVideoRotation_270,
            _ => api::VideoRotation::kVideoRotation_0,
        }
    }

    /// Returns the [`Frame`]'s size.
    #[must_use]
    pub fn buffer_size(&self) -> i32 {
        self.width() * self.height() * 4
    }

    /// Writes the [`Frame`]'s bytes to the given `buffer` as `ABGR buffer`.
    ///
    /// # Safety
    ///
    /// Must be given u8 buffer.
    pub unsafe fn buffer(self: &Frame, bptr: *mut u8) {
        sys::i420_to_abgr(self.0.as_ref(), bptr);
    }
}

/// Drops the [`Frame`] by the given `*mut Frame`.
///
/// # Safety
///
/// Must be given pointer from [`Frame`].
pub unsafe fn delete(frame_ptr: *mut Frame) {
    drop(Box::from_raw(frame_ptr));
}
