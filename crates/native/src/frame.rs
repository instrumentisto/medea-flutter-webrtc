use crate::api;
use cxx::UniquePtr;
use libwebrtc_sys as sys;

pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

impl Frame {
    pub fn create(sys_frame: UniquePtr<sys::VideoFrame>) -> Self {
        Self(Box::new(sys_frame))
    }

    pub fn width(&self) -> i32 {
        self.0.width()
    }

    pub fn height(&self) -> i32 {
        self.0.height()
    }

    pub fn rotation(&self) -> api::VideoRotation {
        match self.0.rotation().repr {
            0 => api::VideoRotation::kVideoRotation_0,
            90 => api::VideoRotation::kVideoRotation_90,
            180 => api::VideoRotation::kVideoRotation_180,
            270 => api::VideoRotation::kVideoRotation_270,
            _ => Result::Err("Invalid value.").unwrap(),
        }
    }

    pub fn buffer_size(&self) -> i32 {
        // TODO: what is 32???
        self.width() * self.height() * (32 >> 3)
    }

    pub unsafe fn buffer(self: &Frame) -> Vec<u8> {
        sys::convert_to_argb(self.0.as_ref(), self.buffer_size())
    }
}

pub unsafe fn delete_frame(frame_ptr: *mut Frame) {
    let _ = Box::from_raw(frame_ptr);
}
