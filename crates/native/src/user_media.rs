use std::{rc::Rc, sync::atomic::Ordering};

use libwebrtc_sys as sys;

use crate::{api, Webrtc};

use std::sync::atomic::AtomicU64;

/// This counter provides global resource for generating `unique id`.
static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// Returns an `unique id`.
fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

/// Struct for `id` of [`MediaStream`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct MediaStreamId(u64);

/// Struct for `id` of `VideoDevice`.
#[derive(Hash, Clone, PartialEq, Eq)]
pub struct VideoDeviceId(String);

/// Struct for `id` of [`VideoSource`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct VideoSourceId(u64);

/// Struct for `id` of `AudioDevice`.
#[derive(Hash, Clone, PartialEq, Eq)]
pub struct AudioDeviceId(String);

/// Struct for `id` of [`AudioSource`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct AudioSourceId(u64);

/// Struct for `id` of [`VideoTrack`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct VideoTrackId(u64);

/// Struct for `id` of [`AudioTrack`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
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
        Ok(Self {
            id: MediaStreamId(generate_id()),
            inner: pc.create_local_media_stream()?,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        })
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
        Ok(Self {
            id: VideoTrackId(generate_id()),
            inner: pc.create_video_track(&src.inner)?,
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
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: VideoSourceId(generate_id()),
            inner: sys::VideoSource::create(
                &mut pc.worker_thread,
                &mut pc.signaling_thread,
                caps.min_width,
                caps.min_height,
                caps.min_fps,
                caps.device_id.to_string(),
            )?,
            device_id: VideoDeviceId(caps.device_id.to_string()),
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
        Ok(Self {
            id: AudioTrackId(generate_id()),
            inner: pc.create_audio_track(&src.inner)?,
            src,
            kind: api::TrackKind::kAudio,
        })
    }
}

/// Is used to manage [`sys::VideoSource`].
pub struct AudioSource {
    id: AudioSourceId,
    inner: sys::AudioSource,
    device_id: AudioDeviceId,
}

impl AudioSource {
    /// Creates a new [`AudioSource`].
    fn new(
        pc: &sys::PeerConnectionFactory,
        caps: &api::AudioConstraints,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: AudioSourceId(generate_id()),
            inner: pc.create_audio_source()?,
            device_id: AudioDeviceId(caps.device_id.to_string()),
        })
    }
}

impl Webrtc {
    /// Creates a new local [`MediaStream`]
    /// with [`VideoTrack`]s and/or [`AudioTrack`]s
    /// according to accepted [`api::MediaStreamConstraints`].
    ///
    /// # Panics
    ///
    /// TODO: Don't panic.
    #[allow(clippy::too_many_lines)]
    pub fn get_users_media(
        self: &mut Webrtc,
        constraints: &api::MediaStreamConstraints,
    ) -> api::MediaStream {
        // Creating a [`MediaStream`].
        let stream = {
            let stream =
                MediaStream::new(&self.0.peer_connection_factory).unwrap();

            self.0
                .local_media_streams
                .entry(stream.id)
                .or_insert(stream)
        };

        let mut result = api::MediaStream {
            stream_id: stream.id.0,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        };

        // Creating [`VideoTrack`]s.
        if constraints.video.required {
            let mut device_id = match constraints.video.device_id.as_str() {
                "" => self.0.video_device_info.device_name(0).unwrap().1,
                other => other.to_string(),
            };

            let source = {
                let mut existing_source: Option<Rc<VideoSource>> = None;

                for src in &self.0.video_sources {
                    if src.1.device_id.0 == device_id {
                        existing_source = Some(Rc::clone(src.1));
                        break;
                    }
                }

                if let Some(src) = existing_source {
                    src
                } else {
                    let source = Rc::new(
                        VideoSource::new(
                            &mut self.0.peer_connection_factory,
                            &constraints.video,
                        )
                        .unwrap(),
                    );
                    self.0.video_sources.insert(source.id, Rc::clone(&source));
                    source
                }
            };
            let track = {
                let track =
                    VideoTrack::new(&self.0.peer_connection_factory, source)
                        .unwrap();

                self.0.video_tracks.entry(track.id).or_insert(track)
            };
            stream.inner.add_video_track(&track.inner).unwrap();
            stream.video_tracks.push(track.id);

            let video_device_index =
                self.0.video_device_info.device_index(&mut device_id);

            result.video_tracks.push(api::MediaStreamTrack {
                id: track.id.0,
                label: self
                    .0
                    .video_device_info
                    .device_name(video_device_index)
                    .unwrap()
                    .0,
                kind: track.kind,
                enabled: true,
            });
        }

        // Creating [`AudioTrack`]s.
        if constraints.audio.required {
            let mut device_id = match constraints.audio.device_id.as_str() {
                "" => {
                    self.0
                        .audio_device_module
                        .recording_device_name(0)
                        .unwrap()
                        .1
                }
                other => other.to_string(),
            };

            let source = {
                let mut existing_source: Option<Rc<AudioSource>> = None;

                for src in &self.0.audio_sources {
                    if src.1.device_id.0 == device_id {
                        existing_source = Some(Rc::clone(src.1));
                        break;
                    }
                }

                if let Some(src) = existing_source {
                    src
                } else {
                    let source = Rc::new(
                        AudioSource::new(
                            &self.0.peer_connection_factory,
                            &constraints.audio,
                        )
                        .unwrap(),
                    );
                    self.0.audio_sources.insert(source.id, Rc::clone(&source));
                    source
                }
            };
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
                    self.0.audio_sources.remove(&src.id);
                };
            }
        }
    }
}
