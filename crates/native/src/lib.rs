#![warn(clippy::pedantic)]

mod device_info;
mod peer_connection;
mod user_media;

use std::{collections::HashMap, rc::Rc};

use libwebrtc_sys::{
    AudioLayer, AudioSourceInterface, PeerConnectionFactoryInterface,
    TaskQueueFactory, Thread, VideoDeviceInfo,
};

use peer_connection::{PeerConnection, PeerConnectionId};

#[doc(inline)]
pub use crate::user_media::{
    AudioDeviceId, AudioDeviceModule, AudioTrack, AudioTrackId, MediaStream,
    MediaStreamId, VideoDeviceId, VideoSource, VideoTrack, VideoTrackId,
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
        kAudio,
        kVideo,
    }

    #[allow(clippy::too_many_arguments)]
    extern "Rust" {
        type Webrtc;

        /// Creates an instance of [`Webrtc`].
        #[cxx_name = "Init"]
        pub fn init() -> Box<Webrtc>;

        /// Returns a list of all available media input and output devices, such
        /// as microphones, cameras, headsets, and so forth.
        #[cxx_name = "EnumerateDevices"]
        fn enumerate_devices(self: &mut Webrtc) -> Vec<MediaDeviceInfo>;

        /// Creates a new [`PeerConnection`] and return id.
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If `error` != "" after the call,
        /// then the result will be default or NULL.
        #[cxx_name = "CreatePeerConnection"]
        fn create_default_peer_connection(
            self: &mut Webrtc,
            error: &mut String,
        ) -> u64;

        /// Creates a new [Offer].
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If `error` != "" after the call,
        /// then the result will be default or NULL.
        #[cxx_name = "CreateOffer"]
        fn create_offer(
            self: &mut Webrtc,
            error: &mut String,
            peer_connection_id: u64,
            offer_to_receive_video: i32,
            offer_to_receive_audio: i32,
            voice_activity_detection: bool,
            ice_restart: bool,
            use_rtp_mux: bool,
            s: usize,
            f: usize,
        );

        /// Creates a new [Answer].
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If `error` != "" after the call,
        /// then the result will be default or NULL.
        #[cxx_name = "CreateAnswer"]
        #[allow(clippy::too_many_arguments)]
        fn create_answer(
            self: &mut Webrtc,
            error: &mut String,
            peer_connection_id: u64,
            offer_to_receive_video: i32,
            offer_to_receive_audio: i32,
            voice_activity_detection: bool,
            ice_restart: bool,
            use_rtp_mux: bool,
            s: usize,
            f: usize,
        );

        /// Set Local Description.
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If `error` != "" after the call,
        /// then the result will be default or NULL.
        #[cxx_name = "SetLocalDescription"]
        fn set_local_description(
            self: &mut Webrtc,
            error: &mut String,
            peer_connection_id: u64,
            type_: String,
            sdp: String,
            s: usize,
            f: usize,
        );

        /// Set Remote Description.
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If `error` != "" after the call,
        /// then the result will be default or NULL.
        #[cxx_name = "SetRemoteDescription"]
        fn set_remote_description(
            self: &mut Webrtc,
            error: &mut String,
            peer_connection_id: u64,
            type_: String,
            sdp: String,
            s: usize,
            f: usize,
        );

        /// Creates a [`MediaStream`] with tracks according to provided
        /// [`MediaStreamConstraints`].
        #[cxx_name = "GetUserMedia"]
        pub fn get_users_media(
            self: &mut Webrtc,
            constraints: &MediaStreamConstraints,
        ) -> MediaStream;

        /// Disposes the [`MediaStream`] and all contained tracks.
        #[cxx_name = "DisposeStream"]
        pub fn dispose_stream(self: &mut Webrtc, id: u64);
    }
}

/// [`Context`] wrapper that is exposed to the C++ API clients.
pub struct Webrtc(Box<Context>);

/// Application context that manages all dependencies.
#[allow(dead_code)]
pub struct Context {
    task_queue_factory: TaskQueueFactory,
    worker_thread: Thread,
    network_thread: Thread,
    signaling_thread: Thread,
    audio_device_module: AudioDeviceModule,
    video_device_info: VideoDeviceInfo,
    peer_connection_factory: PeerConnectionFactoryInterface,
    video_sources: HashMap<VideoDeviceId, Rc<VideoSource>>,
    video_tracks: HashMap<VideoTrackId, VideoTrack>,
    audio_source: Option<Rc<AudioSourceInterface>>,
    audio_tracks: HashMap<AudioTrackId, AudioTrack>,
    local_media_streams: HashMap<MediaStreamId, MediaStream>,
    peer_connections: HashMap<PeerConnectionId, PeerConnection>,
}

/// Creates an instanse of [`Webrtc`].
///
/// # Panics
///
/// Panics on any error returned from the `libWebRTC`.
#[must_use]
pub fn init() -> Box<Webrtc> {
    // TODO: Dont panic but propagate errors to API users.
    let mut task_queue_factory =
        TaskQueueFactory::create_default_task_queue_factory();

    let mut network_thread = Thread::create().unwrap();
    network_thread.start().unwrap();

    let mut worker_thread = Thread::create().unwrap();
    worker_thread.start().unwrap();

    let mut signaling_thread = Thread::create().unwrap();
    signaling_thread.start().unwrap();

    let peer_connection_factory =
        PeerConnectionFactoryInterface::create_whith_null(
            Some(&network_thread),
            Some(&worker_thread),
            Some(&signaling_thread),
        );

    let audio_device_module = AudioDeviceModule::new(
        AudioLayer::kPlatformDefaultAudio,
        &mut task_queue_factory,
    )
    .unwrap();

    let video_device_info = VideoDeviceInfo::create().unwrap();

    Box::new(Webrtc(Box::new(Context {
        task_queue_factory,
        network_thread,
        worker_thread,
        signaling_thread,
        audio_device_module,
        video_device_info,
        peer_connection_factory,
        video_sources: HashMap::new(),
        video_tracks: HashMap::new(),
        audio_source: None,
        audio_tracks: HashMap::new(),
        local_media_streams: HashMap::new(),
        peer_connections: HashMap::new(),
    })))
}


#[cfg(test)]
mod test {
    use crate::*;
    #[test]
    fn test1() {
        let mut w = init();
        let mut error = String::new();
        let id = w.create_default_peer_connection(&mut error);
        let mut pc = w.0.peer_connections.get_mut(&PeerConnectionId(id)).unwrap();

        let obs 
            = libwebrtc_sys::CreateSessionDescriptionObserver::new(
                |sdp,_| {}, 
                |_| {});
        pc.peer_connection_interface.create_offer(&libwebrtc_sys::RTCOfferAnswerOptions::default(), obs);

        let obs2 
                = libwebrtc_sys::SetLocalDescriptionObserverInterface::new(|| {}, |a|{println!("|{}|", a)});
        pc.peer_connection_interface.set_local_description(
            libwebrtc_sys::SessionDescriptionInterface::new(
                libwebrtc_sys::SdpType::try_from("offer").unwrap(), 
                unsafe {&String::from_utf8_unchecked([118, 61, 48, 13, 10, 111, 61, 45, 32, 50, 56, 52, 49, 52, 54, 53, 53, 48, 57, 57, 52, 54, 54, 56, 53, 55, 55, 57, 32, 50, 32, 73, 78, 32, 73, 80, 52, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 13, 10, 115, 61, 45, 13, 10, 116, 61, 48, 32, 48, 13, 10, 97, 61, 101, 120, 116, 109, 97, 112, 45, 97, 108, 108, 111, 119, 45, 109, 105, 120, 101, 100, 13, 10, 97, 61, 109, 115, 105, 100, 45, 115, 101, 109, 97, 110, 116, 105, 99, 58, 32, 87, 77, 83, 13, 10].to_vec())}), obs2);
    }
}