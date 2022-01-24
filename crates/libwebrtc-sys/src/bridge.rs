use cxx::CxxString;

#[allow(clippy::expl_impl_clone_on_copy)]
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

        /// Creates a new [`Thead`].
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
        type CallBackCreateOfferAnswer;
        type CallBackDescription;

        pub fn success_set_descr(self: &mut CallBackDescription);
        pub fn fail_set_descr(
            self: &mut CallBackDescription,
            error: &CxxString,
        );

        pub fn success_create(
            self: &mut CallBackCreateOfferAnswer,
            sdp: &CxxString,
            type_: &CxxString,
        );
        pub fn fail_create(
            self: &mut CallBackCreateOfferAnswer,
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
        /// Where
        /// `s` for callback when 'CreateOffer\Answer' is OnSuccess,
        /// `f` for callback when 'CreateOffer\Answer' is OnFailure.
        pub fn create_create_session_observer(
            cb: Box<CallBackCreateOfferAnswer>,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a [`SetLocalDescriptionObserverInterface`].
        pub fn create_set_local_description_observer_interface(
            cb: Box<CallBackDescription>,
        ) -> UniquePtr<SetLocalDescriptionObserverInterface>;

        /// Creates a [`SetRemoteDescriptionObserverInterface`].
        pub fn create_set_remote_description_observer_interface(
            cb: Box<CallBackDescription>,
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

pub struct CallBackDescription {
    fn_success: fn(usize, usize),
    success: usize,
    fn_fail: fn(usize, &CxxString, usize),
    fail: usize,
    fn_drop: fn(usize, usize),
    drop: usize,
    context: usize,
}

impl CallBackDescription {
    pub fn new(
        success: usize,
        fail: usize,
        drop: usize,
        context: usize,
    ) -> Self {
        let fn_success = |f: usize, cntx: usize| {
            let f_: extern "C" fn(usize) = unsafe { std::mem::transmute(f) };
            f_(cntx);
        };

        let fn_fail = |f: usize, error: &CxxString, cntx: usize| {
            let f_: extern "C" fn(&CxxString, usize) =
                unsafe { std::mem::transmute(f) };
            f_(error, cntx);
        };

        let fn_drop = |f: usize, cntx: usize| {
            let f_: extern "C" fn(usize) = unsafe { std::mem::transmute(f) };
            f_(cntx);
        };
        Self {
            fn_success,
            success,
            fn_fail,
            fail,
            fn_drop,
            drop,
            context,
        }
    }

    pub fn success_set_descr(&mut self) {
        let fn_s = self.fn_success;
        fn_s(self.success, self.context);
    }
    pub fn fail_set_descr(&mut self, error: &CxxString) {
        let fn_f = self.fn_fail;
        fn_f(self.fail, error, self.context);
    }
}

impl Drop for CallBackDescription {
    fn drop(&mut self) {
        let fn_d = self.fn_drop;
        fn_d(self.drop, self.context);
    }
}

pub struct CallBackCreateOfferAnswer {
    fn_success: fn(usize, &CxxString, &CxxString, usize),
    success: usize,
    fn_fail: fn(usize, &CxxString, usize),
    fail: usize,
    fn_drop: fn(usize, usize),
    drop: usize,
    context: usize,
}

impl CallBackCreateOfferAnswer {
    pub fn new(
        success: usize,
        fail: usize,
        drop: usize,
        context: usize,
    ) -> Self {
        let fn_success =
            |f: usize, sdp: &CxxString, type_: &CxxString, cntx: usize| {
                let f_: extern "C" fn(&CxxString, &CxxString, usize) =
                    unsafe { std::mem::transmute(f) };
                f_(sdp, type_, cntx);
            };

        let fn_fail = |f: usize, error: &CxxString, cntx: usize| {
            let f_: extern "C" fn(&CxxString, usize) =
                unsafe { std::mem::transmute(f) };
            f_(error, cntx);
        };

        let fn_drop = |f: usize, cntx: usize| {
            let f_: extern "C" fn(usize) = unsafe { std::mem::transmute(f) };
            f_(cntx);
        };
        Self {
            fn_success,
            success,
            fn_fail,
            fail,
            fn_drop,
            drop,
            context,
        }
    }

    pub fn success_create(&mut self, sdp: &CxxString, type_: &CxxString) {
        let fn_s = self.fn_success;
        fn_s(self.success, sdp, type_, self.context);
    }
    pub fn fail_create(&mut self, error: &CxxString) {
        let fn_f = self.fn_fail;
        fn_f(self.fail, error, self.context);
    }
}

impl Drop for CallBackCreateOfferAnswer {
    fn drop(&mut self) {
        let fn_d = self.fn_drop;
        fn_d(self.drop, self.context);
    }
}

impl TryFrom<&str> for webrtc::SdpType {
    type Error = anyhow::Error;

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
