use cxx::CxxString;

use crate::{create_transceivers, Transceivers};

#[allow(clippy::expl_impl_clone_on_copy, clippy::items_after_statements)]
#[cxx::bridge(namespace = "bridge")]
pub(crate) mod webrtc {
    /// Possible kinds of audio devices implementation.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum AudioLayer {
        kPlatformDefaultAudio = 0,
        kWindowsCoreAudio,
        kWindowsCoreAudio2,
        kLinuxAlsaAudio,
        kLinuxPulseAudio,
        kAndroidJavaAudio,
        kAndroidOpenSLESAudio,
        kAndroidJavaInputAndOpenSLESOutputAudio,
        kAndroidAAudioAudio,
        kAndroidJavaInputAndAAudioOutputAudio,
        kDummyAudio,
    }

    /// The RTCSdpType enum describes
    /// the type of an RTCSessionDescriptionInit,
    /// RTCLocalSessionDescriptionInit,
    /// or RTCSessionDescription instance.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum SdpType {
        /// An RTCSdpType of "offer" indicates
        /// that a description MUST be treated as an [SDP] offer.
        kOffer = 0,

        /// An RTCSdpType of "pranswer" indicates that a description
        /// MUST be treated as an [SDP] answer, but not a final answer.
        /// A description used as an SDP pranswer may be applied
        /// as a response to an SDP offer, or an update to
        /// a previously sent SDP pranswer.
        kPrAnswer,

        /// An RTCSdpType of "answer" indicates that a description
        /// MUST be treated as an [SDP] final answer,
        /// and the offer-answer exchange MUST be considered complete.
        /// A description used as an SDP answer may be applied
        /// as a response to an SDP offer or as an update
        /// to a previously sent SDP pranswer.
        kAnswer,

        /// An RTCSdpType of "rollback" indicates that a description
        /// MUST be treated as canceling the current SDP negotiation
        /// and moving the SDP [SDP] offer back to what
        /// it was in the previous stable state.
        /// Note the local or remote SDP descriptions
        /// in the previous stable state could be null
        /// if there has not yet been a successful
        /// offer-answer negotiation.
        /// An "answer" or "pranswer" cannot be rolled back.
        kRollback,
    }

    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum MediaType {
        MEDIA_TYPE_AUDIO = 0,
        MEDIA_TYPE_VIDEO,
        MEDIA_TYPE_DATA,
        MEDIA_TYPE_UNSUPPORTED,
    }

    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum RtpTransceiverDirection {
        kSendRecv = 0,
        kSendOnly,
        kRecvOnly,
        kInactive,
        kStopped,
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type PeerConnectionFactoryInterface;
        type TaskQueueFactory;
        type Thread;

        /// Creates a default [`TaskQueueFactory`] based on the current
        /// platform.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory()
            -> UniquePtr<TaskQueueFactory>;

        /// Creates a new [`Thread`].
        pub fn create_thread() -> UniquePtr<Thread>;

        /// Starts the current [`Thread`].
        #[cxx_name = "Start"]
        pub fn start_thread(self: Pin<&mut Thread>) -> bool;

        /// Creates a new [`PeerConnectionFactoryInterface`].
        /// Where `default_adm` - can be?? NULL,
        /// `audio_mixer` - can be NULL,
        /// `audio_processing` - can be?? NULL,
        /// `audio_frame_processor` - default NULL,
        #[allow(clippy::too_many_arguments)]
        pub fn create_peer_connection_factory(
            network_thread: &UniquePtr<Thread>,
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
            default_adm: &UniquePtr<AudioDeviceModule>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;
    }

    unsafe extern "C++" {
        type AudioDeviceModule;
        type AudioLayer;

        /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
        pub fn create_audio_device_module(
            audio_layer: AudioLayer,
            task_queue_factory: Pin<&mut TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        /// Initializes the given [`AudioDeviceModule`].
        pub fn init_audio_device_module(
            audio_device_module: &AudioDeviceModule,
        ) -> i32;

        /// Returns count of available audio playout devices.
        pub fn playout_devices(audio_device_module: &AudioDeviceModule) -> i16;

        /// Returns count of available audio recording devices.
        pub fn recording_devices(
            audio_device_module: &AudioDeviceModule,
        ) -> i16;

        /// Writes device info to the provided `name` and `id` for the given
        /// audio playout device `index`.
        pub fn playout_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            id: &mut String,
        ) -> i32;

        /// Writes device info to the provided `name` and `id` for the given
        /// audio recording device `index`.
        pub fn recording_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            id: &mut String,
        ) -> i32;

        /// Specifies which microphone to use for recording audio using an
        /// index retrieved by the corresponding enumeration method which is
        /// [`AudiDeviceModule::RecordingDeviceName`].
        pub fn set_audio_recording_device(
            audio_device_module: &AudioDeviceModule,
            index: u16,
        ) -> i32;
    }

    unsafe extern "C++" {
        type VideoDeviceInfo;

        /// Creates a new [`VideoDeviceInfo`].
        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        /// Returns count of a video recording devices.
        #[namespace = "webrtc"]
        #[cxx_name = "NumberOfDevices"]
        pub fn number_of_video_devices(self: Pin<&mut VideoDeviceInfo>) -> u32;

        /// Writes device info to the provided `name` and `id` for the given
        /// video device `index`.
        pub fn video_device_name(
            device_info: Pin<&mut VideoDeviceInfo>,
            index: u32,
            name: &mut String,
            id: &mut String,
        ) -> i32;
    }

    extern "Rust" {
        type DynSetDescriptionCallback;
        type DynCreateSdpCallback;
        type Transceivers;

        /// Adds a new [`RtpTransceiverInterface`].
        pub fn add(
            self: &mut Transceivers,
            transceiver: UniquePtr<RtpTransceiverInterface>,
        );

        /// Creates a new `boxed` [`Transceivers`].
        pub fn create_transceivers() -> Box<Transceivers>;

        /// Calling in `CreateSessionDescriptionObserver`,
        /// when `CreateOffer/Answer` is success.
        pub fn success_sdp(
            cb: &mut DynCreateSdpCallback,
            sdp: &CxxString,
            kind: &CxxString,
        );

        /// Calling in `CreateSessionDescriptionObserver`,
        /// when `CreateOffer/Answer` is fail.
        pub fn fail_sdp(cb: &mut DynCreateSdpCallback, error: &CxxString);

        /// Calling in `SetLocal/RemoteDescriptionObserver`,
        /// when `SetLocal/RemoteDescription` is success.
        pub fn success_set_description(cb: &mut DynSetDescriptionCallback);

        /// Calling in `SetLocal/RemoteDescriptionObserver`,
        /// when `SetLocal/RemoteDescription` is success.
        pub fn fail_set_description(
            cb: &mut DynSetDescriptionCallback,
            error: &CxxString,
        );

    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        type CreateSessionDescriptionObserver;
        type PeerConnectionDependencies;
        type PeerConnectionInterface;
        type PeerConnectionObserver;
        type RTCConfiguration;
        type RTCOfferAnswerOptions;
        type SdpType;
        type SessionDescriptionInterface;
        type SetLocalDescriptionObserver;
        type SetRemoteDescriptionObserver;

        type MediaType;
        type RtpTransceiverDirection;
        type RtpTransceiverInterface;

        /// Creates default [`RTCConfiguration`].
        pub fn create_default_rtc_configuration()
            -> UniquePtr<RTCConfiguration>;

        /// Creates a [`PeerConnectionInterface`].
        /// # Warning
        /// `error` for error handle without c++ exception.
        /// If 'error` != "" after the call,
        /// then the result will be default or NULL.
        pub fn create_peer_connection_or_error(
            peer_connection_factory: Pin<&mut PeerConnectionFactoryInterface>,
            configuration: &RTCConfiguration,
            dependencies: UniquePtr<PeerConnectionDependencies>,
            error: &mut String,
        ) -> UniquePtr<PeerConnectionInterface>;

        /// Creates a [`PeerConnectionObserver`].
        pub fn create_peer_connection_observer(
        ) -> UniquePtr<PeerConnectionObserver>;

        /// Creates a [`PeerConnectionDependencies`].
        pub fn create_peer_connection_dependencies(
            observer: UniquePtr<PeerConnectionObserver>,
        ) -> UniquePtr<PeerConnectionDependencies>;

        /// Creates default [`RTCOfferAnswerOptions`].
        pub fn create_default_rtc_offer_answer_options(
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a [`RTCOfferAnswerOptions`].
        pub fn create_rtc_offer_answer_options(
            offer_to_receive_video: i32,
            offer_to_receive_audio: i32,
            voice_activity_detection: bool,
            ice_restart: bool,
            use_rtp_mux: bool,
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a [`CreateSessionDescriptionObserver`].
        pub fn create_create_session_observer(
            cb: Box<DynCreateSdpCallback>,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a [`SetLocalDescriptionObserver`].
        pub fn create_set_local_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetLocalDescriptionObserver>;

        /// Creates a [`SetRemoteDescriptionObserver`].
        pub fn create_set_remote_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetRemoteDescriptionObserver>;

        /// Calls `peer_connection_interface`->CreateOffer.
        pub fn create_offer(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls `peer_connection_interface`->CreateAnswer.
        pub fn create_answer(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls `peer_connection_interface`->SetLocalDescription.
        pub fn set_local_description(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetLocalDescriptionObserver>,
        );

        /// Calls `peer_connection_interface`->SetRemoteDescription.
        pub fn set_remote_description(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetRemoteDescriptionObserver>,
        );

        /// Creates [`SessionDescriptionInterface`]
        #[namespace = "webrtc"]
        #[cxx_name = "CreateSessionDescription"]
        pub fn create_session_description(
            kind: SdpType,
            sdp: &CxxString,
        ) -> UniquePtr<SessionDescriptionInterface>;

        /// Adds a new [`RTCRtpTransceiver`][1] to some [`PeerConnectionInterface`].
        ///
        /// [1]: https://tinyurl.com/2p88ajym
        pub fn add_transceiver(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            media_type: MediaType,
            direction: RtpTransceiverDirection
        ) -> UniquePtr<RtpTransceiverInterface>;

        /// Gets information about [`PeerConnectionInterface`]'s [`RTCRtpTransceiver`]s.
        ///
        /// [1]: https://tinyurl.com/2p88ajym
        pub fn get_transceivers(peer_connection_interface: &PeerConnectionInterface) -> Box<Transceivers>;

        pub fn get_transceiver_mid(transceiver: &RtpTransceiverInterface) -> String;

        pub fn get_transceiver_ptr(transceiver: &RtpTransceiverInterface) -> usize;

        pub fn get_transceiver_direction(transceiver: &RtpTransceiverInterface) -> RtpTransceiverDirection;
    }

    unsafe extern "C++" {
        type AudioSourceInterface;
        type AudioTrackInterface;
        type MediaStreamInterface;
        type VideoTrackInterface;
        type VideoTrackSourceInterface;

        /// Creates a new [`VideoTrackSourceInterface`].
        pub fn create_video_source(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
            width: usize,
            height: usize,
            fps: usize,
            device_index: u32,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        /// Creates a new [`AudioSourceInterface`].
        pub fn create_audio_source(
            peer_connection_factory: &PeerConnectionFactoryInterface,
        ) -> UniquePtr<AudioSourceInterface>;

        /// Creates a new [`VideoTrackInterface`].
        pub fn create_video_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
            video_source: &VideoTrackSourceInterface,
        ) -> UniquePtr<VideoTrackInterface>;

        /// Creates a new [`AudioTrackInterface`].
        pub fn create_audio_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
            audio_source: &AudioSourceInterface,
        ) -> UniquePtr<AudioTrackInterface>;

        /// Creates a new [`MediaStreamInterface`].
        pub fn create_local_media_stream(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            id: String,
        ) -> UniquePtr<MediaStreamInterface>;

        /// Adds the [`VideoTrackInterface`] to the [`MediaStreamInterface`].
        pub fn add_video_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        /// Adds the [`AudioTrackInterface`] to the [`MediaStreamInterface`].
        pub fn add_audio_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;

        /// Removes the [`VideoTrackInterface`] from the
        /// [`MediaStreamInterface`].
        pub fn remove_video_track(
            media_stream: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        /// Removes the [`AudioTrackInterface`] from the
        /// [`MediaStreamInterface`].
        pub fn remove_audio_track(
            media_stream: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;

        pub fn ustest(peer_connection_interface: &PeerConnectionInterface);
    }
}

/// Trait for `CreateSessionDescriptionObserver` callbacks.
pub trait CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: &CxxString);
    fn fail(&mut self, error: &CxxString);
}
/// `DynCreateSdpCallback` used for double box, for extern Rust.
type DynCreateSdpCallback = Box<dyn CreateSdpCallback>;

/// Calls when `CreateOffer/Answer` is success.
pub fn success_sdp(
    cb: &mut DynCreateSdpCallback,
    sdp: &CxxString,
    kind: &CxxString,
) {
    cb.success(sdp, kind);
}
/// Calls when `CreateOffer/Answer` is fail.
pub fn fail_sdp(cb: &mut DynCreateSdpCallback, error: &CxxString) {
    cb.fail(error);
}

/// Trait for `SetLocalDescriptionObserver` callbacks.
pub trait SetDescriptionCallback {
    fn success(&mut self);
    fn fail(&mut self, error: &CxxString);
}
/// `DynSetDescriptionCallback` used for double box, for extern Rust.
type DynSetDescriptionCallback = Box<dyn SetDescriptionCallback>;

/// Calls in `OnSetLocalDescriptionComplete`
/// when `SetLocalRemoteDescription` is success.
pub fn success_set_description(cb: &mut DynSetDescriptionCallback) {
    cb.success();
}
/// Calls in `OnSetLocalDescriptionComplete`
/// when `SetLocalRemoteDescription` is fail.
pub fn fail_set_description(
    cb: &mut DynSetDescriptionCallback,
    error: &CxxString,
) {
    cb.fail(error);
}

impl TryFrom<&str> for webrtc::SdpType {
    type Error = anyhow::Error;

    /// Implement TryFrom<&str> for `SdpType`.
    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "offer" => Ok(webrtc::SdpType::kOffer),
            "answer" => Ok(webrtc::SdpType::kAnswer),
            "pranswer" => Ok(webrtc::SdpType::kPrAnswer),
            "rollback" => Ok(webrtc::SdpType::kRollback),
            _ => Err(anyhow::Error::msg("Invalid type")),
        }
    }
}
