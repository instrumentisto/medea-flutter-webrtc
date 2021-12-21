use cxx::UniquePtr;

#[rustfmt::skip]
mod bridge;

pub use bridge::webrtc::AudioLayer;

use bridge::webrtc;

struct TaskQueueFactory(UniquePtr<webrtc::TaskQueueFactory>);

impl TaskQueueFactory {
    fn create_default_task_queue_factory() -> Self {
        Self(webrtc::create_default_task_queue_factory())
    }
}

struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    fn create(
        audio_layer: AudioLayer,
        task_queue_factory: &TaskQueueFactory,
    ) -> Self {
        Self(webrtc::create_audio_device_module(
            audio_layer,
            &task_queue_factory.0,
        ))
    }

    /// Initializes libwebrtc [Audio Device Module].
    ///
    /// [Audio Device Module]: https://tinyurl.com/doc-adm
    pub fn init(&self) {
        webrtc::init_audio_device_module(&self.0);
    }

    /// Returns count of audio playout devices.
    pub fn playout_devices(&self) -> i16 {
        webrtc::playout_devices(&self.0)
    }

    /// Returns count of audio recording devices.
    pub fn recording_devices(&self) -> i16 {
        webrtc::recording_devices(&self.0)
    }

    /// Returns a tuple with an audio playout device information `(id, name)`.
    pub fn playout_device_name(&self, index: i16) -> (String, String) {
        let mut info = webrtc::get_playout_audio_info(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }

    /// Returns a tuple with an audio recording device information `(id, name)`.
    pub fn recording_device_name(&self, index: i16) -> (String, String) {
        let mut info = webrtc::get_recording_audio_info(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }
}

struct VideoDeviceInfo(UniquePtr<webrtc::VideoDeviceInfo>);

impl VideoDeviceInfo {
    /// Creates libwebrtc Video Device Info.
    fn create_device_info() -> Self {
        Self(webrtc::create_video_device_info())
    }

    /// Returns count of video recording devices.
    pub fn number_of_devices(&self) -> u32 {
        webrtc::number_of_video_devices(&self.0)
    }

    /// Returns a tuple with an video recording device information `(id, name)`.
    pub fn get_device_name(&self, index: u32) -> (String, String) {
        let mut info = webrtc::get_video_device_name(&self.0, index);
        (info.pop().unwrap(), info.pop().unwrap())
    }
}
