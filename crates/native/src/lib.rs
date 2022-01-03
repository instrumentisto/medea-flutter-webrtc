#![warn(clippy::pedantic)]

mod device_info;
mod user_media;

use std::{collections::HashMap, rc::Rc};

use libwebrtc_sys::{
    AudioDeviceModule, AudioLayer, PeerConnectionFactory, TaskQueueFactory,
    VideoDeviceInfo,
};

use crate::user_media::{
    AudioSource, AudioSourceId, AudioTrack, AudioTrackId, MediaStream,
    MediaStreamId, VideoSource, VideoSourceId, VideoTrack, VideoTrackId,
};

/// The module which describes the bridge to call Rust from C++.
#[allow(clippy::items_after_statements, clippy::expl_impl_clone_on_copy)]
#[cxx::bridge]
pub mod api {
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
        pub audio: bool,             // TODO: device_id?
        pub video: VideoConstraints, // TODO: supposed to be optional
    }

    /// Constraints for video capturer.
    pub struct VideoConstraints {
        // TODO: device_id?
        pub min_width: usize,
        pub min_height: usize,
        pub min_fps: usize,
        pub device_id: String,
        pub video_required: bool,
    }

    /// The [MediaStream] represents a stream of media content. A stream
    /// consists of several tracks, such as video or audio tracks. Each track
    /// is specified as an instance of [MediaStreamTrack].
    pub struct MediaStream {
        pub stream_id: u64,
        pub video_tracks: Vec<MediaStreamTrack>,
        pub audio_tracks: Vec<MediaStreamTrack>,
    }

    /// The [MediaStreamTrack] interface represents a single media track within
    /// a stream; typically, these are audio or video tracks, but other track
    /// types may exist as well.
    pub struct MediaStreamTrack {
        /// Unique identifier (GUID) for the track
        pub id: u64,

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

    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    pub enum TrackKind {
        kAudio,
        kVideo,
    }

    extern "Rust" {
        type Webrtc;

        /// Creates an instance of [Webrtc].
        #[cxx_name = "Init"]
        fn init() -> Box<Webrtc>;

        /// Returns a list of all available media input and output devices, such
        /// as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        pub fn enumerate_devices(self: &mut Webrtc) -> Vec<MediaDeviceInfo>;

        /// Creates a local Media Stream with Tracks according to
        /// accepted Constraints.
        #[cxx_name = "GetUserMedia"]
        pub fn get_users_media(
            self: &mut Webrtc,
            constraints: &MediaStreamConstraints,
        ) -> MediaStream;

        /// Disposes the MediaStreamNative and all involved
        /// AudioTrackNatives/VideoTrackNatives and
        /// AudioSources/VideoSourceNatives.
        #[cxx_name = "DisposeStream"]
        pub fn dispose_stream(self: &mut Webrtc, id: u64);
    }
}

/// Contains all necessary tools for interoperate with [`libWebRTC`].
///
/// [`libWebrtc`]: https://tinyurl.com/54y935zz
pub struct Inner {
    task_queue_factory: TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    video_device_info: VideoDeviceInfo,
    peer_connection_factory: PeerConnectionFactory,
    video_sources: HashMap<VideoSourceId, Rc<VideoSource>>,
    video_tracks: HashMap<VideoTrackId, VideoTrack>,
    audio_sources: HashMap<AudioSourceId, AudioSource>,
    audio_tracks: HashMap<AudioTrackId, AudioTrack>,
    local_media_streams: HashMap<MediaStreamId, MediaStream>,
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
    let mut task_queue_factory = TaskQueueFactory::create();
    let peer_connection_factory = PeerConnectionFactory::create().unwrap();
    let audio_device_module = AudioDeviceModule::create(
        AudioLayer::kPlatformDefaultAudio,
        &mut task_queue_factory,
    )
    .unwrap();
    audio_device_module.init().unwrap();

    let video_device_info = VideoDeviceInfo::create().unwrap();

    Box::new(Webrtc(Box::new(Inner {
        task_queue_factory,
        audio_device_module,
        video_device_info,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: HashMap::new(),
        audio_sources: HashMap::new(),
        audio_tracks: HashMap::new(),
        local_media_streams: HashMap::new(),
    })))
}
