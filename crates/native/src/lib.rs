use std::{collections::HashMap, rc::Rc};

use cxx::UniquePtr;
use libwebrtc_sys::*;

mod user_media;
use user_media::*;

mod device_info;
use device_info::*;

/// The module which describes the bridge to call Rust from C++.
#[cxx::bridge]
pub mod ffi {
    /// Information about a physical device instance.
    struct DeviceInfo {
        deviceId: String,
        kind: String,
        label: String,
    }

    /// Media Stream constrants.
    struct Constraints {
        audio: bool,
        video: VideoConstraints,
    }

    /// Constraints for video capturer.
    struct VideoConstraints {
        min_width: String,
        min_height: String,
        min_fps: String,
    }

    /// Information about local [Media Stream].
    ///
    /// [Media Stream]: https://www.w3.org/TR/mediacapture-streams/#mediastream
    struct LocalStreamInfo {
        stream_id: String,
        video_tracks: Vec<TrackInfo>,
        audio_tracks: Vec<TrackInfo>,
    }

    /// Information about [Track].
    ///
    /// [Track]: https://www.w3.org/TR/mediacapture-streams/#mediastreamtrack
    struct TrackInfo {
        id: String,
        label: String,
        kind: TrackKind,
        enabled: bool,
    }

    /// Kind of [Track].
    ///
    /// [Track]: https://www.w3.org/TR/mediacapture-streams/#mediastreamtrack
    enum TrackKind {
        Audio,
        Video,
    }

    struct Keklol {
        id: i32,
    }

    struct FrameInfo {
        width: i32,
        height: i32,
        rotation: i32,
        buffer: Vec<u8>,
    }

    extern "Rust" {
        type Webrtc;

        fn enumerate_devices() -> Vec<DeviceInfo>;
        fn init() -> Box<Webrtc>;
        fn get_user_media(
            webrtc: &mut Box<Webrtc>,
            constraints: Constraints,
        ) -> LocalStreamInfo;
        fn dispose_stream(webrtc: &mut Box<Webrtc>, id: String);
    }
}

// pub struct Keklol {
//     id: i32,
// }

impl ffi::Keklol {
    pub fn rise(&mut self) {
        self.id += 1;
    }

    pub fn get(&self) -> i32 {
        self.id
    }
}

static mut FN: extern "C" fn(*const ffi::FrameInfo) = {
    extern "C" fn __(_: *const ffi::FrameInfo) {
        0;
    }
    __
};

pub fn cb(frame: UniquePtr<webrtc::VideoFrame>) {
    let a = ffi::FrameInfo {
        width: webrtc::frame_width(&frame),
        height: webrtc::frame_height(&frame),
        rotation: webrtc::frame_rotation(&frame),
        buffer: webrtc::convert_to_argb(&frame),
    };
    unsafe {
        FN(Box::into_raw(Box::new(a)));
    }
}

#[no_mangle]
unsafe extern "C" fn foo(fp: extern "C" fn(*const ffi::FrameInfo)) {
    FN = fp;

    stream_test(cb);
}

/// Contains all necessary tools for interoperate with [libWebRTC].
///
/// [libWebrtc]: https://webrtc.googlesource.com/src/
pub struct Inner {
    task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
    worker_thread: UniquePtr<webrtc::Thread>,
    signaling_thread: UniquePtr<webrtc::Thread>,
    peer_connection_factory: UniquePtr<webrtc::PeerConnectionFactoryInterface>,
    video_sources: HashMap<VideoSouceId, Rc<VideoSource>>,
    video_tracks: HashMap<VideoTrackId, VideoTrack>,
    audio_sources:
        HashMap<AudioSourceId, UniquePtr<webrtc::AudioSourceInterface>>,
    audio_tracks: HashMap<AudioTrackId, AudioTrack>,
    local_media_streams: HashMap<StreamId, MediaStream>,
    renderers: HashMap<String, Renderer>,
}

struct Renderer {
    texture: String,
    stream: MediaStream,
    frames: HashMap<String, UniquePtr<webrtc::VideoFrame>>,
    callback: extern "C" fn(),
}

/// Wraps the [Inner] instanse.
/// This struct is intended to be extern and managed outside of the Rust app.
///
/// [Inner](Inner)
pub struct Webrtc(Box<Inner>);
