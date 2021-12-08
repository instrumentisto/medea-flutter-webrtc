#[cxx::bridge(namespace = "WEBRTC")]
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

        pub unsafe fn create_audio_device_module(
            task_queue_factory: UniquePtr<TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;
        pub unsafe fn init_audio_device_module(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        );
        pub unsafe fn playout_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;
        pub unsafe fn recording_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;
        pub unsafe fn get_playout_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;
        pub unsafe fn get_recording_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;
        pub unsafe fn number_of_video_devices(
            device_info: &UniquePtr<VideoDeviceInfo>,
        ) -> u32;
        pub unsafe fn get_video_device_name(
            device_info: &UniquePtr<VideoDeviceInfo>,
            index: u32,
        ) -> Vec<String>;

        pub fn create_thread() -> UniquePtr<Thread>;

        pub unsafe fn start_thread(thread: &UniquePtr<Thread>);

        pub unsafe fn create_peer_connection_factory(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;

        pub unsafe fn create_video_source(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
            width: usize,
            height: usize,
            fps: usize,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        pub unsafe fn create_audio_source(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<AudioSourceInterface>;

        pub unsafe fn create_video_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            video_source: &UniquePtr<VideoTrackSourceInterface>,
        ) -> UniquePtr<VideoTrackInterface>;

        pub unsafe fn create_audio_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            audio_source: &UniquePtr<AudioSourceInterface>,
        ) -> UniquePtr<AudioTrackInterface>;

        pub unsafe fn create_local_media_stream(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<MediaStreamInterface>;

        pub unsafe fn add_video_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        pub unsafe fn add_audio_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;

        pub unsafe fn remove_video_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        pub unsafe fn remove_audio_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;

        pub fn test();
    }
}

unsafe impl Send for webrtc::TaskQueueFactory {}
