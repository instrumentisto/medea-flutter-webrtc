#![warn(clippy::pedantic)]

mod device_info;
mod user_media;

use std::{collections::HashMap, rc::Rc};

use libwebrtc_sys::{
    AudioDeviceModule as SysAudioDeviceModule, AudioLayer,
    PeerConnectionFactory, TaskQueueFactory, VideoDeviceInfo,
};

use crate::user_media::{
    AudioDeviceId, AudioSource, AudioTrack, AudioTrackId, MediaStream,
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
    /// [`MediaStreamTrack`]s to include in the [`MediaStream`] returned by
    /// [`Webrtc::get_users_media()`].
    pub struct MediaStreamConstraints {
        /// Specifies the nature and settings of the video [`MediaStreamTrack`].
        pub audio: AudioConstraints,
        /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
        pub video: VideoConstraints,
    }

    /// Specifies the nature and settings of the video [`MediaStreamTrack`]
    /// returned by [`Webrtc::get_users_media()`].
    pub struct VideoConstraints {
        /// Indicates whether [`Webrtc::get_users_media()`] should obtain video
        /// track. All other args will be ignored if `required` is set to
        /// `false`.
        pub required: bool,

        /// The identifier of the device generating the content of the
        /// [`MediaStreamTrack`]. First device will be chosen if empty
        /// [`String`] is provided.
        pub device_id: String,

        /// The width, in pixels.
        pub width: usize,

        /// The height, in pixels.
        pub height: usize,

        /// The exact frame rate (frames per second).
        pub frame_rate: usize,
    }

    /// Specifies the nature and settings of the audio [`MediaStreamTrack`]
    /// returned by [`Webrtc::get_users_media()`].
    pub struct AudioConstraints {
        /// Indicates whether [`Webrtc::get_users_media()`] should obtain video
        /// track. All other args will be ignored if `required` is set to
        /// `false`.
        pub required: bool,

        /// The identifier of the device generating the content of the
        /// [`MediaStreamTrack`]. First device will be chosen if empty
        /// [`String`] is provided.
        ///
        /// __NOTE__: There can be only one active recording device at a time,
        /// so changing device will affect all previously obtained audio tracks.
        pub device_id: String,
    }

    /// The [`MediaStream`] represents a stream of media content. A stream
    /// consists of several [`MediaStreamTrack`], such as video or audio tracks.
    pub struct MediaStream {
        /// Unique ID of this [`MediaStream`];
        pub stream_id: u64,

        /// [`MediaStreamTrack`]s with [`TrackKind::kVideo`].
        pub video_tracks: Vec<MediaStreamTrack>,

        /// [`MediaStreamTrack`]s with [`TrackKind::kAudio`].
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

        /// [`TrackKind`] of the current [`MediaStreamTrack`].
        pub kind: TrackKind,

        /// The `enabled` property on the [`MediaStreamTrack`] interface is a
        /// `enabled` value which is `true` if the track is allowed to render
        /// the source stream or `false` if it is not. This can be used to
        /// intentionally mute a track.
        pub enabled: bool,
    }

    /// Nature of the [`MediaStreamTrack`].
    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    pub enum TrackKind {
        /// Audio media track.
        kAudio,

        /// Video media track.
        kVideo,
    }

    extern "Rust" {
        type Webrtc;

        /// Creates an instance of [`Webrtc`].
        #[cxx_name = "Init"]
        pub fn init() -> Box<Webrtc>;

        /// Returns a list of all available media input and output devices, such
        /// as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        pub fn enumerate_devices(self: &mut Webrtc) -> Vec<MediaDeviceInfo>;

        /// Creates a [`LocalMediaStream`] with Tracks according to
        /// accepted Constraints.
        ///
        /// [`LocalMediaStream`]:LocalMediaStream
        #[cxx_name = "GetUserMedia"]
        pub fn get_users_media(
            self: &mut Webrtc,
            constraints: &MediaStreamConstraints,
        ) -> MediaStream;

        /// Disposes the [`MediaStream`] and all involved
        /// [`AudioTrack`]s/[`VideoTrack`]s and
        /// [`AudioSource`]s/[`VideoSource`]s.
        #[cxx_name = "DisposeStream"]
        pub fn dispose_stream(self: &mut Webrtc, id: u64);
    }
}

/// Wraps the [`Inner`] instanse.
/// This struct is intended to be extern and managed outside of the Rust app.
pub struct Webrtc(Box<Inner>);

/// Contains all necessary tools for interoperate with [`libWebRTC`].
///
/// [`libWebrtc`]: https://tinyurl.com/54y935zz
#[allow(dead_code)]
pub struct Inner {
    task_queue_factory: TaskQueueFactory,
    audio_device_module: AudioDeviceModule,
    video_device_info: VideoDeviceInfo,
    peer_connection_factory: PeerConnectionFactory,
    video_sources: HashMap<VideoSourceId, Rc<VideoSource>>,
    video_tracks: HashMap<VideoTrackId, VideoTrack>,
    audio_source: Option<Rc<AudioSource>>,
    audio_tracks: HashMap<AudioTrackId, AudioTrack>,
    local_media_streams: HashMap<MediaStreamId, MediaStream>,
}

// TODO: move to user_media.rs
struct AudioDeviceModule {
    inner: SysAudioDeviceModule,
    // TODO: index 0 at creation
    current_device_id: AudioDeviceId,
}

/// Creates an instanse of [`Webrtc`].
///
/// # Panics
///
/// May panic if `PeerconnectionFactory` is not valiable to be created.
#[must_use]
pub fn init() -> Box<Webrtc> {
    let mut task_queue_factory = TaskQueueFactory::create();
    let peer_connection_factory = PeerConnectionFactory::create().unwrap();
    let audio_device_module = AudioDeviceModule::new(
        AudioLayer::kPlatformDefaultAudio,
        &mut task_queue_factory,
    );

    let video_device_info = VideoDeviceInfo::create().unwrap();

    Box::new(Webrtc(Box::new(Inner {
        task_queue_factory,
        audio_device_module,
        video_device_info,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: HashMap::new(),
        audio_source: None,
        audio_tracks: HashMap::new(),
        local_media_streams: HashMap::new(),
    })))
}
