#![warn(clippy::pedantic)]
use std::{collections::HashMap, rc::Rc};

use libwebrtc_sys::{
    AudioDeviceModule, AudioLayer, AudioSource, AudioTrack, LocalMediaStream,
    PeerConnectionFactory, TaskQueueFactory, VideoDeviceInfo, VideoSource,
    VideoTrack,
};

mod user_media;
use user_media::{
    dispose_stream, get_users_media, AudioSourceId, AudioTrackId,
    AudioTrackNative, MediaStreamNative, StreamId, VideoSouceId,
    VideoSourceNative, VideoTrackId, VideoTrackNative,
};

mod device_info;
use device_info::enumerate_devices;

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

    extern "Rust" {
        type Webrtc;

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

        fn testfl();
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
    })))
}

pub fn testfl() {
    libwebrtc_sys::testasd();
}
