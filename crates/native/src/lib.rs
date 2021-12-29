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

    /// The [MediaStreamConstraints] is used to instruct what sort of
    /// [MediaStreamTracks] to include in the [MediaStream] returned by
    /// [get_users_media()].
    pub struct MediaStreamConstraints {
        pub audio: bool,
        pub video: VideoConstraints,
    }

    /// Constraints for video capturer.
    pub struct VideoConstraints {
        pub min_width: String,
        pub min_height: String,
        pub min_fps: String,
    }

    /// The [MediaStream] represents a stream of media content. A stream
    /// consists of several tracks, such as video or audio tracks. Each track
    /// is specified as an instance of [MediaStreamTrack].
    pub struct MediaStream {
        pub stream_id: String,
        pub video_tracks: Vec<MediaStreamTrack>,
        pub audio_tracks: Vec<MediaStreamTrack>,
    }

    /// The [MediaStreamTrack] interface represents a single media track within
    /// a stream; typically, these are audio or video tracks, but other track
    /// types may exist as well.
    pub struct MediaStreamTrack {
        /// Unique identifier (GUID) for the track
        pub id: String,

        /// Label that identifies the track source, as in "internal microphone".
        pub label: String,

        /// The MediaStreamTrack.kind read-only property returns a DOMString
        /// set to "audio" if the track is an audio track and to "video",
        /// if it is a video track. It doesn't change if the track is
        /// deassociated from its source.
        pub kind: TrackKind,

        /// The enabled property on the MediaStreamTrack interface is a Boolean
        /// value which is true if the track is allowed to render the source
        /// stream or false if it is not. This can be used to intentionally
        /// mute a track.
        pub enabled: bool,
    }

    /// Representation of a [`MediaStreamTrack.kind`][1].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack-kind
    pub enum TrackKind {
        Audio,
        Video,
    }

    extern "Rust" {
        type Webrtc;

        /// Creates an instance of [Webrtc].
        #[cxx_name = "Init"]
        fn init() -> Box<Webrtc>;

        /// Returns a list of all available media input and output devices, such
        /// as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        fn enumerate_devices(webrtc: &mut Box<Webrtc>) -> Vec<MediaDeviceInfo>;

        /// Creates a local Media Stream with Tracks according to
        /// accepted Constraints.
        #[cxx_name = "GetUserMedia"]
        fn get_users_media(
            webrtc: &mut Box<Webrtc>,
            constraints: &MediaStreamConstraints,
        ) -> MediaStream;

        /// Disposes the MediaStreamNative and all involved
        /// AudioTrackNatives/VideoTrackNatives and
        /// AudioSources/VideoSourceNatives.
        #[cxx_name = "DisposeStream"]
        fn dispose_stream(webrtc: &mut Box<Webrtc>, id: &str);
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
