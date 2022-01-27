use crate::{
    internal::OnFrameHandler, Frame, MediaStreamId, VideoTrackId, Webrtc,
};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

struct OnFrameHandlerWrapper(UniquePtr<OnFrameHandler>);

impl libwebrtc_sys::Callback for OnFrameHandlerWrapper {
    fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
        let frame = Frame::create(frame);

        unsafe {
            self.0.pin_mut().on_frame(Box::into_raw(Box::new(frame)));
        }
    }
}

/// Identifier of the `Flutter Texture`, used as [`Renderer`] `id`.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct TextureId(i64); // TODO: RendererId

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

impl Webrtc {
    pub unsafe fn create_renderer(
        &mut self,
        texture_id: i64,
        stream_id: u64,
        handler: UniquePtr<OnFrameHandler>,
    ) {
        let this = self.0.as_mut();

        let video_track_id = this
            .local_media_streams
            .get(&MediaStreamId::from(stream_id))
            .unwrap()
            .get_first_track_id();

        let mut current_renderer = Renderer {
            texture_id: TextureId(texture_id),
            inner: sys::RendererSink::create(Box::new(OnFrameHandlerWrapper(
                handler,
            ))),
            video_track_id: *video_track_id,
        };

        this.video_tracks
            .get_mut(video_track_id)
            .unwrap()
            .add_renderer(&mut current_renderer);

        this.renderers
            .insert(TextureId(texture_id), current_renderer);

        // unsafe {
        //     handler
        //         .pin_mut()
        //         .on_frame(Box::into_raw(Box::new(())).cast())
        // };
    }

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
