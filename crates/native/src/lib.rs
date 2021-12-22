use std::{collections::HashMap, rc::Rc};

use cxx::{CxxVector, UniquePtr};
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

    enum VideoRotation {
        kVideoRotation_0 = 0,
        kVideoRotation_90 = 90,
        kVideoRotation_180 = 180,
        kVideoRotation_270 = 270,
    }

    extern "Rust" {
        type Webrtc;
        type Frame;

        fn enumerate_devices() -> Vec<DeviceInfo>;
        fn init() -> Box<Webrtc>;
        fn get_user_media(
            webrtc: &mut Box<Webrtc>,
            constraints: Constraints,
        ) -> LocalStreamInfo;
        fn dispose_stream(webrtc: &mut Box<Webrtc>, id: String);
        fn width(self: &Frame) -> i32;
        fn height(self: &Frame) -> i32;
        fn rotation(self: &Frame) -> VideoRotation;
        fn buffer_size(self: &Frame) -> i32;
        unsafe fn buffer(self: &Frame) -> Vec<u8>;
        unsafe fn delete_frame(frame_ptr: *mut Frame);
    }
}

struct FrameInner(UniquePtr<webrtc::VideoFrame>);

pub struct Frame(Box<FrameInner>);

impl Frame {
    fn width(self: &Frame) -> i32 {
        webrtc::frame_width(&self.0 .0)
    }

    fn height(self: &Frame) -> i32 {
        webrtc::frame_height(&self.0 .0)
    }

    fn rotation(self: &Frame) -> ffi::VideoRotation {
        match webrtc::frame_rotation(&self.0 .0) {
            0 => ffi::VideoRotation::kVideoRotation_0,
            90 => ffi::VideoRotation::kVideoRotation_90,
            180 => ffi::VideoRotation::kVideoRotation_180,
            270 => ffi::VideoRotation::kVideoRotation_270,
            _ => Result::Err("Invalid value.").unwrap(),
        }
    }

    fn buffer_size(self: &Frame) -> i32 {
        self.width() * self.height() * (32 >> 3)
    }

    unsafe fn buffer(self: &Frame) -> Vec<u8> {
        webrtc::convert_to_argb(&self.0 .0, self.buffer_size())
    }
}

static mut FN: extern "C" fn(*mut Frame) = {
    extern "C" fn __(_: *mut Frame) {
        0;
    }
    __
};

pub fn cb(frame: UniquePtr<webrtc::VideoFrame>) {
    let a = Frame(Box::new(FrameInner(frame)));

    unsafe {
        FN(Box::into_raw(Box::new(a)));
    }
}

#[no_mangle]
unsafe extern "C" fn foo(fp: extern "C" fn(*mut Frame)) {
    FN = fp;

    stream_test(cb);
}

unsafe fn delete_frame(frame_ptr: *mut Frame) {
    Box::from_raw(frame_ptr);
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
