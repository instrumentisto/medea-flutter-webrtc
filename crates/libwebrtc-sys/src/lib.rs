use cxx::UniquePtr;

#[rustfmt::skip]
mod bridge;

pub use bridge::webrtc::AudioLayer;

use bridge::webrtc;

/// A thread safe task queue factory internally used in `WebRTC` that is
/// capable of creating [Task Queue]s.
///
/// [Task Queue Factory]: https://tinyurl.com/doc-threads
pub struct TaskQueueFactory(UniquePtr<webrtc::TaskQueueFactory>);

impl TaskQueueFactory {
    /// Creates a default [TaskQueueFactory] based on the current platform
    /// capabilities.
    pub fn create_default_task_queue_factory() -> Self {
        Self(webrtc::create_default_task_queue_factory())
    }
}

/// Available audio devices manager that is responsible for driving input
/// (microphone) and output (speaker) audio in `WebRTC`.
///
/// Backed by WebRTC's [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    /// Creates a default [AudioDeviceModule].
    pub fn create(
        audio_layer: AudioLayer,
        task_queue_factory: &mut TaskQueueFactory,
    ) -> Self {
        Self(webrtc::create_audio_device_module(
            audio_layer,
            task_queue_factory.0.pin_mut(),
        ))
    }

    /// Initializes current [AudioDeviceModule].
    pub fn init(&self) {
        webrtc::init_audio_device_module(&self.0);
    }

    /// Returns count of available audio playout devices.
    pub fn playout_devices(&self) -> i16 {
        webrtc::playout_devices(&self.0)
    }

    /// Returns count of available audio recording devices.
    pub fn recording_devices(&self) -> i16 {
        webrtc::recording_devices(&self.0)
    }

    /// Returns a tuple with an audio playout device information `(id, name)`.
    pub fn playout_device_name(&self, index: i16) -> (String, String) {
        let mut info = webrtc::playout_device_name(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }

    /// Returns a tuple with an audio recording device information `(id, name)`.
    pub fn recording_device_name(&self, index: i16) -> (String, String) {
        let mut info = webrtc::recording_device_name(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }
}

/// Interface for receiving information about available camera devices.
pub struct VideoDeviceInfo(UniquePtr<webrtc::VideoDeviceInfo>);

impl VideoDeviceInfo {
    /// Creates a new [VideoDeviceInfo].
    pub fn create_device_info() -> Self {
        Self(webrtc::create_video_device_info())
    }

    /// Returns count of a video recording devices.
    pub fn number_of_devices(&self) -> u32 {
        webrtc::number_of_video_devices(&self.0)
    }

    /// Returns a tuple with an video recording device information `(id, name)`.
    pub fn device_name(&self, index: u32) -> (String, String) {
        let mut info = webrtc::video_device_name(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }
}
