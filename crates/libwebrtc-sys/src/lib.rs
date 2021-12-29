#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use anyhow::bail;
use cxx::UniquePtr;

use self::bridge::webrtc;

pub use webrtc::AudioLayer;

/// Thread safe task queue factory internally used in [`webrtc`] that is
/// capable of creating [Task Queue]s.
///
/// [Task Queue]: https://tinyurl.com/doc-threads
pub struct TaskQueueFactory(UniquePtr<webrtc::TaskQueueFactory>);

impl TaskQueueFactory {
    /// Creates a default [`TaskQueueFactory`] based on the current platform.
    #[must_use]
    pub fn create_default_task_queue_factory() -> Self {
        Self(webrtc::create_default_task_queue_factory())
    }
}

/// Available audio devices manager that is responsible for driving input
/// (microphone) and output (speaker) audio in WebRTC.
///
/// Backed by WebRTC's [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
    pub fn create(
        audio_layer: AudioLayer,
        task_queue_factory: &mut TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_audio_device_module(
            audio_layer,
            task_queue_factory.0.pin_mut(),
        );

        if ptr.is_null() {
            bail!("`null` pointer returned from `AudioDeviceModule::Create()`");
        }
        Ok(Self(ptr))
    }

    /// Initializes the current [`AudioDeviceModule`].
    pub fn init(&self) -> anyhow::Result<()> {
        let result = webrtc::init_audio_device_module(&self.0);
        if result != 0 {
            bail!("`AudioDeviceModule::Init()` failed with `{}` code", result);
        }
        Ok(())
    }

    /// Returns count of available audio playout devices.
    pub fn playout_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::playout_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::PlayoutDevices()` failed with `{}` code",
                count,
            );
        }

        Ok(count)
    }

    /// Returns count of available audio recording devices.
    pub fn recording_devices(&self) -> anyhow::Result<i16> {
        let count = webrtc::recording_devices(&self.0);

        if count < 0 {
            bail!(
                "`AudioDeviceModule::RecordingDevices()` failed with `{}` code",
                count
            );
        }

        Ok(count)
    }

    /// Returns the `(label, id)` tuple for the given audio playout device
    /// `index`.
    pub fn playout_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result =
            webrtc::playout_device_name(&self.0, index, &mut name, &mut guid);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::PlayoutDeviceName()` failed with `{}` \
                 code",
                result,
            );
        }

        Ok((name, guid))
    }

    /// Returns the `(label, id)` tuple for the given audio recording device
    /// `index`.
    pub fn recording_device_name(
        &self,
        index: i16,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result =
            webrtc::recording_device_name(&self.0, index, &mut name, &mut guid);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::RecordingDeviceName()` failed with \
                 `{}` code",
                result,
            );
        }

        Ok((name, guid))
    }
}

/// Interface for receiving information about available camera devices.
pub struct VideoDeviceInfo(UniquePtr<webrtc::VideoDeviceInfo>);

impl VideoDeviceInfo {
    /// Creates a new [`VideoDeviceInfo`].
    pub fn create() -> anyhow::Result<Self> {
        let ptr = webrtc::create_video_device_info();

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `VideoCaptureFactory::CreateDeviceInfo()`",
            );
        }
        Ok(Self(ptr))
    }

    /// Returns count of a video recording devices.
    pub fn number_of_devices(&mut self) -> u32 {
        self.0.pin_mut().number_of_video_devices()
    }

    /// Returns the `(label, id)` tuple for the given video device `index`.
    pub fn device_name(
        &mut self,
        index: u32,
    ) -> anyhow::Result<(String, String)> {
        let mut name = String::new();
        let mut guid = String::new();

        let result = webrtc::video_device_name(
            self.0.pin_mut(),
            index,
            &mut name,
            &mut guid,
        );

        if result != 0 {
            bail!(
                "`AudioDeviceModule::GetDeviceName()` failed with `{}` code",
                result,
            );
        }

        Ok((name, guid))
    }
}

/// Interface for using a [Thread].
///
/// [Thread]: https://tinyurl.com/yhtrryye
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a [`Thread`].
    pub fn create() -> anyhow::Result<Self> {
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
    ///
    /// # Panics
    ///
    /// Panics if thread is not valiable to be started.
    pub fn start(&mut self) -> anyhow::Result<()> {
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
    ///
    /// # Panics
    ///
    /// Panics if thread is not valiable to be started.
    pub fn create() -> anyhow::Result<Self> {
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
    ///
    /// # Panics
    ///
    /// Panics if thread is not valiable to be started.
    pub fn create_video_source(
        &mut self,
        width: usize,
        height: usize,
        fps: usize,
    ) -> anyhow::Result<VideoSource> {
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
    pub fn create_audio_source(&self) -> anyhow::Result<AudioSource> {
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
    ) -> anyhow::Result<VideoTrack> {
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
    ) -> anyhow::Result<AudioTrack> {
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
    pub fn create_local_media_stream(
        &self,
    ) -> anyhow::Result<LocalMediaStream> {
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
    pub fn add_video_track(&self, track: &VideoTrack) -> anyhow::Result<()> {
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
    pub fn add_audio_track(&self, track: &AudioTrack) -> anyhow::Result<()> {
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
    pub fn remove_video_track(&self, track: &VideoTrack) -> anyhow::Result<()> {
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
    pub fn remove_audio_track(&self, track: &AudioTrack) -> anyhow::Result<()> {
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
