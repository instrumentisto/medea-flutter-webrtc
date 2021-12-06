use std::collections::HashMap;

use cxx::UniquePtr;
use libwebrtc_sys::*;

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    struct DeviceInfo {
        deviceId: String,
        kind: String,
        label: String,
    }

    extern "Rust" {
        type Webrtc;

        fn enumerate_devices() -> Vec<DeviceInfo>;
        fn init() -> Box<Webrtc>;
        fn create_local_stream(pcf: &mut Box<Webrtc>, id: String);
        fn create_local_video_source(
            pcf: &mut Box<Webrtc>,
            id: String,
            width: String,
            height: String,
            fps: String,
        );
        fn create_local_video_track(
            pcf: &mut Box<Webrtc>,
            id: String,
            source: String,
        );
        fn create_local_audio_source(pcf: &mut Box<Webrtc>, id: String);
        fn create_local_audio_track(
            pcf: &mut Box<Webrtc>,
            id: String,
            source: String,
        );
        fn add_video_track_to_local(
            pcf: &mut Box<Webrtc>,
            stream: String,
            id: String,
        );
        fn add_audio_track_to_local(
            pcf: &mut Box<Webrtc>,
            stream: String,
            id: String,
        );
        fn dispose_stream(pcf: &mut Box<Webrtc>, id: String);
    }
}

enum AudioKind {
    Playout,
    Recording,
}

pub struct WebrtcInner {
    task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
    worker_thread: UniquePtr<webrtc::Thread>,
    signaling_thread: UniquePtr<webrtc::Thread>,
    peer_connection_factory: UniquePtr<webrtc::PeerConnectionFactoryInterface>,
    video_sources: HashMap<String, VideoSource>,
    video_tracks: HashMap<String, VideoTrack>,
    audio_sources: HashMap<String, UniquePtr<webrtc::AudioSourceInterface>>,
    audio_tracks: HashMap<String, AudioTrack>,
    local_media_streams: HashMap<String, MediaStream>,
}

pub struct Webrtc(Box<WebrtcInner>);

struct MediaStream {
    ptr: UniquePtr<webrtc::MediaStreamInterface>,
    video_tracks: Vec<String>,
    audio_tracks: Vec<String>,
}

struct VideoTrack {
    ptr: UniquePtr<webrtc::VideoTrackInterface>,
    source: String,
}

struct VideoSource {
    ptr: UniquePtr<webrtc::VideoTrackSourceInterface>,
    tracks_on: u32,
}

impl VideoSource {
    fn increase(&mut self) {
        self.tracks_on += 1;
    }

    fn decrease(&mut self) -> bool {
        if self.tracks_on < 2 {
            false
        } else {
            self.tracks_on -= 1;
            true
        }
    }
}

struct AudioTrack {
    ptr: UniquePtr<webrtc::AudioTrackInterface>,
    source: String,
}

fn audio_devices_info(kind: AudioKind) -> Vec<ffi::DeviceInfo> {
    let task_queue = create_default_task_queue_factory();
    let audio_device_module = create_audio_device_module(task_queue);
    init_audio_device_module(&audio_device_module);
    let audio_device_count = if let AudioKind::Playout = kind {
        count_audio_playout_devices(&audio_device_module)
    } else {
        count_audio_recording_devices(&audio_device_module)
    };

    let mut list = vec![];

    for i in 0..audio_device_count {
        let audio_device_info = if let AudioKind::Playout = kind {
            get_audio_playout_device_info(&audio_device_module, i)
        } else {
            get_audio_recording_device_info(&audio_device_module, i)
        };

        let device_info = ffi::DeviceInfo {
            deviceId: audio_device_info.0,
            kind: if let AudioKind::Playout = kind {
                "audiooutput".to_string()
            } else {
                "audioinput".to_string()
            },
            label: audio_device_info.1,
        };

        list.push(device_info);
    }

    list
}

fn video_devices_info() -> Vec<ffi::DeviceInfo> {
    let video_device_module = create_video_device_module();
    let video_device_count = count_video_devices(&video_device_module);
    let mut list = vec![];

    for i in 0..video_device_count {
        let video_device_info = get_video_device_info(&video_device_module, i);

        let device_info = ffi::DeviceInfo {
            deviceId: video_device_info.0,
            kind: "videoinput".to_string(),
            label: video_device_info.1,
        };

        list.push(device_info);
    }

    list
}

/// Enumerates all the available media devices.
pub fn enumerate_devices() -> Vec<ffi::DeviceInfo> {
    let iters = audio_devices_info(AudioKind::Playout)
        .into_iter()
        .chain(audio_devices_info(AudioKind::Recording).into_iter())
        .chain(video_devices_info().into_iter());

    iters.collect()
}

pub fn init() -> Box<Webrtc> {
    let worker_thread = create_thread();
    start_thread(&worker_thread);

    let signaling_thread = create_thread();
    start_thread(&signaling_thread);

    let peer_connection_factory =
        create_peer_connection_factory(&worker_thread, &signaling_thread);
    let task_queue_factory = create_default_task_queue_factory();

    Box::new(Webrtc {
        0: Box::new(WebrtcInner {
            task_queue_factory,
            worker_thread,
            signaling_thread,
            peer_connection_factory,
            video_sources: HashMap::new(),
            video_tracks: HashMap::new(),
            audio_sources: HashMap::new(),
            audio_tracks: HashMap::new(),
            local_media_streams: HashMap::new(),
        }),
    })
}

pub fn create_local_stream(pcf: &mut Box<Webrtc>, id: String) {
    pcf.0.local_media_streams.insert(
        id,
        MediaStream {
            ptr: create_local_media_stream(&pcf.0.peer_connection_factory),
            video_tracks: vec![],
            audio_tracks: vec![],
        },
    );
}

pub fn create_local_video_source(
    pcf: &mut Box<Webrtc>,
    id: String,
    width: String,
    height: String,
    fps: String,
) {
    pcf.0.video_sources.insert(
        id,
        VideoSource {
            ptr: create_video_source(
                &pcf.0.worker_thread,
                &pcf.0.signaling_thread,
                width.parse::<usize>().unwrap(),
                height.parse::<usize>().unwrap(),
                fps.parse::<usize>().unwrap(),
            ),
            tracks_on: 0,
        },
    );
}

pub fn create_local_video_track(
    pcf: &mut Box<Webrtc>,
    id: String,
    source: String,
) {
    pcf.0.video_sources.get_mut(&source).unwrap().increase();

    pcf.0.video_tracks.insert(
        id,
        VideoTrack {
            ptr: create_video_track(
                &pcf.0.peer_connection_factory,
                &pcf.0.video_sources.get(&source).unwrap().ptr,
            ),
            source,
        },
    );
}

pub fn create_local_audio_source(pcf: &mut Box<Webrtc>, id: String) {
    pcf.0
        .audio_sources
        .insert(id, create_audio_source(&pcf.0.peer_connection_factory));
}

pub fn create_local_audio_track(
    pcf: &mut Box<Webrtc>,
    id: String,
    source: String,
) {
    pcf.0.audio_tracks.insert(
        id,
        AudioTrack {
            ptr: create_audio_track(
                &pcf.0.peer_connection_factory,
                &pcf.0.audio_sources.get(&source).unwrap(),
            ),
            source,
        },
    );
}

pub fn add_video_track_to_local(
    pcf: &mut Box<Webrtc>,
    stream: String,
    id: String,
) {
    let stream = pcf.0.local_media_streams.get_mut(&stream).unwrap();
    let track = pcf.0.video_tracks.get(&id).unwrap();

    add_video_track(&stream.ptr, &track.ptr);

    stream.video_tracks.push(id);
}

pub fn add_audio_track_to_local(
    pcf: &mut Box<Webrtc>,
    stream: String,
    id: String,
) {
    let stream = pcf.0.local_media_streams.get_mut(&stream).unwrap();
    let track = pcf.0.audio_tracks.get(&id).unwrap();

    add_audio_track(&stream.ptr, &track.ptr);

    stream.audio_tracks.push(id);
}

pub fn dispose_stream(pcf: &mut Box<Webrtc>, id: String) {
    let local_stream = pcf.0.local_media_streams.remove(&id).unwrap();

    let video_tracks = local_stream.video_tracks;
    let audio_tracks = local_stream.audio_tracks;

    video_tracks.into_iter().for_each(|track| {
        let src = pcf.0.video_tracks.remove(&track).unwrap().source;

        if !pcf.0.video_sources.get_mut(&src).unwrap().decrease() {
            pcf.0.video_sources.remove(&src);
        };
    });

    audio_tracks.into_iter().for_each(|track| {
        let src = pcf.0.audio_tracks.remove(&track).unwrap().source;
        pcf.0.audio_sources.remove(&src);
    });
}
