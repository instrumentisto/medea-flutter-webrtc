use std::mem;

use crate::{Frame, MediaStreamId, VideoTrackId, Webrtc};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

/// Identifier of the `Flutter Texture`, used as [`Renderer`] `id`.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct TextureId(i64); // TODO: RendererId asdasd

/// [`sys::Renderer`] wrapper.
pub struct Renderer {
    texture_id: TextureId,
    inner: sys::RendererSink,
    video_track_id: VideoTrackId,
}

impl Renderer {
    #[must_use]
    pub fn get_texture_id(&self) -> &TextureId {
        &self.texture_id
    }
}

impl AsMut<sys::RendererSink> for Renderer {
    fn as_mut(&mut self) -> &mut sys::RendererSink {
        &mut self.inner
    }
}

/// Registers `FlutterRenderer` according to the given [`TextureId`],
/// [`MediaStreamId`] and `FlutterVideoRenderer::OnFrame()`.
#[no_mangle]
unsafe extern "C" fn register_renderer(
    webrtc: &mut Box<Webrtc>,
    texture_id: i64,
    stream_id: u64,
    cpp_cb: OnFrameCallback,
) {
    let this = webrtc.as_mut().0.as_mut();

    // TODO: remove MediaStream, call the certain VideoTrack.
    let video_track_id = this
        .local_media_streams
        .get(&MediaStreamId::from(stream_id))
        .unwrap()
        .get_first_track_id();

    let mut current_renderer = Renderer {
        texture_id: TextureId(texture_id),
        inner: sys::RendererSink::create(cb, mem::transmute_copy(&cpp_cb)),
        video_track_id: *video_track_id,
    };

    this.video_tracks
        .get_mut(video_track_id)
        .unwrap()
        .add_renderer(&mut current_renderer);

    this.renderers
        .insert(TextureId(texture_id), current_renderer);
}

/// Callback which passed to `libWebRTC`.
unsafe fn cb(frame: UniquePtr<sys::VideoFrame>, on_frame_cb: usize) {
    let frame = Frame::create(frame);

    let on_frame_cb: OnFrameCallback = mem::transmute(on_frame_cb);

    on_frame_cb(Box::into_raw(Box::new(frame)));
}

impl Webrtc {
    /// Drops the [`Renderer`] according to the given [`TextureId`].
    ///
    /// # Panics
    ///
    /// May panic on taking [`Renderer`] as mut.
    pub fn dispose_renderer(&mut self, texture_id: i64) {
        let renderer = self.0.renderers.remove(&TextureId(texture_id)).unwrap();

        let video_track = self.0.video_tracks.get_mut(&renderer.video_track_id);

        if let Some(track) = video_track {
            track.remove_renderer(renderer);
        }
    }
}
