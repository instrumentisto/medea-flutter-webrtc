use std::rc::Rc;

use crate::{
    ffi, AudioTrack, LocalMediaStream, VideoSource, VideoTrack, Webrtc,
};

pub type StreamId = String;
pub type VideoSouceId = String;
pub type VideoTrackId = String;
pub type AudioSourceId = String;
pub type AudioTrackId = String;
pub type TextureId = i64;

pub struct MediaStreamNative {
    ptr: LocalMediaStream,
    pub video_tracks: Vec<VideoTrackId>,
    audio_tracks: Vec<AudioTrackId>,
}

pub struct VideoTrackNative {
    pub ptr: VideoTrack,
    source: Rc<VideoSourceNative>,
    pub renderers: Vec<Rc<TextureId>>,
}

pub struct VideoSourceNative {
    ptr: VideoSource,
    id: VideoSouceId,
}

pub struct AudioTrackNative {
    ptr: AudioTrack,
    source: AudioTrackId,
}

/// Creates a new Local Media Stream.
fn create_local_stream(webrtc: &mut Box<Webrtc>, id: StreamId) {
    let this = webrtc.as_mut().0.as_mut();

    this.local_media_streams.insert(
        id,
        MediaStreamNative {
            ptr: this
                .peer_connection_factory
                .create_local_media_stream()
                .unwrap(),
            video_tracks: vec![],
            audio_tracks: vec![],
        },
    );
}

/// Creates a new local Video Source.
fn create_local_video_source(
    webrtc: &mut Box<Webrtc>,
    id: VideoSouceId,
    width: &str,
    height: &str,
    fps: &str,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.video_sources.insert(
        id.to_string(),
        Rc::new(VideoSourceNative {
            ptr: this
                .peer_connection_factory
                .create_video_source(
                    width.parse::<usize>().unwrap(),
                    height.parse::<usize>().unwrap(),
                    fps.parse::<usize>().unwrap(),
                )
                .unwrap(),
            id,
        }),
    );
}

/// Creates a new local Video Track.
fn create_local_video_track(
    webrtc: &mut Box<Webrtc>,
    id: VideoTrackId,
    source: &str,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.video_tracks.insert(
        id,
        VideoTrackNative {
            ptr: this
                .peer_connection_factory
                .create_video_track(
                    &this.video_sources.get(&source.to_string()).unwrap().ptr,
                )
                .unwrap(),
            source: Rc::clone(
                this.video_sources.get(&source.to_string()).unwrap(),
            ),
            renderers: vec![],
        },
    );
}

/// Creates a new local Audio Source.
fn create_local_audio_source(webrtc: &mut Box<Webrtc>, id: AudioSourceId) {
    let this = webrtc.as_mut().0.as_mut();

    this.audio_sources.insert(
        id,
        this.peer_connection_factory.create_audio_source().unwrap(),
    );
}

/// Creates a new local Audio Track.
fn create_local_audio_track(
    webrtc: &mut Box<Webrtc>,
    id: AudioTrackId,
    source: AudioSourceId,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.audio_tracks.insert(
        id,
        AudioTrackNative {
            ptr: this
                .peer_connection_factory
                .create_audio_track(this.audio_sources.get(&source).unwrap())
                .unwrap(),
            source,
        },
    );
}

/// Adds the video track to the Local Media Stream.
fn add_video_track_to_local(
    webrtc: &mut Box<Webrtc>,
    stream: &str,
    id: VideoTrackId,
) {
    let this = webrtc.as_mut().0.as_mut();

    let stream = this
        .local_media_streams
        .get_mut(&stream.to_string())
        .unwrap();
    let track = this.video_tracks.get(&id).unwrap();

    stream.ptr.add_video_track(&track.ptr).unwrap();

    stream.video_tracks.push(id);
}

/// Adds the audio track to the Local Media Stream.
fn add_audio_track_to_local(
    webrtc: &mut Box<Webrtc>,
    stream: &str,
    id: AudioTrackId,
) {
    let this = webrtc.as_mut().0.as_mut();

    let stream = this
        .local_media_streams
        .get_mut(&stream.to_string())
        .unwrap();
    let track = this.audio_tracks.get(&id).unwrap();

    stream.ptr.add_audio_track(&track.ptr).unwrap();

    stream.audio_tracks.push(id);
}

/// Creates a local [Media Stream] with [Track]s according to accepted
/// [`Constraints`].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
/// [Track]: https://tinyurl.com/yc79x5s8
/// [`Constraints`]: ffi::Constraints
pub fn get_users_media(
    webrtc: &mut Box<Webrtc>,
    constraints: &ffi::Constraints,
) -> ffi::LocalStreamInfo {
    let stream_id = "test_stream_id";
    let video_source_id = "test_video_source_id";
    let video_track_id = "test_video_track_id";
    let audio_source_id = "test_audio_source_id";
    let audio_track_id = "test_audio_track_id";

    create_local_stream(webrtc, stream_id.to_string());

    create_local_video_source(
        webrtc,
        video_source_id.to_string(),
        constraints.video.min_width.as_str(),
        constraints.video.min_height.as_str(),
        constraints.video.min_fps.as_str(),
    );
    create_local_video_track(
        webrtc,
        video_track_id.to_string(),
        video_source_id,
    );
    add_video_track_to_local(webrtc, stream_id, video_track_id.to_string());

    if constraints.audio {
        create_local_audio_source(webrtc, audio_source_id.to_string());
        create_local_audio_track(
            webrtc,
            audio_track_id.to_string(),
            audio_source_id.to_string(),
        );
        add_audio_track_to_local(webrtc, stream_id, audio_track_id.to_string());
    };

    ffi::LocalStreamInfo {
        stream_id: stream_id.to_string(),
        video_tracks: vec![ffi::TrackInfo {
            id: video_track_id.to_string(),
            label: video_track_id.to_string(),
            kind: ffi::TrackKind::Video,
            enabled: true,
        }],
        audio_tracks: if constraints.audio {
            vec![ffi::TrackInfo {
                id: audio_track_id.to_string(),
                label: audio_track_id.to_string(),
                kind: ffi::TrackKind::Audio,
                enabled: true,
            }]
        } else {
            vec![]
        },
    }
}

/// Disposes the [`MediaStreamNative`] and all involved
/// [`AudioTrackNative`]s/[`VideoTrackNative`]s and
/// [`AudioSource`]s/[`VideoSourceNative`]s.
pub fn dispose_stream(webrtc: &mut Box<Webrtc>, id: &str) {
    let this = webrtc.as_mut().0.as_mut();

    let local_stream =
        this.local_media_streams.remove(&id.to_string()).unwrap();

    let video_tracks = local_stream.video_tracks;
    let audio_tracks = local_stream.audio_tracks;

    for track in video_tracks {
        let src = this.video_tracks.remove(&track).unwrap().source;

        if Rc::strong_count(&src) == 2 {
            this.video_sources.remove(&src.id);
        };
    }

    for track in audio_tracks {
        let src = this.audio_tracks.remove(&track).unwrap().source;
        this.audio_sources.remove(&src);
    }
}

pub fn get_display_media(webrtc: &mut Box<Webrtc>) -> ffi::LocalStreamInfo {
    let stream_id = "test_stream_id";
    let video_source_id = "test_video_source_id";
    let video_track_id = "test_video_track_id";
    let audio_source_id = "test_audio_source_id";
    let audio_track_id = "test_audio_track_id";

    create_local_stream(webrtc, stream_id.to_string());

    webrtc.0.video_sources.insert(
        video_source_id.to_string(),
        Rc::new(VideoSourceNative {
            ptr: webrtc
                .0
                .peer_connection_factory
                .create_screen_source(640, 480, 30)
                .unwrap(),
            id: video_source_id.to_string(),
        }),
    );
    create_local_video_track(
        webrtc,
        video_track_id.to_string(),
        video_source_id,
    );
    add_video_track_to_local(webrtc, stream_id, video_track_id.to_string());

    ffi::LocalStreamInfo {
        stream_id: stream_id.to_string(),
        video_tracks: vec![ffi::TrackInfo {
            id: video_track_id.to_string(),
            label: video_track_id.to_string(),
            kind: ffi::TrackKind::Video,
            enabled: true,
        }],
        audio_tracks: vec![],
    }
}
