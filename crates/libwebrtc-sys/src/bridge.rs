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
        type Thread;
        type PeerConnectionFactoryInterface;
        type VideoTrackSourceInterface;
        type AudioSourceInterface;
        type VideoTrackInterface;
        type AudioTrackInterface;
        type MediaStreamInterface;

        /// Creates a default [`TaskQueueFactory`] based on the current
        /// platform.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;

        pub fn create_thread() -> UniquePtr<Thread>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn start_thread(thread: Pin<&mut Thread>) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_peer_connection_factory(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_video_source(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
            width: usize,
            height: usize,
            fps: usize,
            device_id: String,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_audio_source(
            peer_connection_factory: &PeerConnectionFactoryInterface,
        ) -> UniquePtr<AudioSourceInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_video_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            video_source: &VideoTrackSourceInterface,
        ) -> UniquePtr<VideoTrackInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_audio_track(
            peer_connection_factory: &PeerConnectionFactoryInterface,
            audio_source: &AudioSourceInterface,
        ) -> UniquePtr<AudioTrackInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_local_media_stream(
            peer_connection_factory: &PeerConnectionFactoryInterface,
        ) -> UniquePtr<MediaStreamInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn add_video_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn add_audio_track(
            peer_connection_factory: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn remove_video_track(
            media_stream: &MediaStreamInterface,
            track: &VideoTrackInterface,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn remove_audio_track(
            media_stream: &MediaStreamInterface,
            track: &AudioTrackInterface,
        ) -> bool;
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

        pub fn get_device_index(
            device_info: Pin<&mut VideoDeviceInfo>,
            device: String,
        ) -> u32;

        pub fn test();
    }
}
