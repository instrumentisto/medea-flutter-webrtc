use std::{
    rc::Rc,
    sync::atomic::{AtomicU64, Ordering},
};

use anyhow::bail;
use derive_more::{AsRef, Display};
use libwebrtc_sys as sys;

use crate::{
    api::{self, AudioConstraints, VideoConstraints},
    Webrtc,
};

/// This counter provides global resource for generating `unique id`.
static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// Returns an `unique id`.
fn next_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

impl Webrtc {
    /// Creates a new local [`MediaStream`] with [`VideoTrack`]s and/or
    /// [`AudioTrack`]s according to the provided accepted
    /// [`api::MediaStreamConstraints`].
    #[allow(clippy::too_many_lines, clippy::missing_panics_doc)]
    pub fn get_users_media(
        self: &mut Webrtc,
        constraints: &api::MediaStreamConstraints,
    ) -> api::MediaStream {
        let mut stream =
            MediaStream::new(&self.0.peer_connection_factory).unwrap();

        let mut result = api::MediaStream {
            stream_id: stream.id.0,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        };

        // Creating [`VideoTrack`]s.
        if constraints.video.required {
            let source =
                self.get_or_create_video_source(&constraints.video).unwrap();
            let track = self.create_video_track(source).unwrap();

            stream.add_video_track(track).unwrap();
            result.video_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: track.device_label,
                kind: track.kind,
                enabled: true,
            });
        }

        // Creating [`AudioTrack`]s.
        if constraints.audio.required {
            let source =
                self.get_or_create_audio_source(&constraints.audio).unwrap();
            let track = self.create_audio_track(source).unwrap();

            stream.add_audio_track(track).unwrap();
            result.audio_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: track.device_label,
                kind: track.kind,
                enabled: true,
            });

            let track = {
                let track = AudioTrack::new(
                    &self.0.peer_connection_factory,
                    Rc::clone(&source),
                )
                .unwrap();

                self.0.audio_tracks.entry(track.id).or_insert(track)
            };

            stream.inner.add_audio_track(&track.inner).unwrap();
            stream.audio_tracks.push(track.id);

            let audio_device_index =
                self.0.audio_device_module.device_index(&mut device_id);

            result.audio_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: self
                    .0
                    .audio_device_module
                    .recording_device_name(
                        audio_device_index.try_into().unwrap(),
                    )
                    .unwrap()
                    .0,
                kind: track.kind,
                enabled: true,
            });
        };

        self.0
            .local_media_streams
            .entry(stream.id)
            .or_insert(stream);

        result
    }

    /// Disposes the [`MediaStream`] and all involved
    /// [`AudioTrack`]s/[`VideoTrack`]s and
    /// [`AudioSource`]s/[`VideoSource`]s.
    ///
    /// # Panics
    ///
    /// Panics if tracks from the provided stream are not found in the context.
    /// It is an invariant violation.
    pub fn dispose_stream(self: &mut Webrtc, id: u64) {
        if let Some(stream) =
            self.0.local_media_streams.remove(&MediaStreamId(id))
        {
            let video_tracks = stream.video_tracks;
            let audio_tracks = stream.audio_tracks;

            for track in video_tracks {
                let src = self.0.video_tracks.remove(&track).unwrap().src;

                if Rc::strong_count(&src) == 2 {
                    self.0.video_sources.remove(&src.id);
                };
            }

            for track in audio_tracks {
                let src = self.0.audio_tracks.remove(&track).unwrap().src;

                if Rc::strong_count(&src) == 2 {
                    self.0.audio_source.remove(&src.id);
                };
            }
        }
    }

    fn create_video_track(
        &mut self,
        source: Rc<VideoSource>,
    ) -> anyhow::Result<&mut VideoTrack> {
        let track = VideoTrack::new(&self.0.peer_connection_factory, source)?;

        let track = self.0.video_tracks.entry(track.id).or_insert(track);

        Ok(track)
    }

    fn get_or_create_video_source(
        &mut self,
        caps: &VideoConstraints,
    ) -> anyhow::Result<Rc<VideoSource>> {
        let (index, device_id) = if caps.device_id.is_empty() {
            // No device ID is provided so just pick the first available device
            let device_id =
                VideoDeviceId(self.0.video_device_info.device_name(0)?.1);
            (0, device_id)
        } else {
            let device_id = VideoDeviceId(caps.device_id.clone());
            if let Some(index) = self.get_index_of_video_device(&device_id) {
                (index, device_id)
            } else {
                bail!(
                    "Could not find video device with the specified ID `{}`",
                    device_id
                );
            }
        };

        for (_, src) in &self.0.video_sources {
            if src.device_id == device_id {
                return Ok(Rc::clone(src));
            }
        }

        let source = Rc::new(VideoSource::new(
            &mut self.0.peer_connection_factory,
            &caps,
            index,
            device_id,
        )?);
        self.0.video_sources.insert(source.id, Rc::clone(&source));

        Ok(source)
    }

    fn get_or_create_audio_source(
        &mut self,
        caps: &AudioConstraints,
    ) -> anyhow::Result<Rc<AudioSource>> {
        let (device_id) = if caps.device_id.is_empty() {
            // No device ID is provided so just pick the currently used
            self.0.audio_device_module.current_device_id.clone()
        } else {
            AudioDeviceId(caps.device_id.clone())
        };

        let device_index =
            if let Some(index) = self.get_index_of_audio_device(&device_id)? {
                index
            } else {
                bail!(
                    "Could not find audio device with the specified ID `{}`",
                    device_id
                );
            };

        if device_id != self.0.audio_device_module.current_device_id {
            self.0
                .audio_device_module
                .inner
                .set_recording_device(device_index)?;
        }

        let src = if let Some(src) = self.0.audio_source.as_ref() {
            Rc::clone(src)
        } else {
            let src =
                Rc::new(AudioSource::new(&mut self.0.peer_connection_factory)?);
            self.0.audio_source.insert(Rc::clone(&src));

            src
        };

        Ok(src)
    }
}

/// Struct for `id` of [`MediaStream`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct MediaStreamId(u64);

/// Struct for `id` of `VideoDevice`.
#[derive(AsRef, Clone, Debug, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct VideoDeviceId(String);

/// Struct for `id` of [`VideoSource`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct VideoSourceId(u64);

/// Struct for `id` of `AudioDevice`.
#[derive(AsRef, Clone, Debug, Display, Eq, Hash, PartialEq)]
#[as_ref(forward)]
pub struct AudioDeviceId(String);

/// Struct for `id` of [`VideoTrack`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct VideoTrackId(u64);

/// Struct for `id` of [`AudioTrack`].
#[derive(Clone, Copy, Debug, Display, Eq, Hash, PartialEq)]
pub struct AudioTrackId(u64);

/// Is used to manage [`sys::LocalMediaStream`]
/// and all included [`VideoTrack`] and [`AudioTrack`].
pub struct MediaStream {
    id: MediaStreamId,
    inner: sys::LocalMediaStream,
    video_tracks: Vec<VideoTrackId>,
    audio_tracks: Vec<AudioTrackId>,
}

impl MediaStream {
    /// Creates a new [`MediaStream`].
    fn new(pc: &sys::PeerConnectionFactory) -> anyhow::Result<Self> {
        let id = MediaStreamId(next_id());
        Ok(Self {
            id,
            inner: pc.create_local_media_stream(id.to_string())?,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        })
    }

    fn add_video_track(&mut self, track: &VideoTrack) -> anyhow::Result<()> {
        self.inner.add_video_track(&track.inner)?;
        self.video_tracks.push(track.id);

        Ok(())
    }
}

/// Is used to manage [`sys::VideoTrack`].
pub struct VideoTrack {
    id: VideoTrackId,
    inner: sys::VideoTrack,
    src: Rc<VideoSource>,
    kind: api::TrackKind,
}

impl VideoTrack {
    /// Creates a new [`VideoTrack`].
    fn new(
        pc: &sys::PeerConnectionFactory,
        src: Rc<VideoSource>,
    ) -> anyhow::Result<Self> {
        let id = VideoTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_video_track(id.to_string(), &src.inner)?,
            src,
            kind: api::TrackKind::kVideo,
        })
    }
}

/// Is used to manage [`sys::VideoSource`].
pub struct VideoSource {
    id: VideoSourceId,
    inner: sys::VideoSource,
    device_id: VideoDeviceId,
}

impl VideoSource {
    /// Creates a new [`VideoSource`].
    fn new(
        pc: &mut sys::PeerConnectionFactory,
        caps: &api::VideoConstraints,
        device_index: u32,
        device_id: VideoDeviceId,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: VideoSourceId(next_id()),
            inner: sys::VideoSource::create(
                &mut pc.worker_thread,
                &mut pc.signaling_thread,
                caps.width,
                caps.height,
                caps.frame_rate,
                device_index,
            )?,
            device_id,
        })
    }
}

/// Is used to manage [`sys::VideoSource`].
pub struct AudioTrack {
    id: AudioTrackId,
    inner: sys::AudioTrack,
    src: Rc<AudioSource>,
    kind: api::TrackKind,
}

impl AudioTrack {
    /// Creates a new [`AudioTrack`].
    fn new(
        pc: &sys::PeerConnectionFactory,
        src: Rc<AudioSource>,
    ) -> anyhow::Result<Self> {
        let id = AudioTrackId(next_id());
        Ok(Self {
            id,
            inner: pc.create_audio_track(id.to_string(), &src.inner)?,
            src,
            kind: api::TrackKind::kAudio,
        })
    }
}

/// Is used to manage [`sys::VideoSource`].
pub struct AudioSource {
    inner: sys::AudioSource,
}

impl AudioSource {
    /// Creates a new [`AudioSource`].
    fn new(pc: &sys::PeerConnectionFactory) -> anyhow::Result<Self> {
        Ok(Self {
            inner: pc.create_audio_source()?,
        })
    }
}
