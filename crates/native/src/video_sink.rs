use crate::{internal, Frame, MediaStreamId, VideoTrackId, Webrtc};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

/// An [`internal::OnFrameHandler`] wrapper.
struct OnFrameHandler(UniquePtr<internal::OnFrameHandler>);

impl libwebrtc_sys::OnFrameCallback for OnFrameHandler {
    /// Implementation of the `OnFrame` `callback`.
    fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
        let frame = Frame::create(frame);

        unsafe {
            self.0.pin_mut().on_frame(Box::into_raw(Box::new(frame)));
        }
    }
}

/// Identifier of the `Flutter Texture`, used as [`VideoSink`] `id`.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct Id(i64);

/// A [`sys::VideoSink`] wrapper.
pub struct VideoSink {
    id: Id,
    inner: sys::VideoSink,
    video_track_id: VideoTrackId,
}

impl VideoSink {
    /// Returns the [`VideoSink`]'s [`Id`].
    #[must_use]
    pub fn get_id(&self) -> &Id {
        &self.id
    }
}

impl AsMut<sys::VideoSink> for VideoSink {
    fn as_mut(&mut self) -> &mut sys::VideoSink {
        &mut self.inner
    }
}

impl Webrtc {
    /// Creates a new [`VideoSink`].
    ///
    /// # Panics
    ///
    /// May panic on getting some [`MediaStream`] by the [`MediaStreamId`].
    pub fn create_video_sink(
        &mut self,
        id: i64,
        stream_id: u64,
        handler: UniquePtr<internal::OnFrameHandler>,
    ) {
        let this = self.0.as_mut();

        let video_track_id = this
            .local_media_streams
            .get(&MediaStreamId::from(stream_id))
            .unwrap()
            .get_first_track_id();

        let mut current_video_sink = VideoSink {
            id: Id(id),
            inner: sys::VideoSink::create(Box::new(OnFrameHandler(handler))),
            video_track_id: *video_track_id,
        };

        this.video_tracks
            .get_mut(video_track_id)
            .unwrap()
            .add_video_sink(&mut current_video_sink);

        this.video_sinks.insert(Id(id), current_video_sink);
    }

    /// Drops the [`VideoSink`] according to the given [`Id`].
    ///
    /// # Panics
    ///
    /// May panic on taking [`VideoSink`] as mut.
    pub fn dispose_video_sink(&mut self, texture_id: i64) {
        let video_sink = self.0.video_sinks.remove(&Id(texture_id)).unwrap();

        let video_track =
            self.0.video_tracks.get_mut(&video_sink.video_track_id);

        if let Some(track) = video_track {
            track.remove_video_sink(video_sink);
        }
    }
}
