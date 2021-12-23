use std::rc::Rc;

use libwebrtc_sys as sys;

use crate::{api, Webrtc};

// TODO: use new-types, dont hardcode IDs
pub type MediaStreamId = u64;
pub type VideoSourceId = u64;
pub type AudioSourceId = u64;
pub type VideoTrackId = u64;
pub type AudioTrackId = u64;

pub struct MediaStream {
    id: MediaStreamId,
    inner: sys::LocalMediaStream,
    video_tracks: Vec<VideoTrackId>,
    audio_tracks: Vec<AudioTrackId>,
}

impl MediaStream {
    fn new(pc: &sys::PeerConnectionFactory) -> anyhow::Result<Self> {
        Ok(Self {
            id: 0,
            inner: pc.create_local_media_stream()?,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        })
    }
}

pub struct VideoTrack {
    id: VideoTrackId,
    inner: sys::VideoTrack,
    src: Rc<VideoSource>,
    kind: api::TrackKind,
}

impl VideoTrack {
    fn new(
        pc: &sys::PeerConnectionFactory,
        src: Rc<VideoSource>,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: 0,
            inner: pc.create_video_track(&src.inner)?,
            src,
            kind: api::TrackKind::kVideo,
        })
    }
}

pub struct VideoSource {
    id: VideoSourceId,
    inner: sys::VideoSource,
}

impl VideoSource {
    fn new(
        pc: &mut sys::PeerConnectionFactory,
        caps: &api::VideoConstraints,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: 0,
            inner: pc.create_video_source(
                caps.min_width,
                caps.min_height,
                caps.min_width,
            )?,
        })
    }
}

pub struct AudioTrack {
    id: AudioTrackId,
    inner: sys::AudioTrack,
    src: AudioSourceId,
    kind: api::TrackKind,
}

impl AudioTrack {
    fn new(
        pc: &sys::PeerConnectionFactory,
        src: &AudioSource,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            id: 0,
            inner: pc.create_audio_track(&src.inner)?,
            src: src.id,
            kind: api::TrackKind::kAudio,
        })
    }
}

pub struct AudioSource {
    id: AudioSourceId,
    inner: sys::AudioSource,
}

impl AudioSource {
    fn new(pc: &sys::PeerConnectionFactory) -> anyhow::Result<Self> {
        Ok(Self {
            id: 0,
            inner: pc.create_audio_source()?,
        })
    }
}

impl Webrtc {
    /// Creates a local [Media Stream] with [Track]s according to accepted
    /// [`Constraints`].
    ///
    /// [Media Stream]: https://tinyurl.com/2k2376z9
    /// [Track]: https://tinyurl.com/yc79x5s8
    /// [`Constraints`]: ffi::Constraints
    ///
    /// # Panics
    ///
    /// TODO: Don't panic
    pub fn get_users_media(
        self: &mut Webrtc,
        constraints: &api::MediaStreamConstraints,
    ) -> api::MediaStream {
        // TODO: dont hardcode id's
        let stream = {
            let stream =
                MediaStream::new(&self.0.peer_connection_factory).unwrap();

            self.0
                .local_media_streams
                .entry(stream.id)
                .or_insert(stream)
        };

        let mut result = api::MediaStream {
            stream_id: stream.id,
            video_tracks: Vec::new(),
            audio_tracks: Vec::new(),
        };

        {
            // TODO: if let Some(constraints) = constraints.video
            let source = {
                let source = Rc::new(
                    VideoSource::new(
                        &mut self.0.peer_connection_factory,
                        &constraints.video,
                    )
                    .unwrap(),
                );
                self.0.video_sources.insert(source.id, Rc::clone(&source));
                source
            };
            let track = {
                let track =
                    VideoTrack::new(&self.0.peer_connection_factory, source)
                        .unwrap();

                self.0.video_tracks.entry(track.id).or_insert(track)
            };
            stream.inner.add_video_track(&track.inner).unwrap();
            stream.video_tracks.push(track.id);

            result.video_tracks.push(api::MediaStreamTrack {
                id: track.id,
                label: track.id.to_string(), // TODO: source device label
                kind: track.kind,
                enabled: true,
            });
        }

        if constraints.audio {
            let source = {
                let source =
                    AudioSource::new(&self.0.peer_connection_factory).unwrap();

                self.0.audio_sources.entry(source.id).or_insert(source)
            };
            let track = {
                let track =
                    AudioTrack::new(&self.0.peer_connection_factory, source)
                        .unwrap();

                self.0.audio_tracks.entry(track.id).or_insert(track)
            };

            stream.inner.add_audio_track(&track.inner).unwrap();
            stream.audio_tracks.push(track.id);

            result.audio_tracks.push(api::MediaStreamTrack {
                id: track.id,
                label: track.id.to_string(), // TODO: source device label
                kind: track.kind,
                enabled: true,
            });
        };

        result
    }

    /// Disposes the [`MediaStreamNative`] and all involved
    /// [`AudioTrackNative`]s/[`VideoTrackNative`]s and
    /// [`AudioSource`]s/[`VideoSourceNative`]s.
    ///
    /// # Panics
    ///
    /// Panics if tracks from the provided stream are not found in the context.
    /// It is an invariant violation.
    pub fn dispose_stream(self: &mut Webrtc, id: MediaStreamId) {
        if let Some(stream) = self.0.local_media_streams.remove(&id) {
            let video_tracks = stream.video_tracks;
            let audio_tracks = stream.audio_tracks;

            for track in video_tracks {
                let src = self.0.video_tracks.remove(&track).unwrap().src;

                if Rc::strong_count(&src) == 2 {
                    self.0.video_sources.remove(&src.id);
                };
            }

            for track in audio_tracks {
                // TODO: are we sure that single audio source cannot source
                //       multiple audio tracks?
                let src = self.0.audio_tracks.remove(&track).unwrap().src;
                self.0.audio_sources.remove(&src);
            }
        }
    }
}
