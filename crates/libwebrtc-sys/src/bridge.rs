use cxx::CxxString;

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

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");
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
        type SetLocalRemoteDescriptionCallBack;
        type CreateOfferAnswerCallback;

        /// Calling in `CreateSessionDescriptionObserver`,
        /// when `CreateOffer/Answer` is success.
        pub fn success_sdp(
            cb: &CreateOfferAnswerCallback,
            sdp: &CxxString,
            type_: &CxxString,
        );

        /// Calling in `CreateSessionDescriptionObserver`,
        /// when `CreateOffer/Answer` is fail.
        pub fn fail_sdp(cb: &CreateOfferAnswerCallback, error: &CxxString);

        /// Calling in `SetLocalDescriptionObserverInterface`,
        /// when SetLocalRemoteDescription` is success.
        pub fn success_set_description(cb: &SetLocalRemoteDescriptionCallBack);

        /// Calling in `SetRemoteDescriptionObserverInterface`,
        /// when SetLocalRemoteDescription` is success.
        pub fn fail_set_description(
            cb: &SetLocalRemoteDescriptionCallBack,
            error: &CxxString,
        );

    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        type AudioDecoderFactory;
        type AudioEncoderFactory;
        type AudioFrameProcessor;
        type AudioMixer;
        type AudioProcessing;
        type CreateSessionDescriptionObserver;
        type PeerConnectionDependencies;
        type PeerConnectionFactoryInterface;
        type PeerConnectionInterface;
        type PeerConnectionObserver;
        type RTCConfiguration;
        type RTCOfferAnswerOptions;
        type SdpType;
        type SessionDescriptionInterface;
        type SetLocalDescriptionObserverInterface;
        type SetRemoteDescriptionObserverInterface;
        type VideoDecoderFactory;
        type VideoEncoderFactory;

        /// Creates a new [`VideoEncoderFactory`].
        #[namespace = "webrtc"]
        #[cxx_name = "CreateBuiltinVideoEncoderFactory"]
        pub fn create_builtin_video_encoder_factory(
        ) -> UniquePtr<VideoEncoderFactory>;

        /// Creates a new [`VideoDecoderFactory`].
        #[namespace = "webrtc"]
        #[cxx_name = "CreateBuiltinVideoDecoderFactory"]
        pub fn create_builtin_video_decoder_factory(
        ) -> UniquePtr<VideoDecoderFactory>;

        /// Creates a new [`AudioEncoderFactory`].
        pub fn create_builtin_audio_encoder_factory(
        ) -> UniquePtr<AudioEncoderFactory>;

        /// Creates a new [`AudioDecoderFactory`].
        pub fn create_builtin_audio_decoder_factory(
        ) -> UniquePtr<AudioDecoderFactory>;

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
            default_adm: UniquePtr<AudioDeviceModule>,
            audio_encoder_factory: Pin<&mut AudioEncoderFactory>,
            audio_decoder_factory: Pin<&mut AudioDecoderFactory>,
            video_encoder_factory: UniquePtr<VideoEncoderFactory>,
            video_decoder_factory: UniquePtr<VideoDecoderFactory>,
            audio_mixer: UniquePtr<AudioMixer>,
            audio_processing: UniquePtr<AudioProcessing>,
            audio_frame_processor: UniquePtr<AudioFrameProcessor>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;

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
            error: &mut String,
            configuration: &RTCConfiguration,
            dependencies: UniquePtr<PeerConnectionDependencies>,
        ) -> UniquePtr<PeerConnectionInterface>;

        /// Creates a [`PeerConnectionObserver`].
        pub fn create_peer_connection_observer(
            e: fn(&CxxString),
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
            cb: Box<CreateOfferAnswerCallback>,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a [`SetLocalDescriptionObserverInterface`].
        pub fn create_set_local_description_observer_interface(
            cb: Box<SetLocalRemoteDescriptionCallBack>,
        ) -> UniquePtr<SetLocalDescriptionObserverInterface>;

        /// Creates a [`SetRemoteDescriptionObserverInterface`].
        pub fn create_set_remote_description_observer_interface(
            cb: Box<SetLocalRemoteDescriptionCallBack>,
        ) -> UniquePtr<SetRemoteDescriptionObserverInterface>;

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
            obs: UniquePtr<SetLocalDescriptionObserverInterface>,
        );

        /// Calls `peer_connection_interface`->SetRemoteDescription.
        pub fn set_remote_description(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: UniquePtr<SetRemoteDescriptionObserverInterface>,
        );

        /// Creates [`SessionDescriptionInterface`]
        #[namespace = "webrtc"]
        #[cxx_name = "CreateSessionDescription"]
        pub fn create_session_description(
            type_: SdpType,
            sdp: &CxxString,
        ) -> UniquePtr<SessionDescriptionInterface>;
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
}

/// Trait for `CreateSessionDescriptionObserver` callbacks.
pub trait CreateSdpCallback {
    fn success(&self, sdp: &CxxString, type_: &CxxString);
    fn fail(&self, error: &CxxString);
}
/// `CreateOfferAnswerCallback` used for double box, for extern Rust.
pub type CreateOfferAnswerCallback = Box<dyn CreateSdpCallback>;

/// Calls when `CreateOffer/Answer` is success.
pub fn success_sdp(
    cb: &CreateOfferAnswerCallback,
    sdp: &CxxString,
    type_: &CxxString,
) {
    cb.success(sdp, type_);
}
/// Calls when `CreateOffer/Answer` is fail.
pub fn fail_sdp(cb: &CreateOfferAnswerCallback, error: &CxxString) {
    cb.fail(error);
}

/// Trait for `SetLocalDescriptionObserverInterface` callbacks.
pub trait SetDescriptionCallback {
    fn success(&self);
    fn fail(&self, error: &CxxString);
}
/// `SetLocalRemoteDescriptionCallBack` used for double box, for extern Rust.
pub type SetLocalRemoteDescriptionCallBack = Box<dyn SetDescriptionCallback>;
/// Calls in `OnSetLocalDescriptionComplete`
/// when `SetLocalRemoteDescription` is success.
pub fn success_set_description(cb: &SetLocalRemoteDescriptionCallBack) {
    cb.success();
}
/// Calls in `OnSetLocalDescriptionComplete`
/// when `SetLocalRemoteDescription` is fail.
pub fn fail_set_description(
    cb: &SetLocalRemoteDescriptionCallBack,
    error: &CxxString,
) {
    cb.fail(error);
}

impl TryFrom<&str> for webrtc::SdpType {
    type Error = anyhow::Error;

    /// Implement TryFrom<&str>.
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
