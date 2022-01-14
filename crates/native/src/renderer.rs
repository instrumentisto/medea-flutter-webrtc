use std::{mem, ops::Deref, rc::Rc};

use crate::{Frame, MediaStreamId, Webrtc};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

pub type TextureId = i64;

pub struct Renderer {
    texture_id: Rc<TextureId>,
    inner: sys::Renderer,
    callback: extern "C" fn(*mut Frame),
}

impl Renderer {
    pub fn set_no_track(&mut self) {
        self.inner.set_no_track();
    }
}

pub fn cb(frame: UniquePtr<sys::VideoFrame>, flutter_cb_ptr: usize) {
    let a = Frame::create(frame);

    unsafe {
        let flutter_cb: extern "C" fn(*mut Frame) =
            mem::transmute(flutter_cb_ptr);

        flutter_cb(Box::into_raw(Box::new(a)));
    }
}

#[no_mangle]
unsafe extern "C" fn foo(
    webrtc: &mut Box<Webrtc>,
    texture_id: TextureId,
    stream_id: MediaStreamId,
    cpp_cb: extern "C" fn(*mut Frame),
) {
    let this = webrtc.as_mut().0.as_mut();

    let video_track_id = this
        .local_media_streams
        .get(&stream_id)
        .unwrap()
        .get_first_track_id();

    let mut current_renderer = Renderer {
        texture_id: Rc::new(texture_id),
        inner: sys::Renderer::create(
            cb,
            mem::transmute_copy(&cpp_cb),
            &this.video_tracks.get(video_track_id).unwrap().deref(),
        ),
        callback: cpp_cb,
    };

    this.video_tracks
        .get_mut(video_track_id)
        .unwrap()
        .add_renderer(Rc::clone(&current_renderer.texture_id));

    this.renderers.insert(texture_id, current_renderer);
}

impl Webrtc {
    pub fn dispose_renderer(&mut self, texture_id: TextureId) {
        let renderer = self.0.renderers.get_mut(&texture_id).unwrap();

        let no_track = Rc::strong_count(&renderer.texture_id) < 2;

        if no_track {
            renderer.set_no_track();
        }

        self.0.renderers.remove(&texture_id).unwrap();
    }
}
