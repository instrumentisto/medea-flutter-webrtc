use std::{mem, rc::Rc};

use crate::{Frame, MediaStreamId, Webrtc};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

/// Identifier of the `Flutter Texture`, used as [`Renderer`] `id`.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct TextureId(i64);

/// [`sys::Renderer`] wrapper.
pub struct Renderer {
    texture_id: Rc<TextureId>,
    inner: sys::Renderer,
}

impl Renderer {
    /// Notifies that [`VideoTrack`] used in this [`Renderer`] does not exist.
    ///
    /// [`VideoTrack`]:crate::VideoTrack
    fn set_no_track(&mut self) {
        self.inner.set_no_track();
    }
}

/// Callback which passed to `libWebRTC`.
pub fn cb(frame_ptr: UniquePtr<sys::VideoFrame>, flutter_cb_ptr: usize) {
    let frame = Frame::create(frame_ptr);

    unsafe {
        let flutter_cb: extern "C" fn(*mut Frame) =
            mem::transmute(flutter_cb_ptr);

        flutter_cb(Box::into_raw(Box::new(frame)));
    }
}

/// Registers `FlutterRenderer` according to the given [`TextureId`],
/// [`MediaStreamId`] and `FlutterVideoRenderer::OnFrame()`.
#[no_mangle]
unsafe extern "C" fn register_renderer(
    webrtc: &mut Box<Webrtc>,
    texture_id: i64,
    stream_id: u64,
    cpp_cb: extern "C" fn(*mut Frame),
) {
    let this = webrtc.as_mut().0.as_mut();

    let video_track_id = this
        .local_media_streams
        .get(&MediaStreamId(stream_id))
        .unwrap()
        .get_first_track_id();

    let current_renderer = Renderer {
        texture_id: Rc::new(TextureId(texture_id)),
        inner: sys::Renderer::create(
            cb,
            mem::transmute_copy(&cpp_cb),
            &**this.video_tracks.get(video_track_id).unwrap(),
        ),
    };

    this.video_tracks
        .get_mut(video_track_id)
        .unwrap()
        .add_renderer(Rc::clone(&current_renderer.texture_id));

    this.renderers
        .insert(TextureId(texture_id), current_renderer);
}

impl Webrtc {
    /// Drops the [`Renderer`] according to the given [`TextureId`].
    ///
    /// # Panics
    ///
    /// May panic on taking [`Renderer`] as mut.
    pub fn dispose_renderer(&mut self, texture_id: i64) {
        let renderer =
            self.0.renderers.get_mut(&TextureId(texture_id)).unwrap();

        let no_track = Rc::strong_count(&renderer.texture_id) < 2;

        if no_track {
            renderer.set_no_track();
        }

        self.0.renderers.remove(&TextureId(texture_id)).unwrap();
    }
}
