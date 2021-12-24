use cxx::UniquePtr;
use std::{collections::HashMap, mem, rc::Rc};

use libwebrtc_sys::*;

mod user_media;
use user_media::*;

mod device_info;
use device_info::*;

mod frame;
use frame::*;

mod renderer;
use renderer::*;

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
        fn dispose_renderer(webrtc: &mut Box<Webrtc>, texture_id: i64);
    }
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
    renderers: HashMap<TextureId, Renderer>,
}

/// Wraps the [Inner] instanse.
/// This struct is intended to be extern and managed outside of the Rust app.
///
/// [Inner](Inner)
pub struct Webrtc(Box<Inner>);
