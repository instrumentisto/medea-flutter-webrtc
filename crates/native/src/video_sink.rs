use cxx::UniquePtr;
use derive_more::{AsMut, AsRef};
use libwebrtc_sys as sys;

use crate::{cpp_api, VideoTrackId, Webrtc};

impl Webrtc {
    /// Creates a new [`VideoSink`].
    ///
    /// # Panics
    ///
    /// If the specified [`MediaStream`] cannot be found, or if it's found
    /// without any [`VideoTrack`]s.
    pub fn create_video_sink(
        &mut self,
        sink_id: i64,
        track_id: u64,
        handler: UniquePtr<cpp_api::OnFrameCallbackInterface>,
    ) {
        let mut sink = VideoSink {
            id: Id(sink_id),
            inner: sys::VideoSinkInterface::create_forwarding(Box::new(OnFrameCallback(
                handler,
            ))),
            track_id: track_id.into(),
        };

        self.video_tracks
            .get_mut(&track_id.into())
            .unwrap()
            .add_video_sink(&mut sink);

        self.video_sinks.insert(Id(sink_id), sink);
    }

    /// Destroys a [`VideoSink`] by the given ID.
    pub fn dispose_video_sink(&mut self, sink_id: i64) {
        if let Some(sink) = self.video_sinks.remove(&Id(sink_id)) {
            if let Some(mut track) = self.video_tracks.get_mut(&sink.track_id) {
                track.remove_video_sink(sink);
            }
        }
    }
}

/// ID of a [`VideoSink`].
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub struct Id(pub(crate) i64);

/// Wrapper around a [`sys::VideoSink`] attaching a unique ID to it.
#[derive(AsRef, AsMut)]
pub struct VideoSink {
    /// ID of this [`VideoSink`].
    pub(crate) id: Id,

    /// Underlying [`sys::VideoSinkInterface`].
    #[as_ref]
    #[as_mut]
    pub(crate) inner: sys::VideoSinkInterface,

    /// ID of the [`VideoTrack`] attached to this [`VideoSink`].
    pub(crate) track_id: VideoTrackId,
}

impl VideoSink {
    /// Returns an [`Id`] of this [`VideoSink`].
    #[must_use]
    pub fn id(&self) -> Id {
        self.id
    }
}

/// Wrapper around a [`sys::VideoFrame`] transferable via FFI.
pub struct Frame(Box<UniquePtr<sys::VideoFrame>>);

impl cpp_api::VideoFrame {
    /// Converts this [`api::VideoFrame`] pixel data to the `ABGR` scheme and
    /// outputs the result to the provided `buffer`.
    ///
    /// # Safety
    ///
    /// The provided `buffer` must be a valid pointer.
    #[allow(clippy::unused_self)]
    pub unsafe fn get_abgr_bytes(self: &cpp_api::VideoFrame, buffer: *mut u8) {
        libwebrtc_sys::video_frame_to_abgr(self.frame.0.as_ref(), buffer);
    }
}

impl From<UniquePtr<sys::VideoFrame>> for cpp_api::VideoFrame {
    #[allow(clippy::cast_sign_loss)]
    fn from(frame: UniquePtr<sys::VideoFrame>) -> Self {
        let height = frame.height();
        let width = frame.width();

        assert!(height >= 0, "VideoFrame has a negative height");
        assert!(width >= 0, "VideoFrame has a negative width");

        let buffer_size = width * height * 4;

        Self {
            height: height as usize,
            width: width as usize,
            buffer_size: buffer_size as usize,
            rotation: frame.rotation().repr,
            frame: Box::new(Frame(Box::new(frame))),
        }
    }
}

/// Wrapper around an [`internal::OnFrameCallbackInterface`] implementing the
/// required interfaces.
struct OnFrameCallback(UniquePtr<cpp_api::OnFrameCallbackInterface>);

impl libwebrtc_sys::OnFrameCallback for OnFrameCallback {
    fn on_frame(&mut self, frame: UniquePtr<sys::VideoFrame>) {
        self.0.pin_mut().on_frame(cpp_api::VideoFrame::from(frame));
    }
}
