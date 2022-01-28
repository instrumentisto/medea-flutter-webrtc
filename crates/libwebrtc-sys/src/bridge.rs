use crate::{on_frame, DynOnFrameCallback};

#[allow(clippy::expl_impl_clone_on_copy)]
#[allow(clippy::items_after_statements)]
// #[allow(clippy::all)]
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

        type PeerConnectionFactoryInterface;
        type TaskQueueFactory;
        type Thread;

        /// Creates a default [`TaskQueueFactory`] based on the current
        /// platform.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;

        /// Creates a new [`Thead`].
        pub fn create_thread() -> UniquePtr<Thread>;

        /// Starts the current [`Thread`].
        #[cxx_name = "Start"]
        pub fn start_thread(self: Pin<&mut Thread>) -> bool;

        /// Creates a new [`PeerConnectionFactory`].
        pub fn create_peer_connection_factory(
            worker_thread: Pin<&mut Thread>,
            signaling_thread: Pin<&mut Thread>,
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

    /// Possible variants of [`VideoFrame`]'s rotation.
    #[repr(i32)]
    #[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
    pub enum VideoRotation {
        kVideoRotation_0 = 0,
        kVideoRotation_90 = 90,
        kVideoRotation_180 = 180,
        kVideoRotation_270 = 270,
    }

    unsafe extern "C++" {
        #[namespace = "webrtc"]
        type VideoFrame;
        type VideoSinkObserver;
        type VideoSink;
        type VideoRotation;

        /// Returns width of the [`VideoFrame`].
        #[cxx_name = "width"]
        #[must_use]
        pub fn width(self: &VideoFrame) -> i32;

        /// Returns height of the [`VideoFrame`].
        #[cxx_name = "height"]
        #[must_use]
        pub fn height(self: &VideoFrame) -> i32;

        /// Returns [`VideoRotation`] of the [`VideoFrame`].
        #[cxx_name = "rotation"]
        #[must_use]
        pub fn rotation(self: &VideoFrame) -> VideoRotation;

        /// Converts [`VideoFrame`]'s `i420 buffer` to `ABGR buffer`.
        pub unsafe fn i420_to_abgr(frame: &VideoFrame, buffer_ptr: *mut u8);

        /// Adds a new [`VideoSink`] to the [`VideoTrackInterface`].
        pub fn add_or_update_video_sink(
            track: &VideoTrackInterface,
            sink: Pin<&mut VideoSink>,
        );

        /// Removes the [`VideoSink`] from the [`VideoTrackInterface`].
        pub fn remove_video_sink(
            track: &VideoTrackInterface,
            sink: Pin<&mut VideoSink>,
        );

        /// Creates a new [`VideoSink`] for
        /// the given `callbacks`.
        pub fn create_video_sink(
            handler: Box<DynOnFrameCallback>,
        ) -> UniquePtr<VideoSink>;
    }

    extern "Rust" {
        type DynOnFrameCallback;

        /// Calls [`DynOnFrameCallback`]'s `callback`.
        pub fn on_frame(
            cb: &mut DynOnFrameCallback,
            frame: UniquePtr<VideoFrame>,
        );
    }
}
