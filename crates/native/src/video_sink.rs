use crate::{internal, MediaStreamId, VideoTrackId, Webrtc, api};

use cxx::UniquePtr;
use libwebrtc_sys as sys;

use crate::api::VideoFrame;

pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

impl api::VideoFrame {
    /// Converts this [`api::VideoFrame`] pixel data to the `ABGR` scheme and
    /// outputs the data to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[allow(clippy::unused_self)]
    pub unsafe fn get_abgr_bytes(self: &api::VideoFrame, buffer: *mut u8) {
        libwebrtc_sys::video_frame_to_abgr(self.frame.0.as_ref(), buffer);
    }
}

/// An [`internal::OnFrameCallbackInterface`] wrapper.
struct OnFrameCallback(UniquePtr<internal::OnFrameCallbackInterface>);

impl libwebrtc_sys::OnFrameCallback for OnFrameCallback {
    /// Implementation of the `OnFrame` `callback`.
    #[allow(clippy::cast_sign_loss)]
    fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
        let height = frame.height() as usize;
        let width = frame.width() as usize;
        let buffer_size = width * height * 4;

        println!("on_frame");

        unsafe {
            self.0.pin_mut().on_frame(VideoFrame {
                height,
                width,
                buffer_size,
                rotation: frame.rotation().repr,
                frame: Box::new(Frame(Box::new(frame)))
            });
        }
    }
}

/// Identifier of the `Flutter Texture`, used as [`VideoSink`] `id`.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct Id(i64);

/// A [`sys::VideoSink`] wrapper.
pub struct VideoSink {
    id: Id,
    inner: sys::VideoSinkInterface,
    video_track_id: VideoTrackId,
}

impl VideoSink {
    /// Returns the [`VideoSink`]'s [`Id`].
    #[must_use]
    pub fn get_id(&self) -> &Id {
        &self.id
    }
}

impl AsMut<sys::VideoSinkInterface> for VideoSink {
    fn as_mut(&mut self) -> &mut sys::VideoSinkInterface {
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
        handler: UniquePtr<internal::OnFrameCallbackInterface>,
    ) {
        println!("create_video_sink");
        let this = self.0.as_mut();

        let video_track_id = this
            .local_media_streams
            .get(&MediaStreamId::from(stream_id))
            .unwrap()
            .get_first_track_id();

        let mut current_video_sink = VideoSink {
            id: Id(id),
            inner: sys::VideoSinkInterface::create_forwarding(Box::new(
                OnFrameCallback(handler),
            )),
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
    pub fn dispose_video_sink(&mut self, sink_id: i64) {
        let video_sink = self.0.video_sinks.remove(&Id(sink_id)).unwrap();

        let video_track =
            self.0.video_tracks.get_mut(&video_sink.video_track_id);

        if let Some(track) = video_track {
            track.remove_video_sink(video_sink);
        }
    }
}
