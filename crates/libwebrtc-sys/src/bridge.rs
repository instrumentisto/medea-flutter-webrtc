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
        type VideoFrame;
        type VideoRenderer;

        pub fn create_default_task_queue_factory() -> UniquePtr<TaskQueueFactory>;

        pub fn create_audio_device_module(
            task_queue_factory: UniquePtr<TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;
        pub fn init_audio_device_module(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        );
        pub fn playout_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;
        pub fn recording_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;
        pub fn get_playout_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;
        pub fn get_recording_audio_info(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
            index: i16,
        ) -> Vec<String>;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;
        pub fn number_of_video_devices(
            device_info: &UniquePtr<VideoDeviceInfo>,
        ) -> u32;
        pub fn get_video_device_name(
            device_info: &UniquePtr<VideoDeviceInfo>,
            index: u32,
        ) -> Vec<String>;

        pub fn create_thread() -> UniquePtr<Thread>;

        pub fn start_thread(thread: &UniquePtr<Thread>);

        pub fn create_peer_connection_factory(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
        ) -> UniquePtr<PeerConnectionFactoryInterface>;

        pub fn create_video_source(
            worker_thread: &UniquePtr<Thread>,
            signaling_thread: &UniquePtr<Thread>,
            width: usize,
            height: usize,
            fps: usize,
        ) -> UniquePtr<VideoTrackSourceInterface>;

        pub fn create_audio_source(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<AudioSourceInterface>;

        pub fn create_video_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            video_source: &UniquePtr<VideoTrackSourceInterface>,
        ) -> UniquePtr<VideoTrackInterface>;

        pub fn create_audio_track(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
            audio_source: &UniquePtr<AudioSourceInterface>,
        ) -> UniquePtr<AudioTrackInterface>;

        pub fn create_local_media_stream(
            peer_connection_factory: &UniquePtr<PeerConnectionFactoryInterface>,
        ) -> UniquePtr<MediaStreamInterface>;

        pub fn add_video_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        pub fn add_audio_track(
            peer_connection_factory: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;

        pub fn remove_video_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<VideoTrackInterface>,
        ) -> bool;

        pub fn remove_audio_track(
            media_stream: &UniquePtr<MediaStreamInterface>,
            track: &UniquePtr<AudioTrackInterface>,
        ) -> bool;

        pub fn frame_width(frame: &UniquePtr<VideoFrame>) -> i32;

        pub fn frame_height(frame: &UniquePtr<VideoFrame>) -> i32;

        pub fn frame_rotation(frame: &UniquePtr<VideoFrame>) -> i32;

        pub unsafe fn convert_to_argb(
            frame: &UniquePtr<VideoFrame>,
            buffer_size: i32,
        ) -> Vec<u8>;

        pub unsafe fn get_video_renderer(cb: unsafe fn(UniquePtr<VideoFrame>, *mut i64), flutter_cb_ptr: *mut i64, video_track: &UniquePtr<VideoTrackInterface>) -> UniquePtr<VideoRenderer>;

        // pub fn test(cb: fn(UniquePtr<VideoFrame>));
    }
}
