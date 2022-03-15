use std::{cell::RefCell, rc::Rc};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

use crate::{
    api_::{MediaDeviceInfo, MediaStreamConstraints, MediaStream},
    init,
    video_sink::{Id, OnFrameCallback},
    MediaStreamId, VideoSink, Webrtc, api::OnFrameCallbackInterface,
};

pub static mut WEBRTC: Option<Rc<RefCell<Box<Webrtc>>>> = None;

pub fn webrtc_init() {
    unsafe {
        match WEBRTC {
            None => WEBRTC = Some(Rc::new(RefCell::new(init()))),
            _ => (),
        }
    }
}

pub fn create_video_sink(sink_id: i64, stream_id: u64, callback_ptr: u64) {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    let handler: UniquePtr<OnFrameCallbackInterface> =
        unsafe { std::mem::transmute(callback_ptr) };
    webrtc.create_video_sink(sink_id, stream_id, handler);
}

pub fn dispose_video_sink(sink_id: i64) {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    webrtc.dispose_video_sink(sink_id);
}

pub fn enumerate_devices() -> Vec<MediaDeviceInfo> {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    webrtc.enumerate_devices()
}

// pub fn get_media(
//     constraints: MediaStreamConstraints,
//     is_display: bool,
// ) -> MediaStream {
//     webrtc_init();
//     let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
//     webrtc.get_media(&constraints, is_display)
// }