#![warn(clippy::pedantic)]
use std::{collections::HashMap, rc::Rc};

use cxx::UniquePtr;
use libwebrtc_sys::{
    webrtc::VideoFrame, AudioDeviceModule, AudioLayer, AudioSource, AudioTrack,
    LocalMediaStream, PeerConnectionFactory, TaskQueueFactory, VideoDeviceInfo,
    VideoSource, VideoTrack, *,
};

mod user_media;
use user_media::{
    dispose_stream, get_display_media, get_users_media, AudioSourceId,
    AudioTrackId, AudioTrackNative, MediaStreamNative, StreamId, TextureId,
    VideoSouceId, VideoSourceNative, VideoTrackId, VideoTrackNative,
};

mod device_info;
use device_info::enumerate_devices;

mod frame;
use frame::*;

mod renderer;
use renderer::*;

/// The module which describes the bridge to call Rust from C++.
#[allow(clippy::items_after_statements, clippy::expl_impl_clone_on_copy)]
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

    /// Information about `Local Media Stream`.
    struct LocalStreamInfo {
        stream_id: String,
        video_tracks: Vec<TrackInfo>,
        audio_tracks: Vec<TrackInfo>,
    }

    /// Information about Track.
    struct TrackInfo {
        id: String,
        label: String,
        kind: TrackKind,
        enabled: bool,
    }

    /// Kind of Track.
    enum TrackKind {
        Audio,
        Video,
    }

    /// Possible kinds of media devices.
    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    pub enum MediaDeviceKind {
        kAudioInput,
        kAudioOutput,
        kVideoInput,
    }

    /// Information describing a single media input or output device.
    #[derive(Debug)]
    pub struct MediaDeviceInfo {
        /// Unique identifier for the represented device.
        pub device_id: String,

        /// Kind of the represented device.
        pub kind: MediaDeviceKind,

        /// Label describing the represented device.
        pub label: String,
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

        /// Returns a list of all available media input and output devices, such
        /// as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        fn enumerate_devices(webrtc: &mut Box<Webrtc>) -> Vec<MediaDeviceInfo>;

        /// Creates an instanse of Webrtc.
        #[cxx_name = "Init"]
        fn init() -> Box<Webrtc>;

        /// Creates a local Media Stream with Tracks according to
        /// accepted Constraints.
        #[cxx_name = "GetUserMedia"]
        fn get_users_media(
            webrtc: &mut Box<Webrtc>,
            constraints: &Constraints,
        ) -> LocalStreamInfo;

        /// Disposes the MediaStreamNative and all involved
        /// AudioTrackNatives/VideoTrackNatives and
        /// AudioSources/VideoSourceNatives.
        #[cxx_name = "DisposeStream"]
        fn dispose_stream(webrtc: &mut Box<Webrtc>, id: &str);

        #[cxx_name = "GetDisplayMedia"]
        fn get_display_media(webrtc: &mut Box<Webrtc>) -> LocalStreamInfo;

        fn width(self: &Frame) -> i32;
        fn height(self: &Frame) -> i32;
        fn rotation(self: &Frame) -> VideoRotation;
        fn buffer_size(self: &Frame) -> i32;
        unsafe fn buffer(self: &Frame) -> Vec<u8>;
        unsafe fn delete_frame(frame_ptr: *mut Frame);
        fn dispose_renderer(webrtc: &mut Box<Webrtc>, texture_id: i64);

        // fn testfl();
    }
}

/// Contains all necessary tools for interoperate with [`libWebRTC`].
///
/// [`libWebrtc`]: https://tinyurl.com/54y935zz
pub struct Inner {
    task_queue_factory: TaskQueueFactory,
    peer_connection_factory: PeerConnectionFactory,
    video_sources: HashMap<VideoSouceId, Rc<VideoSourceNative>>,
    video_tracks: HashMap<VideoTrackId, VideoTrackNative>,
    audio_sources: HashMap<AudioSourceId, AudioSource>,
    audio_tracks: HashMap<AudioTrackId, AudioTrackNative>,
    local_media_streams: HashMap<StreamId, MediaStreamNative>,
    renderers: HashMap<TextureId, Renderer>,
}

/// Wraps the [`Inner`] instanse.
/// This struct is intended to be extern and managed outside of the Rust app.
pub struct Webrtc(Box<Inner>);

/// Creates an instanse of [`Webrtc`].
///
/// # Panics
///
/// May panic if `PeerconnectionFactory` is not valiable to be created.
#[must_use]
pub fn init() -> Box<Webrtc> {
    let task_queue_factory =
        TaskQueueFactory::create_default_task_queue_factory();
    let peer_connection_factory = PeerConnectionFactory::create().unwrap();

    Box::new(Webrtc(Box::new(Inner {
        task_queue_factory,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: HashMap::new(),
        audio_sources: HashMap::new(),
        audio_tracks: HashMap::new(),
        local_media_streams: HashMap::new(),
        renderers: HashMap::new(),
    })))
}

// pub fn testfl() {
//     // libwebrtc_sys::testasd();
// }

// fn cb(frame: UniquePtr<VideoFrame>, cbf: usize) {
//     0;
// }

// #[cfg(test)]
// mod test {

//     use libwebrtc_sys::webrtc;

//     use crate::{cb, init};

//     #[test]
//     fn testik() {
//         let mut webrtc = init();
//         let ptr = webrtc
//             .0
//             .peer_connection_factory
//             .create_screen_source(640, 480, 30)
//             .unwrap();

//         let track_ptr = webrtc
//             .0
//             .peer_connection_factory
//             .create_video_track(&ptr)
//             .unwrap();
//         let a = unsafe { webrtc::get_video_renderer(cb, 0, &track_ptr.0) };
//         loop {}
//         assert!(true);
//     }
// }
