use anyhow::{bail, Result};
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

pub fn stream_test() -> bool {
    // let worker_thread = create_thread();
    // start_thread(&worker_thread);

    // let signaling_thread = create_thread();
    // start_thread(&signaling_thread);

    // let _ =
    //     create_video_source(&worker_thread, &signaling_thread, 640, 380, 30);

    // let c = PeerConnectionFactory::create().unwrap();
    // let asd = c.create_video_source(640, 380, 30).unwrap();
    // let dsa = c.create_video_track(&asd);

    true
}

/// Interface for using a [Thread].
///
/// [Thread]: https://tinyurl.com/yhtrryye
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a [`Thread`].
    pub fn create() -> Result<Self> {
        let ptr = webrtc::create_thread();

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                rtc::Thread::Create()"
            );
        }
        Ok(Self(ptr))
    }

    /// Starts the [`Thread`].
    pub fn start(&mut self) -> Result<()> {
        let result = unsafe { webrtc::start_thread(self.0.as_mut().unwrap()) };

        if !result {
            bail!(
                "Thread is running or failed calling \
                rtc::Thread::Start()"
            );
        }
        Ok(())
    }
}

/// Interface for using [Peer Connection Factory].
///
/// [Peer Connection Factory]: https://tinyurl.com/44wywepd
pub struct PeerConnectionFactory {
    pointer: UniquePtr<webrtc::PeerConnectionFactoryInterface>,
    worker_thread: Thread,
    signaling_thread: Thread,
}

impl PeerConnectionFactory {
    /// Creates a new [`PeerConnectionFactory`].
    /// This interface provides 3 main directions: Peer Connection Interface,
    /// Local Media Stream Interface and Local Video and Audio Track
    /// Interface.
    pub fn create() -> Result<Self> {
        let mut worker_thread = Thread::create().unwrap();
        worker_thread.start().unwrap();
        let mut signaling_thread = Thread::create().unwrap();
        signaling_thread.start().unwrap();

        let pointer = unsafe {
            webrtc::create_peer_connection_factory(
                worker_thread.0.as_mut().unwrap(),
                signaling_thread.0.as_mut().unwrap(),
            )
        };

        if pointer.is_null() {
            bail!(
                "Null pointer returned from \
                webrtc::CreatePeerConnectionFactory()"
            );
        }
        Ok(Self {
            pointer,
            worker_thread,
            signaling_thread,
        })
    }

    /// Creates a new [`VideoSource`], which provides source of frames from
    /// native platform.
    pub fn create_video_source(
        &mut self,
        width: usize,
        height: usize,
        fps: usize,
    ) -> Result<VideoSource> {
        let ptr = unsafe {
            webrtc::create_video_source(
                self.worker_thread.0.as_mut().unwrap(),
                self.signaling_thread.0.as_mut().unwrap(),
                width,
                height,
                fps,
            )
        };

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                webrtc::CreateVideoTrackSourceProxy()"
            );
        }
        Ok(VideoSource(ptr))
    }

    /// Creates a new [`AudioSource`], which provides sound recording from
    /// native platform.
    pub fn create_audio_source(&self) -> Result<AudioSource> {
        let ptr = unsafe { webrtc::create_audio_source(&self.pointer) };

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                webrtc::PeerConnectionFactoryInterface::CreateAudioSource()"
            );
        }
        Ok(AudioSource(ptr))
    }

    /// Creates a new [`VideoTrack`] using [`VideoSource`].
    pub fn create_video_track(
        &self,
        video_src: &VideoSource,
    ) -> Result<VideoTrack> {
        let ptr =
            unsafe { webrtc::create_video_track(&self.pointer, &video_src.0) };

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                    webrtc::VideoTrackSourceInterface::CreateVideoTrack()"
            );
        }
        Ok(VideoTrack(ptr))
    }

    /// Creates a new [`AudioTrack`] using [`AudioSource`].
    pub fn create_audio_track(
        &self,
        audio_src: &AudioSource,
    ) -> Result<AudioTrack> {
        let ptr =
            unsafe { webrtc::create_audio_track(&self.pointer, &audio_src.0) };

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                    webrtc::VideoTrackSourceInterface::CreateAudioTrack()"
            );
        }
        Ok(AudioTrack(ptr))
    }

    /// Creates an empty [`LocalMediaStream`].
    pub fn create_local_media_stream(&self) -> Result<LocalMediaStream> {
        let ptr = unsafe { webrtc::create_local_media_stream(&self.pointer) };

        if ptr.is_null() {
            bail!(
                "Null pointer returned from \
                    webrtc::VideoTrackSourceInterface::CreateLocalMediaStream()"
            );
        }
        Ok(LocalMediaStream(ptr))
    }
}

/// Interface for [Video Source].
///
/// [Video Source]: https://tinyurl.com/52fwxnan
pub struct VideoSource(UniquePtr<webrtc::VideoTrackSourceInterface>);

/// Interface for Audio Source.
pub struct AudioSource(UniquePtr<webrtc::AudioSourceInterface>);

/// Interface for Video [Track]
///
/// [Track]: https://tinyurl.com/yc79x5s8
pub struct VideoTrack(UniquePtr<webrtc::VideoTrackInterface>);

/// Interface for Audio [Track]
///
/// [Track]: https://tinyurl.com/yc79x5s8
pub struct AudioTrack(UniquePtr<webrtc::AudioTrackInterface>);

/// Interface for local [Media Stream].
///
/// [Media Stream]: https://tinyurl.com/2k2376z9
pub struct LocalMediaStream(UniquePtr<webrtc::MediaStreamInterface>);

impl LocalMediaStream {
    /// Adds [`VideoTrack`] to [`LocalMediaStream`].
    pub fn add_video_track(&self, track: &VideoTrack) -> Result<()> {
        let result = unsafe { webrtc::add_video_track(&self.0, &track.0) };

        if !result {
            bail!(
                "Failed calling \
                webrtc::MediaStreamInterface::AddTrack()"
            );
        }
        Ok(())
    }

    /// Adds [`AudioTrack`] to [`LocalMediaStream`].
    pub fn add_audio_track(&self, track: &AudioTrack) -> Result<()> {
        let result = unsafe { webrtc::add_audio_track(&self.0, &track.0) };

        if !result {
            bail!(
                "Failed calling \
                webrtc::MediaStreamInterface::AddTrack()"
            );
        }
        Ok(())
    }

    /// Removes [`VideoTrack`] from [`LocalMediaStream`].
    pub fn remove_video_track(&self, track: &VideoTrack) -> Result<()> {
        let result = unsafe { webrtc::remove_video_track(&self.0, &track.0) };

        if !result {
            bail!(
                "Failed calling \
                webrtc::MediaStreamInterface::RemoveTrack()"
            );
        }
        Ok(())
    }

    /// Removes [`AudioTrack`] from [`LocalMediaStream`].
    pub fn remove_audio_track(&self, track: &AudioTrack) -> Result<()> {
        let result = unsafe { webrtc::remove_audio_track(&self.0, &track.0) };

        if !result {
            bail!(
                "Failed calling \
                webrtc::MediaStreamInterface::RemoveTrack()"
            );
        }
        Ok(())
    }
}

#[cfg(test)]
mod test {
    use super::stream_test;

    #[test]
    fn it_works() {
        assert!(stream_test());
    }
}
