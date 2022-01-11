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

    // TODO: docs
    #[repr(i32)]
    #[derive(Debug, Eq, Hash, PartialEq)]
    pub enum SdpType {
        kOffer = 0,
        kPrAnswer,
        kAnswer,
        kRollback,
    }

    #[rustfmt::skip]
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;

        /// Creates a default [`TaskQueueFactory`] based on the current
        /// platform.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;
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
        type Thread;
        type VideoEncoderFactory;
        type VideoDecoderFactory;
        type PeerConnectionFactoryInterface;
        type AudioEncoderFactory;
        type AudioDecoderFactory;
        type AudioMixer;
        type AudioProcessing;
        type AudioFrameProcessor;
        type PeerConnectionDependencies;
        type RTCConfiguration;
        type PeerConnectionObserver;
        type PeerConnectionInterface;
        type RTCOfferAnswerOptions;
        type SessionDescriptionInterface;
        type SdpType;
        type CreateSessionDescriptionObserver;
        type SetSessionDescriptionObserver;

        // TODO: docs
        pub fn create_thread() -> UniquePtr<Thread>;

        // TODO: try to call member function
        // #[namespace = "webrtc"]
        // #[cxx_name = "CreateBuiltinVideoEncoderFactory"]
        #[allow(clippy::missing_safety_doc)]
        pub fn start_thread(thread: Pin<&mut Thread>) -> bool;

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

        /// Creates NULL [`AudioDecoderFactory`].
        pub fn create_audio_device_module_null() -> UniquePtr<AudioDeviceModule>;

        /// Creates NULL [`AudioMixer`].
        pub fn create_audio_mixer_null() -> UniquePtr<AudioMixer>;

        /// Creates NULL [`AudioProcessing`].
        pub fn create_audio_processing_null() -> UniquePtr<AudioProcessing>;

        /// Creates NULL [`AudioFrameProcessor`].
        pub fn create_audio_frame_processor_null(
        ) -> UniquePtr<AudioFrameProcessor>;

        /// Creates a new [`PeerConnectionFactoryInterface`].
        /// Where `default_adm` - can be?? NULL,
        /// `audio_mixer` - can be NULL,
        /// `audio_processing` - can be?? NULL,
        /// `audio_frame_processor` - default NULL,
        pub unsafe fn create_peer_connection_factory(
            network_thread: *mut Thread,
            worker_thread: *mut Thread,
            signaling_thread: *mut Thread,
            default_adm: *mut AudioDeviceModule,
            audio_encoder_factory: Pin<&mut AudioEncoderFactory>,
            audio_decoder_factory: Pin<&mut AudioDecoderFactory>,
            video_encoder_factory: UniquePtr<VideoEncoderFactory>,
            video_decoder_factory: UniquePtr<VideoDecoderFactory>,
            audio_mixer: *mut AudioMixer,
            audio_processing: *mut AudioProcessing,
            audio_frame_processor: *mut AudioFrameProcessor,
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
        /// `s` - void (*callback_success)(std::string, std::string)
        /// for callback when 'CreateOffer\Answer' is OnSuccess,
        /// `f` - void (*callback_fail)(std::string)
        /// for callback when 'CreateOffer\Answer' is OnFailure.
        pub fn create_create_session_observer(
            s: usize, // TODO: try to pass fn() instead of usize
            f: usize,
        ) -> UniquePtr<CreateSessionDescriptionObserver>;

        /// Creates a [`SetSessionDescriptionObserver`].
        /// Where
        /// `s` - void (*callback_success_desc)()
        /// for callback when 'SetLocal\RemoteDescription' is OnSuccess,
        /// `f` - void (*callback_fail)(std::string)
        /// for callback when 'SetLocal\RemoteDescription' is OnFailure.
        pub fn create_set_session_description_observer(
            s: usize,
            f: usize,
        ) -> UniquePtr<SetSessionDescriptionObserver>;

        /// Calls `peer_connection_interface`->CreateOffer.
        pub unsafe fn create_offer(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: *mut CreateSessionDescriptionObserver,
        );

        /// Calls `peer_connection_interface`->CreateAnswer.
        pub unsafe fn create_answer(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            options: &RTCOfferAnswerOptions,
            obs: *mut CreateSessionDescriptionObserver,
        );

        /// Calls `peer_connection_interface`->SetLocalDescription.
        pub unsafe fn set_local_description(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: *mut SetSessionDescriptionObserver,
        );

        /// Calls `peer_connection_interface`->SetRemoteDescription.
        pub unsafe fn set_remote_description(
            peer_connection_interface: Pin<&mut PeerConnectionInterface>,
            desc: UniquePtr<SessionDescriptionInterface>,
            obs: *mut SetSessionDescriptionObserver,
        );

        /// Creates [`SessionDescriptionInterface`]
        #[namespace = "webrtc"]
        #[cxx_name = "CreateSessionDescription"]
        pub unsafe fn create_session_description(
            type_: SdpType,
            sdp: &CxxString,
        ) -> UniquePtr<SessionDescriptionInterface>;
    }
}
