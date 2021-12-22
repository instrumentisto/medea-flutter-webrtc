use std::rc::Rc;

use libwebrtc_sys as sys;

use crate::{api, Webrtc};

// TODO: use new-types
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

pub struct VideoTrack {
    id: VideoTrackId,
    inner: sys::VideoTrack,
    source: Rc<VideoSource>,
    kind: api::TrackKind,
}

pub struct VideoSource {
    id: VideoSourceId,
    inner: sys::VideoSource,
}

pub struct AudioTrack {
    id: AudioTrackId,
    inner: sys::AudioTrack,
    source: AudioSourceId,
    kind: api::TrackKind,
}

pub struct AudioSource {
    id: AudioSourceId,
    inner: sys::AudioSource,
}

impl Webrtc {
    /// Creates a local [Media Stream] with [Track]s according to accepted
    /// [`Constraints`].
    ///
    /// [Media Stream]: https://tinyurl.com/2k2376z9
    /// [Track]: https://tinyurl.com/yc79x5s8
    /// [`Constraints`]: ffi::Constraints
    pub fn get_users_media(
        self: &mut Webrtc,
        constraints: &api::MediaStreamConstraints,
    ) -> api::MediaStream {
        // TODO: dont hardcode id's
        let mut stream = self.create_local_stream();
        let mut result = api::MediaStream {
            stream_id,
            video_tracks: vec![],
            audio_tracks: vec![],
        };

        {
            // TODO: if let Some(constraints) = constraints.video
            let video_source = self.create_video_source(&constraints.video);
            let video_track =
                self.create_local_video_track(Rc::clone(&video_source));
            self.add_video_track_to_stream(&mut stream, video_track);

            result.video_tracks.push(api::MediaStreamTrack {
                id: video_track.id,
                label: video_track.id.to_string(), // TODO: source device label
                kind: api::TrackKind::kVideo,
                enabled: true,
            });
        }

        if constraints.audio {
            let source = self.create_audio_source();
            let track = self.create_local_audio_track(source);
            self.add_audio_track_to_stream(&mut stream, track);
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
    pub fn dispose_stream(self: &mut Webrtc, id: MediaStreamId) {
        if let Some(stream) = self.0.local_media_streams.remove(&id) {
            let video_tracks = stream.video_tracks;
            let audio_tracks = stream.audio_tracks;

            for track in video_tracks {
                let src = self.0.video_tracks.remove(&track).unwrap().source;

                if Rc::strong_count(&src) == 2 {
                    self.0.video_sources.remove(&src.id);
                };
            }

            for track in audio_tracks {
                // TODO: are we sure that single audio source cannot source
                //       multiple audio tracks?
                let src = self.0.audio_tracks.remove(&track).unwrap().source;
                self.0.audio_sources.remove(&src);
            }
        }
    }

    /// Creates a new Local Media Stream.
    fn create_local_stream(&mut self) -> &mut MediaStream {
        let id = 0;
        let inner = self
            .0
            .peer_connection_factory
            .create_local_media_stream()
            .unwrap();
        let stream = MediaStream {
            id,
            inner,
            video_tracks: vec![],
            audio_tracks: vec![],
        };

        self.0.local_media_streams.entry(id).or_insert(stream)
    }

    /// Creates a new local Video Source.
    fn create_video_source(
        &mut self,
        constraints: &api::VideoConstraints,
    ) -> &Rc<VideoSource> {
        let id = 0;
        let inner = self
            .0
            .peer_connection_factory
            .create_video_source(
                constraints.min_width,
                constraints.min_height,
                constraints.min_width,
            )
            .unwrap();
        let source = VideoSource { id, inner };

        self.0.video_sources.entry(id).or_insert(Rc::new(source))
    }

    fn create_audio_source(&mut self) -> &AudioSource {
        let id = 0;
        let inner = self
            .0
            .peer_connection_factory
            .create_audio_source()
            .unwrap();

        let source = AudioSource { id, inner };

        self.0.audio_sources.entry(id).or_insert(source)
    }

    /// Creates a new local Video Track.
    fn create_local_video_track(
        &mut self,
        source: Rc<VideoSource>,
    ) -> &VideoTrack {
        let id = 0;
        let inner = self
            .0
            .peer_connection_factory
            .create_video_track(&source.inner)
            .unwrap();
        let track = VideoTrack {
            id,
            inner,
            source,
            kind: api::TrackKind::kVideo,
        };

        self.0.video_tracks.entry(id).or_insert(track)
    }

    /// Creates a new local Audio Track.
    fn create_local_audio_track(
        &mut self,
        source: &AudioSource,
    ) -> &AudioTrack {
        let id = 0;
        let track = AudioTrack {
            id,
            inner: self
                .0
                .peer_connection_factory
                .create_audio_track(&source.inner)
                .unwrap(),
            source: source.id,
            kind: api::TrackKind::kAudio,
        };

        self.0.audio_tracks.entry(id).or_insert(track)
    }

    /// Adds the video track to the Local Media Stream.
    fn add_video_track_to_stream(
        &mut self,
        stream: &mut MediaStream,
        track: &VideoTrack,
    ) {
        stream.inner.add_video_track(&track.inner).unwrap();
        stream.video_tracks.push(track.id);
    }

    /// Adds the audio track to the Local Media Stream.
    fn add_audio_track_to_stream(
        &mut self,
        stream: &mut MediaStream,
        track: &AudioTrack,
    ) {
        stream.inner.add_audio_track(&track.inner).unwrap();
        stream.audio_tracks.push(track.id);
    }
}
