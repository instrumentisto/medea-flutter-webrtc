use cxx::UniquePtr;

mod bridge;
pub use bridge::webrtc;

/// Creates default [libWebRTC Task Queue Factory].
///
/// [libWebRTC Task Queue Factory]: https://tinyurl.com/yhtrryye
#[rustfmt::skip]
pub fn create_default_task_queue_factory() -> UniquePtr<webrtc::TaskQueueFactory>
{
    webrtc::create_default_task_queue_factory()
}

/// Creates [libWebRTC Audio Device Module] with default Windows layout.
///
/// [libWebRTC Audio Device Module]: https://tinyurl.com/2xf4pnrt
pub fn create_audio_device_module(
    task_queue_factory: UniquePtr<webrtc::TaskQueueFactory>,
) -> UniquePtr<webrtc::AudioDeviceModule> {
    unsafe { webrtc::create_audio_device_module(task_queue_factory) }
}

/// Initializes [libWebRTC Audio Device Module].
///
/// [libWebRTC Audio Device Module]: https://tinyurl.com/2xf4pnrt
pub fn init_audio_device_module(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) {
    unsafe { webrtc::init_audio_device_module(audio_device_module) }
}

/// Returns count of audio playout devices.
pub fn count_audio_playout_devices(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) -> i16 {
    unsafe { webrtc::playout_devices(audio_device_module) }
}

/// Returns count of audio recording devices.
pub fn count_audio_recording_devices(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
) -> i16 {
    unsafe { webrtc::recording_devices(audio_device_module) }
}

/// Returns a tuple with an audio playout device information `(id, name)`.
pub fn get_audio_playout_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_playout_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Returns a tuple with an audio recording device information `(id, name)`.
pub fn get_audio_recording_device_info(
    audio_device_module: &UniquePtr<webrtc::AudioDeviceModule>,
    index: i16,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_recording_audio_info(audio_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Creates libWebRTC Video Device Info.
pub fn create_video_device_module() -> UniquePtr<webrtc::VideoDeviceInfo> {
    webrtc::create_video_device_info()
}

/// Returns count of video recording devices.
pub fn count_video_devices(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
) -> u32 {
    unsafe { webrtc::number_of_video_devices(video_device_module) }
}

/// Returns a tuple with an video recording device information `(id, name)`.
pub fn get_video_device_info(
    video_device_module: &UniquePtr<webrtc::VideoDeviceInfo>,
    index: u32,
) -> (String, String) {
    let mut info;
    unsafe {
        info = webrtc::get_video_device_name(video_device_module, index);
    }
    (info.pop().unwrap(), info.pop().unwrap())
}

/// Creates a [Thread].
///
/// [Thread]: https://tinyurl.com/yhtrryye
pub fn create_thread() -> UniquePtr<webrtc::Thread> {
    webrtc::create_thread()
}

/// Starts the [Thread].
///
/// [Thread]: https://tinyurl.com/yhtrryye
pub fn start_thread(thread: &UniquePtr<webrtc::Thread>) {
    unsafe {
        webrtc::start_thread(thread);
    }
}

/// Creates a new [Peer Connection Factory].
/// This interface provides 3 main directions: Peer Connection Interface, Local
/// Media Stream Interface and Local Video and Audio Track Interface,
///
/// [Peer Connection Factory]: https://tinyurl.com/44wywepd
pub fn create_peer_connection_factory(
    worker_thread: &UniquePtr<webrtc::Thread>,
    signaling_thread: &UniquePtr<webrtc::Thread>,
) -> UniquePtr<webrtc::PeerConnectionFactoryInterface> {
    unsafe {
        webrtc::create_peer_connection_factory(worker_thread, signaling_thread)
    }
}

/// Creates a new [Video Source], which provides source of frames from native
/// platform.
///
/// [Video Source]: https://tinyurl.com/52fwxnan
pub fn create_video_source(
    worker_thread: &UniquePtr<webrtc::Thread>,
    signaling_thread: &UniquePtr<webrtc::Thread>,
    width: usize,
    height: usize,
    fps: usize,
) -> UniquePtr<webrtc::VideoTrackSourceInterface> {
    unsafe {
        webrtc::create_video_source(
            worker_thread,
            signaling_thread,
            width,
            height,
            fps,
        )
    }
}

/// Creates a new Audio Source, which provides sound recording from native
/// platform.
pub fn create_audio_source(
    peer_connection_factory: &UniquePtr<webrtc::PeerConnectionFactoryInterface>,
) -> UniquePtr<webrtc::AudioSourceInterface> {
    unsafe { webrtc::create_audio_source(peer_connection_factory) }
}

/// Creates Video [Track].
///
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn create_video_track(
    peer_connection_factory: &UniquePtr<webrtc::PeerConnectionFactoryInterface>,
    video_source: &UniquePtr<webrtc::VideoTrackSourceInterface>,
) -> UniquePtr<webrtc::VideoTrackInterface> {
    unsafe { webrtc::create_video_track(peer_connection_factory, video_source) }
}

/// Creates Audio [Track].
///
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn create_audio_track(
    peer_connection_factory: &UniquePtr<webrtc::PeerConnectionFactoryInterface>,
    audio_source: &UniquePtr<webrtc::AudioSourceInterface>,
) -> UniquePtr<webrtc::AudioTrackInterface> {
    unsafe { webrtc::create_audio_track(peer_connection_factory, audio_source) }
}

/// Creates an empty local [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
pub fn create_local_media_stream(
    peer_connection_factory: &UniquePtr<webrtc::PeerConnectionFactoryInterface>,
) -> UniquePtr<webrtc::MediaStreamInterface> {
    unsafe { webrtc::create_local_media_stream(peer_connection_factory) }
}

/// Adds Video [Track] to [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn add_video_track(
    media_stream: &UniquePtr<webrtc::MediaStreamInterface>,
    track: &UniquePtr<webrtc::VideoTrackInterface>,
) -> bool {
    unsafe { webrtc::add_video_track(media_stream, track) }
}

/// Adds Audio [Track] to [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn add_audio_track(
    media_stream: &UniquePtr<webrtc::MediaStreamInterface>,
    track: &UniquePtr<webrtc::AudioTrackInterface>,
) -> bool {
    unsafe { webrtc::add_audio_track(media_stream, track) }
}

/// Removes Video [Track] from [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn remove_video_track(
    media_stream: &UniquePtr<webrtc::MediaStreamInterface>,
    track: &UniquePtr<webrtc::VideoTrackInterface>,
) -> bool {
    unsafe { webrtc::remove_video_track(media_stream, track) }
}

/// Removes Audio [Track] from [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
/// [Track]: https://tinyurl.com/yc79x5s8
pub fn remove_audio_track(
    media_stream: &UniquePtr<webrtc::MediaStreamInterface>,
    track: &UniquePtr<webrtc::AudioTrackInterface>,
) -> bool {
    unsafe { webrtc::remove_audio_track(media_stream, track) }
}

pub fn stream_test() -> bool {
    let worker_thread = create_thread();
    start_thread(&worker_thread);

    let signaling_thread = create_thread();
    start_thread(&signaling_thread);

    let _ =
        create_video_source(&worker_thread, &signaling_thread, 640, 380, 30);

    true
}

#[cfg(test)]
mod test {
    use super::stream_test;

    #[test]
    fn it_works() {
        assert!(stream_test());
    }
}
