#[cxx::bridge(namespace = "WEBRTC")]
#[rustfmt::skip]
pub mod webrtc {
    // C++ types and signatures exposed to Rust.
    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;
        type AudioDeviceModule;
        type VideoDeviceInfo;
        type Thread;
        type PeerConnectionFactoryInterface;
        type VideoTrackSourceInterface;
        type AudioSourceInterface;
        type VideoTrackInterface;
        type AudioTrackInterface;
        type MediaStreamInterface;

        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_audio_device_module(
            task_queue_factory: UniquePtr<TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn init_audio_device_module(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        );

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn playout_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn recording_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn get_playout_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn get_recording_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn number_of_video_devices(
            device_info: &UniquePtr<VideoDeviceInfo>,
        ) -> u32;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn get_video_device_name(
            device_info: &UniquePtr<VideoDeviceInfo>,
            index: u32,
        ) -> Vec<String>;

        pub fn create_thread() -> UniquePtr<Thread>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn start_thread(thread: &UniquePtr<Thread>) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_peer_connection_factory(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_video_source(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
            width: usize,
            height: usize,
            fps: usize,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_audio_source(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<AudioSourceInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_video_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            video_source: &UniquePtr<VideoTrackSourceInterface>,
        ) -> UniquePtr<VideoTrackInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_audio_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            audio_source: &UniquePtr<AudioSourceInterface>,
        ) -> UniquePtr<AudioTrackInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn create_local_media_stream(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<MediaStreamInterface>;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn add_video_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn add_audio_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn remove_video_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        #[allow(clippy::missing_safety_doc)]
        pub unsafe fn remove_audio_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;
    }
}
