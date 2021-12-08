use std::{collections::HashMap, rc::Rc};

use crate::*;
use cxx::UniquePtr;

pub type StreamId = String;
pub type VideoSouceId = String;
pub type VideoTrackId = String;
pub type AudioSourceId = String;
pub type AudioTrackId = String;

pub struct MediaStream {
    ptr: UniquePtr<webrtc::MediaStreamInterface>,
    video_tracks: Vec<VideoTrackId>,
    audio_tracks: Vec<AudioTrackId>,
}

pub struct VideoTrack {
    ptr: UniquePtr<webrtc::VideoTrackInterface>,
    source: Rc<VideoSource>,
}

pub struct VideoSource {
    ptr: UniquePtr<webrtc::VideoTrackSourceInterface>,
    id: VideoSouceId,
}

pub struct AudioTrack {
    ptr: UniquePtr<webrtc::AudioTrackInterface>,
    source: AudioTrackId,
}

fn create_local_stream(webrtc: &mut Box<Webrtc>, id: StreamId) {
    let this = webrtc.as_mut().0.as_mut();

    this.local_media_streams.insert(
        id,
        MediaStream {
            ptr: create_local_media_stream(&this.peer_connection_factory),
            video_tracks: vec![],
            audio_tracks: vec![],
        },
    );
}

fn create_local_video_source(
    webrtc: &mut Box<Webrtc>,
    id: VideoSouceId,
    width: String,
    height: String,
    fps: String,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.video_sources.insert(
        id.to_string(),
        Rc::new(VideoSource {
            ptr: create_video_source(
                &this.worker_thread,
                &this.signaling_thread,
                width.parse::<usize>().unwrap(),
                height.parse::<usize>().unwrap(),
                fps.parse::<usize>().unwrap(),
            ),
            id,
        }),
    );
}

fn create_local_video_track(
    webrtc: &mut Box<Webrtc>,
    id: VideoTrackId,
    source: VideoSouceId,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.video_tracks.insert(
        id,
        VideoTrack {
            ptr: create_video_track(
                &this.peer_connection_factory,
                &this.video_sources.get(&source).unwrap().ptr,
            ),
            source: Rc::clone(this.video_sources.get(&source).unwrap()),
        },
    );
}

fn create_local_audio_source(webrtc: &mut Box<Webrtc>, id: AudioSourceId) {
    let this = webrtc.as_mut().0.as_mut();

    this.audio_sources
        .insert(id, create_audio_source(&this.peer_connection_factory));
}

fn create_local_audio_track(
    webrtc: &mut Box<Webrtc>,
    id: AudioTrackId,
    source: AudioSourceId,
) {
    let this = webrtc.as_mut().0.as_mut();

    this.audio_tracks.insert(
        id,
        AudioTrack {
            ptr: create_audio_track(
                &this.peer_connection_factory,
                this.audio_sources.get(&source).unwrap(),
            ),
            source,
        },
    );
}

fn add_video_track_to_local(
    webrtc: &mut Box<Webrtc>,
    stream: StreamId,
    id: VideoTrackId,
) {
    let this = webrtc.as_mut().0.as_mut();

    let stream = this.local_media_streams.get_mut(&stream).unwrap();
    let track = this.video_tracks.get(&id).unwrap();

    add_video_track(&stream.ptr, &track.ptr);

    stream.video_tracks.push(id);
}

fn add_audio_track_to_local(
    webrtc: &mut Box<Webrtc>,
    stream: StreamId,
    id: AudioTrackId,
) {
    let this = webrtc.as_mut().0.as_mut();

    let stream = this.local_media_streams.get_mut(&stream).unwrap();
    let track = this.audio_tracks.get(&id).unwrap();

    add_audio_track(&stream.ptr, &track.ptr);

    stream.audio_tracks.push(id);
}

/// Creates an instanse of [Webrtc].
///
/// [Webrtc](Webrtc)
pub fn init() -> Box<Webrtc> {
    let worker_thread = create_thread();
    start_thread(&worker_thread);

    let signaling_thread = create_thread();
    start_thread(&signaling_thread);

    let peer_connection_factory =
        create_peer_connection_factory(&worker_thread, &signaling_thread);
    let task_queue_factory = create_default_task_queue_factory();

    Box::new(Webrtc(Box::new(Inner {
        task_queue_factory,
        worker_thread,
        signaling_thread,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: HashMap::new(),
        audio_sources: HashMap::new(),
        audio_tracks: HashMap::new(),
        local_media_streams: HashMap::new(),
    })))
}

/// Creates a local [Media Stream] with [Track]s according to accepted
/// [Constraints].
///
/// [Media Stream]: https://www.w3.org/TR/mediacapture-streams/#mediastream
/// [Track]: https://www.w3.org/TR/mediacapture-streams/#mediastreamtrack
/// [Constraints]: ffi::Constraints
pub fn get_user_media(
    webrtc: &mut Box<Webrtc>,
    constraints: ffi::Constraints,
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
        constraints.video.min_width,
        constraints.video.min_height,
        constraints.video.min_fps,
    );
    create_local_video_track(
        webrtc,
        video_track_id.to_string(),
        video_source_id.to_string(),
    );
    add_video_track_to_local(
        webrtc,
        stream_id.to_string(),
        video_track_id.to_string(),
    );

    if constraints.audio {
        create_local_audio_source(webrtc, audio_source_id.to_string());
        create_local_audio_track(
            webrtc,
            audio_track_id.to_string(),
            audio_source_id.to_string(),
        );
        add_audio_track_to_local(
            webrtc,
            stream_id.to_string(),
            audio_track_id.to_string(),
        );
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

/// Disposes the [Media Stream] and all involved [Track]s and Audio/Video
/// sources.
///
/// [Track]: https://www.w3.org/TR/mediacapture-streams/#mediastreamtrack
/// [Media Stream]: https://www.w3.org/TR/mediacapture-streams/#mediastream
pub fn dispose_stream(webrtc: &mut Box<Webrtc>, id: StreamId) {
    let this = webrtc.as_mut().0.as_mut();

    let local_stream = this.local_media_streams.remove(&id).unwrap();

    let video_tracks = local_stream.video_tracks;
    let audio_tracks = local_stream.audio_tracks;

    video_tracks.into_iter().for_each(|track| {
        let src = this.video_tracks.remove(&track).unwrap().source;

        if Rc::strong_count(&src) == 2 {
            this.video_sources.remove(&src.id);
        };
    });

    audio_tracks.into_iter().for_each(|track| {
        let src = this.audio_tracks.remove(&track).unwrap().source;
        this.audio_sources.remove(&src);
    });
}
