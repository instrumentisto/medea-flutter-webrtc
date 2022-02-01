use std::fmt;

use anyhow::anyhow;
use cxx::{CxxString,CxxVector,UniquePtr};

use crate::{CreateSdpCallback, PeerConnectionOnEvent, SetDescriptionCallback, Candidate};

/// [`CreateSdpCallback`] that can be transferred to the CXX side.
type DynCreateSdpCallback = Box<dyn CreateSdpCallback>;

/// [`SetDescriptionCallback`] that can be transferred to the CXX side.
type DynSetDescriptionCallback = Box<dyn SetDescriptionCallback>;

pub type DynPeerConnectionOnEvent = Box<dyn PeerConnectionOnEvent>;

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

    /// [RTCSdpType] representation.
    ///
    /// [RTCSdpType]: https://www.w3.org/TR/webrtc/#dom-rtcsdptype
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum SdpType {
        /// [RTCSdpType.offer][1] representation.
        ///
        /// [1]: https://www.w3.org/TR/webrtc/#dom-rtcsdptype-offer
        kOffer,

        /// [RTCSdpType.pranswer][1] representation.
        ///
        /// [1]: https://www.w3.org/TR/webrtc/#dom-rtcsdptype-offer
        kPrAnswer,

        /// [RTCSdpType.answer][1] representation.
        ///
        /// [1]: https://www.w3.org/TR/webrtc/#dom-rtcsdptype-answer
        kAnswer,

        /// [RTCSdpType.rollback][1] representation.
        ///
        /// [1]: https://www.w3.org/TR/webrtc/#dom-rtcsdptype-rollback
        kRollback,
    }

    // todo.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum SignalingState {
        kStable,
        kHaveLocalOffer,
        kHaveLocalPrAnswer,
        kHaveRemoteOffer,
        kHaveRemotePrAnswer,
        kClosed,
    }

    // todo.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum IceGatheringState {
        kIceGatheringNew,
        kIceGatheringGathering,
        kIceGatheringComplete,
    }

    // todo.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    enum PeerConnectionState {
        kNew,
        kConnecting,
        kConnected,
        kDisconnected,
        kFailed,
        kClosed,
    }

    // todo.
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    enum IceConnectionState {
        kIceConnectionNew,
        kIceConnectionChecking,
        kIceConnectionConnected,
        kIceConnectionCompleted,
        kIceConnectionFailed,
        kIceConnectionDisconnected,
        kIceConnectionClosed,
        kIceConnectionMax,
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
        type SignalingState;
        type IceGatheringState;
        type PeerConnectionState;
        type IceConnectionState;

        type IceCandidateInterface;
        type Candidate;

        /// Creates a default [`RTCConfiguration`].
        pub fn create_default_rtc_configuration()
            -> UniquePtr<RTCConfiguration>;

        /// Creates a new [`PeerConnectionInterface`].
        ///
        /// If creation fails then an error will be written to the provided
        /// `error` and the returned [`UniquePtr`] will be `null`.
        pub fn create_peer_connection_or_error(
            peer_connection_factory: Pin<&mut PeerConnectionFactoryInterface>,
            conf: &RTCConfiguration,
            deps: UniquePtr<PeerConnectionDependencies>,
            error: &mut String,
        ) -> UniquePtr<PeerConnectionInterface>;

        /// Creates a new [`PeerConnectionObserver`].
        pub fn create_peer_connection_observer(
            cb: Box<DynPeerConnectionOnEvent>,
        ) -> UniquePtr<PeerConnectionObserver>;

        /// Creates a [`PeerConnectionDependencies`] from the provided
        /// [`PeerConnectionObserver`].
        pub fn create_peer_connection_dependencies(
            observer: &UniquePtr<PeerConnectionObserver>,
        ) -> UniquePtr<PeerConnectionDependencies>;

        /// Creates a default [`RTCOfferAnswerOptions`].
        pub fn create_default_rtc_offer_answer_options(
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a new [`RTCOfferAnswerOptions`] from the provided options.
        pub fn create_rtc_offer_answer_options(
            offer_to_receive_video: i32,
            offer_to_receive_audio: i32,
            voice_activity_detection: bool,
            ice_restart: bool,
            use_rtp_mux: bool,
        ) -> UniquePtr<RTCOfferAnswerOptions>;

        /// Creates a new [`CreateSessionDescriptionObserver`] from the
        /// provided [`DynCreateSdpCallback`].
        pub fn create_create_session_observer(
            cb: Box<DynCreateSdpCallback>,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a new [`SetLocalDescriptionObserver`] from the provided
        /// [`DynSetDescriptionCallback`].
        pub fn create_set_local_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetLocalDescriptionObserver>;

        /// Creates a new [`SetRemoteDescriptionObserver`] from the provided
        /// [`DynSetDescriptionCallback`].
        pub fn create_set_remote_description_observer(
            cb: Box<DynSetDescriptionCallback>,
        ) -> UniquePtr<SetRemoteDescriptionObserver>;

        /// Calls the [`RTCPeerConnection::createOffer()`][1] on the provided
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc/#dom-rtcpeerconnection-createoffer
        pub fn create_offer(
            peer: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls the [`RTCPeerConnection::createAnswer()`][1] on the provided
        /// [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc/#dom-rtcpeerconnection-createanswer
        pub fn create_answer(
            peer: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: UniquePtr<CreateSessionDescriptionObserver>,
        );

        /// Calls the [`RTCPeerConnection::setLocalDescription()`][1] on the
        /// provided [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc/#dom-peerconnection-setlocaldescription
        pub fn set_local_description(
            peer: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetLocalDescriptionObserver>,
        );

        /// Calls the [`RTCPeerConnection::setRemoteDescription()`][1] on the
        /// provided [`PeerConnectionInterface`].
        ///
        /// [1]: https://w3.org/TR/webrtc/#dom-peerconnection-setremotedescription
        pub fn set_remote_description(
            peer: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetRemoteDescriptionObserver>,
        );

        /// Creates a new [`SessionDescriptionInterface`].
        #[namespace = "webrtc"]
        #[cxx_name = "CreateSessionDescription"]
        pub fn create_session_description(
            kind: SdpType,
            sdp: &CxxString,
        ) -> UniquePtr<SessionDescriptionInterface>;

        //todo
        pub unsafe fn ice_candidate_interface_to_string(
            candidate: *const IceCandidateInterface
        ) -> UniquePtr<CxxString>;

        pub fn candidate_to_string(candidate: &Candidate) -> UniquePtr<CxxString>;
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
    }

    extern "Rust" {
        fn _touch_candidate(i: UniquePtr<Candidate>);
    }

    extern "Rust" {
        type DynSetDescriptionCallback;
        type DynCreateSdpCallback;
        type DynPeerConnectionOnEvent;

        /// Successfully completes the provided [`DynSetDescriptionCallback`].
        pub fn create_sdp_success(
            cb: Box<DynCreateSdpCallback>,
            sdp: &CxxString,
            kind: SdpType,
        );

        /// Completes the provided [`DynCreateSdpCallback`] with an error.
        pub fn create_sdp_fail(
            cb: Box<DynCreateSdpCallback>,
            error: &CxxString,
        );

        /// Successfully completes the provided [`DynSetDescriptionCallback`].
        pub fn set_description_success(cb: Box<DynSetDescriptionCallback>);

        /// Completes the provided [`DynSetDescriptionCallback`] with an error.
        pub fn set_description_fail(
            cb: Box<DynSetDescriptionCallback>,
            error: &CxxString,
        );

        /// todo
        pub fn call_peer_connection_on_signaling_change(
            cb: &mut DynPeerConnectionOnEvent,
            state: SignalingState,
        );
        pub fn call_peer_connection_on_standardized_ice_connection_change(
            cb: &mut DynPeerConnectionOnEvent,
            new_state: IceConnectionState,
        );
        pub fn call_peer_connection_on_connection_change(
            cb: &mut DynPeerConnectionOnEvent,
            new_state: PeerConnectionState,
        );
        pub fn call_peer_connection_on_ice_gathering_change(
            cb: &mut DynPeerConnectionOnEvent,
            new_state: IceGatheringState,
        );
        pub fn call_peer_connection_on_negotiation_needed_event(
            cb: &mut DynPeerConnectionOnEvent,
            event_id: u32,
        );
        pub fn call_peer_connection_on_ice_candidate_error(
            cb: &mut DynPeerConnectionOnEvent,
            host_candidate: &CxxString,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );
        pub fn call_peer_connection_on_ice_candidate_address_port_error(
            cb: &mut DynPeerConnectionOnEvent,
            address: &CxxString,
            port: i32,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );
        pub fn call_peer_connection_on_ice_connection_receiving_change(
            cb: &mut DynPeerConnectionOnEvent,
            receiving: bool,
        );
        pub fn call_peer_connection_on_interesting_usage(
            cb: &mut DynPeerConnectionOnEvent,
            usage_pattern: i32,
        );

        pub unsafe fn call_peer_connection_on_ice_candidate(
            cb: &mut DynPeerConnectionOnEvent,
            candidate: *const IceCandidateInterface,
        );

    }
}

/// Successfully completes the provided [`DynSetDescriptionCallback`].
#[allow(clippy::boxed_local)]
pub fn create_sdp_success(
    mut cb: Box<DynCreateSdpCallback>,
    sdp: &CxxString,
    kind: webrtc::SdpType,
) {
    cb.success(sdp, kind);
}

/// Completes the provided [`DynCreateSdpCallback`] with an error.
#[allow(clippy::boxed_local)]
pub fn create_sdp_fail(mut cb: Box<DynCreateSdpCallback>, error: &CxxString) {
    cb.fail(error);
}

/// Successfully completes the provided [`DynSetDescriptionCallback`].
#[allow(clippy::boxed_local)]
pub fn set_description_success(mut cb: Box<DynSetDescriptionCallback>) {
    cb.success();
}

/// Completes the provided [`DynSetDescriptionCallback`] with an error.
#[allow(clippy::boxed_local)]
pub fn set_description_fail(
    mut cb: Box<DynSetDescriptionCallback>,
    error: &CxxString,
) {
    cb.fail(error);
}

pub fn call_peer_connection_on_signaling_change(
    cb: &mut DynPeerConnectionOnEvent,
    state: webrtc::SignalingState,
) {
    cb.on_signaling_change(state);
}

pub fn call_peer_connection_on_standardized_ice_connection_change(
    cb: &mut DynPeerConnectionOnEvent,
    new_state: webrtc::IceConnectionState,
) {
    cb.on_standardized_ice_connection_change(new_state);
}
pub fn call_peer_connection_on_connection_change(
    cb: &mut DynPeerConnectionOnEvent,
    new_state: webrtc::PeerConnectionState,
) {
    cb.on_connection_change(new_state);
}
pub fn call_peer_connection_on_ice_gathering_change(
    cb: &mut DynPeerConnectionOnEvent,
    new_state: webrtc::IceGatheringState,
) {
    cb.on_ice_gathering_change(new_state);
}
pub fn call_peer_connection_on_negotiation_needed_event(
    cb: &mut DynPeerConnectionOnEvent,
    event_id: u32,
) {
    cb.on_negotiation_needed_event(event_id);
}
pub fn call_peer_connection_on_ice_candidate_error(
    cb: &mut DynPeerConnectionOnEvent,
    host_candidate: &CxxString,
    url: &CxxString,
    error_code: i32,
    error_text: &CxxString,
) {
    cb.on_ice_candidate_error(host_candidate, url, error_code, error_text);
}
pub fn call_peer_connection_on_ice_candidate_address_port_error(
    cb: &mut DynPeerConnectionOnEvent,
    address: &CxxString,
    port: i32,
    url: &CxxString,
    error_code: i32,
    error_text: &CxxString,
) {
    cb.on_ice_candidate_address_port_error(
        address, port, url, error_code, error_text,
    );
}
pub fn call_peer_connection_on_ice_connection_receiving_change(
    cb: &mut DynPeerConnectionOnEvent,
    receiving: bool,
) {
    cb.on_ice_connection_receiving_change(receiving);
}

pub fn call_peer_connection_on_interesting_usage(
    cb: &mut DynPeerConnectionOnEvent,
    usage_pattern: i32,
) {
    cb.on_interesting_usage(usage_pattern);
}

pub fn call_peer_connection_on_ice_candidate(
    cb: &mut DynPeerConnectionOnEvent,
    candidate: *const webrtc::IceCandidateInterface,
) {
    cb.on_ice_candidate(candidate);
}

pub fn call_peer_connection_on_ice_candidates_removed(
    cb: &mut DynPeerConnectionOnEvent,
    candidates: Vec<UniquePtr<Candidate>>,
) {
    cb.on_ice_candidates_removed(candidates);
}

fn _touch_candidate(_: cxx::UniquePtr<Candidate>) {}

impl TryFrom<&str> for webrtc::SdpType {
    type Error = anyhow::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "offer" => Ok(webrtc::SdpType::kOffer),
            "answer" => Ok(webrtc::SdpType::kAnswer),
            "pranswer" => Ok(webrtc::SdpType::kPrAnswer),
            "rollback" => Ok(webrtc::SdpType::kRollback),
            _ => Err(anyhow!("Invalid SdpType `{}`", value)),
        }
    }
}

impl fmt::Display for webrtc::SdpType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            webrtc::SdpType::kOffer => write!(f, "offer"),
            webrtc::SdpType::kAnswer => write!(f, "answer"),
            webrtc::SdpType::kPrAnswer => write!(f, "pranswer"),
            webrtc::SdpType::kRollback => write!(f, "rollback"),
            _ => unreachable!(),
        }
    }
}

impl ToString for webrtc::SignalingState {
    fn to_string(&self) -> String {
        match *self {
            webrtc::SignalingState::kStable => "kStable".to_owned(),
            webrtc::SignalingState::kHaveLocalOffer => {
                "kHaveLocalOffer".to_owned()
            }
            webrtc::SignalingState::kHaveLocalPrAnswer => {
                "kHaveLocalPrAnswer".to_owned()
            }
            webrtc::SignalingState::kHaveRemoteOffer => {
                "kHaveRemoteOffer".to_owned()
            }
            webrtc::SignalingState::kHaveRemotePrAnswer => {
                "kHaveRemotePrAnswer".to_owned()
            }
            webrtc::SignalingState::kClosed => "kClosed".to_owned(),
            _ => unreachable!(),
        }
    }
}

impl ToString for webrtc::IceGatheringState {
    fn to_string(&self) -> String {
        match *self {
            webrtc::IceGatheringState::kIceGatheringNew => {
                "kIceGatheringNew".to_owned()
            }
            webrtc::IceGatheringState::kIceGatheringGathering => {
                "kIceGatheringGathering".to_owned()
            }
            webrtc::IceGatheringState::kIceGatheringComplete => {
                "kIceGatheringComplete".to_owned()
            }
            _ => unreachable!(),
        }
    }
}

impl ToString for webrtc::IceConnectionState {
    fn to_string(&self) -> String {
        match *self {
            webrtc::IceConnectionState::kIceConnectionNew => {
                "kIceConnectionNew".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionChecking => {
                "kIceConnectionChecking".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionConnected => {
                "kIceConnectionConnected".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionCompleted => {
                "kIceConnectionCompleted".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionFailed => {
                "kIceConnectionFailed".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionDisconnected => {
                "kIceConnectionDisconnected".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionClosed => {
                "kIceConnectionClosed".to_owned()
            }
            webrtc::IceConnectionState::kIceConnectionMax => {
                "kIceConnectionMax".to_owned()
            }
            _ => unreachable!(),
        }
    }
}

impl ToString for webrtc::PeerConnectionState {
    fn to_string(&self) -> String {
        match *self {
            webrtc::PeerConnectionState::kNew => "kNew".to_owned(),
            webrtc::PeerConnectionState::kConnecting => {
                "kConnecting".to_owned()
            }
            webrtc::PeerConnectionState::kConnected => "kConnected".to_owned(),
            webrtc::PeerConnectionState::kDisconnected => {
                "kDisconnected".to_owned()
            }
            webrtc::PeerConnectionState::kFailed => "kFailed".to_owned(),
            webrtc::PeerConnectionState::kClosed => "kClosed".to_owned(),
            _ => unreachable!(),
        }
    }
}
