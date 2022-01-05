use core::panic;
use std::mem;

use cxx::UniquePtr;

use crate::*;

pub struct Renderer {
    texture_id: Rc<TextureId>,
    pointer: UniquePtr<webrtc::VideoRenderer>,
    callback: extern "C" fn(*mut Frame),
}

pub fn cb(frame: UniquePtr<webrtc::VideoFrame>, flutter_cb_ptr: usize) {
    let a = Frame(Box::new(FrameInner(frame)));

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
    stream_id: StreamId,
    cpp_cb: extern "C" fn(*mut Frame),
) {
    let this = webrtc.as_mut().0.as_mut();

    let mut current_renderer = Renderer {
        texture_id: Rc::new(texture_id),
        pointer: UniquePtr::null(),
        callback: cpp_cb,
    };

    let video_track_id =
        this.local_media_streams[&stream_id].video_tracks[0].as_str();

    current_renderer.pointer = webrtc::get_video_renderer(
        cb,
        mem::transmute_copy(&current_renderer.callback),
        &this.video_tracks[video_track_id].ptr.0,
    );

    this.video_tracks
        .get_mut(video_track_id)
        .unwrap()
        .renderers
        .push(Rc::clone(&current_renderer.texture_id));

    this.renderers.insert(texture_id, current_renderer);
}

pub fn dispose_renderer(webrtc: &mut Box<Webrtc>, texture_id: TextureId) {
    let this = webrtc.as_mut().0.as_mut();

    let no_track =
        Rc::strong_count(&this.renderers[&texture_id].texture_id) < 2;

    if no_track {
        webrtc::set_renderer_no_track(&this.renderers[&texture_id].pointer);
    }

    this.renderers.remove(&texture_id).unwrap();
}
