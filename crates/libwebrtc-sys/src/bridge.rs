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

        pub fn create_thread() -> UniquePtr<Thread>;

        #[allow(clippy::missing_safety_doc)]
        pub fn start_thread(thread: Pin<&mut Thread>) -> bool;

        #[namespace = "webrtc"]
        #[cxx_name = "CreateBuiltinVideoEncoderFactory"]
        pub fn create_builtin_video_encoder_factory(
        ) -> UniquePtr<VideoEncoderFactory>;

        #[namespace = "webrtc"]
        #[cxx_name = "CreateBuiltinVideoDecoderFactory"]
        pub fn create_builtin_video_decoder_factory(
        ) -> UniquePtr<VideoDecoderFactory>;

        pub fn create_builtin_audio_encoder_factory(
        ) -> UniquePtr<AudioEncoderFactory>;

        pub fn create_builtin_audio_decoder_factory(
        ) -> UniquePtr<AudioDecoderFactory>;

        pub fn create_audio_device_module_null() -> UniquePtr<AudioDeviceModule>;

        pub fn create_audio_mixer_null() -> UniquePtr<AudioMixer>;

        pub fn create_audio_processing_null() -> UniquePtr<AudioProcessing>;

        pub fn create_audio_frame_processor_null(
        ) -> UniquePtr<AudioFrameProcessor>;

        pub unsafe fn create_peer_connection_factory_null(
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
    }
}
