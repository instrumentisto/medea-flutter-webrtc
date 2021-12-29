use std::rc::Rc;

use crate::{
    ffi, ffi::VideoConstraints, AudioTrack, LocalMediaStream, VideoSource,
    VideoTrack, Webrtc,
};

// TODO: use new-types
pub type StreamId = u64;
pub type VideoSourceId = u64;
pub type TrackId = u64;
pub type VideoTrackId = u64;
pub type AudioSourceId = u64;
pub type AudioTrackId = u64;

pub struct MediaStreamNative {
    inner: LocalMediaStream,
    video_tracks: Vec<VideoTrackId>,
    audio_tracks: Vec<AudioTrackId>,
}

pub struct VideoTrackNative {
    inner: VideoTrack,
    source: Rc<VideoSourceNative>,
}

pub struct VideoSourceNative {
    id: VideoSourceId,
    inner: VideoSource,
}

pub struct AudioTrackNative {
    inner: AudioTrack,
    source: AudioTrackId,
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
        constraints: &ffi::MediaStreamConstraints,
    ) -> ffi::MediaStream {
        // TODO: dont hardcode id's
        let stream_id = self.create_local_stream();
        let mut stream = ffi::MediaStream {
            stream_id,
            video_tracks: vec![],
            audio_tracks: vec![],
        };

        let video_source_id =
            self.create_local_video_source(&constraints.video);
        let video_track_id = self.create_local_video_track(video_source_id);
        self.add_video_track_to_local(stream_id, video_track_id);

        stream.video_tracks.push(ffi::MediaStreamTrack {
            id: video_track_id,
            label: video_track_id.to_string(),
            kind: ffi::TrackKind::Video,
            enabled: true,
        });

        if constraints.audio {
            let audio_source_id = self.create_audio_source();
            let audio_track_id =
                self.create_local_audio_track(audio_source_id);
            stream.audio_tracks.push(ffi::MediaStreamTrack {
                id: audio_track_id,
                label: audio_track_id.to_string(),
                kind: ffi::TrackKind::Audio,
                enabled: true,
            });
        };

        stream
    }

    /// Disposes the [`MediaStreamNative`] and all involved
    /// [`AudioTrackNative`]s/[`VideoTrackNative`]s and
    /// [`AudioSource`]s/[`VideoSourceNative`]s.
    pub fn dispose_stream(self: &mut Webrtc, id: StreamId) {
        let local_stream =
            self.0.local_media_streams.remove(&id).unwrap();

        let video_tracks = local_stream.0.video_tracks;
        let audio_tracks = local_stream.0.audio_tracks;

        for track in video_tracks {
            let src = self.0.video_tracks.remove(&track).unwrap().source;

            if Rc::strong_count(&src) == 2 {
                self.0.video_sources.remove(&src.id);
            };
        }

        for track in audio_tracks {
            let src = self.0.audio_tracks.remove(&track).unwrap().source;
            self.0.audio_sources.remove(&src);
        }
    }

    /// Creates a new Local Media Stream.
    fn create_local_stream(&mut self) -> StreamId {
        let id = 0;
        let inner = self
            .0
            .peer_connection_factory
            .create_local_media_stream()
            .unwrap();
        self.0.local_media_streams.insert(
            id,
            MediaStreamNative {
                inner,
                video_tracks: vec![],
                audio_tracks: vec![],
            },
        );

        id
    }

    /// Creates a new local Video Source.
    fn create_local_video_source(
        &mut self,
        constraints: &VideoConstraints,
    ) -> VideoSourceId {
        let obj = self
            .0
            .peer_connection_factory
            .create_video_source(
                constraints.min_width,
                constraints.min_height,
                constraints.min_width,
            )
            .unwrap();
        let id = 0;
        self.0.video_sources.insert(
            id,
            Rc::new(VideoSourceNative {
                id,
                inner: obj,
            }),
        );

        id
    }

    /// Creates a new local Video Track.
    fn create_local_video_track(&mut self, source: VideoSourceId) -> VideoTrackId {
        let id = 0;
        self.0.video_tracks.insert(
            id,
            VideoTrackNative {
                inner: self
                    .0
                    .peer_connection_factory
                    .create_video_track(
                        &self
                            .0
                            .video_sources
                            .get(&source)
                            .unwrap()
                            .inner,
                    )
                    .unwrap(),
                source: Rc::clone(
                    self.0.video_sources.get(&source).unwrap(),
                ),
            },
        );

        id
    }

    /// Creates a new local Audio Track.
    fn create_local_audio_track(
        &mut self,
        source: AudioSourceId,
    ) -> AudioTrackId {
        let id = 0;
        self.0.audio_tracks.insert(
            id,
            AudioTrackNative {
                inner: self
                    .0
                    .peer_connection_factory
                    .create_audio_track(
                        self.0.audio_sources.get(&source).unwrap(),
                    )
                    .unwrap(),
                source,
            },
        );
        self.add_audio_track_to_local(stream_id, audio_track_id.to_string());

        id
    }

    /// Adds the video track to the Local Media Stream.
    fn add_video_track_to_local(&mut self, stream: StreamId, id: VideoTrackId) {
        let stream = self
            .0
            .local_media_streams
            .get_mut(&stream)
            .unwrap();
        let track = self.0.video_tracks.get(&id).unwrap();

        stream.inner.add_video_track(&track.inner).unwrap();

        stream.0.video_tracks.push(id);
    }

    /// Adds the audio track to the Local Media Stream.
    fn add_audio_track_to_local(&mut self, stream: StreamId, id: AudioTrackId) {
        let stream = self
            .0
            .local_media_streams
            .get_mut(&stream)
            .unwrap();
        let track = self.0.audio_tracks.get(&id).unwrap();

        stream.inner.add_audio_track(&track.inner).unwrap();

        stream.0.audio_tracks.push(id);
    }

    fn create_audio_source(&mut self) -> AudioSourceId {
        let id = 0;
        let audio_source = self
            .0
            .peer_connection_factory
            .create_audio_source()
            .unwrap();
        self.0
            .audio_sources
            .insert(id, audio_source);

        id
    }
}
