use cxx::{CxxVector, UniquePtr};

use crate::*;
pub struct FrameInner(pub UniquePtr<webrtc::VideoFrame>);

pub struct Frame(pub Box<FrameInner>);

impl Frame {
    pub fn width(self: &Frame) -> i32 {
        webrtc::frame_width(&self.0 .0)
    }

    pub fn height(self: &Frame) -> i32 {
        webrtc::frame_height(&self.0 .0)
    }

    pub fn rotation(self: &Frame) -> ffi::VideoRotation {
        match webrtc::frame_rotation(&self.0 .0) {
            0 => ffi::VideoRotation::kVideoRotation_0,
            90 => ffi::VideoRotation::kVideoRotation_90,
            180 => ffi::VideoRotation::kVideoRotation_180,
            270 => ffi::VideoRotation::kVideoRotation_270,
            _ => Result::Err("Invalid value.").unwrap(),
        }
    }

    pub fn buffer_size(self: &Frame) -> i32 {
        self.width() * self.height() * (32 >> 3)
    }

    pub unsafe fn buffer(self: &Frame) -> UniquePtr<CxxVector<u8>> {
        webrtc::convert_to_argb(&self.0 .0, self.buffer_size())
    }
}

pub unsafe fn delete_frame(frame_ptr: *mut Frame) {
    let _ = Box::from_raw(frame_ptr);
}
