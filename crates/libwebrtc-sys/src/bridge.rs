#[cxx::bridge(namespace = "bridge")]
pub(crate) mod webrtc {
    struct DeviceName {
        name: String,
        guid: String,
    }

    #[repr(i32)]
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

    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type TaskQueueFactory;

        /// Creates default libwebrtc [Task Queue Factory].
        ///
        /// [Task Queue Factory]: https://tinyurl.com/doc-threads
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory()
            -> UniquePtr<TaskQueueFactory>;
    }

    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type AudioDeviceModule;
        type AudioLayer;

        /// Creates libwebrtc [Audio Device Module] with default Windows layout.
        ///
        /// [Audio Device Module]: https://tinyurl.com/doc-adm
        pub fn create_audio_device_module(
            audio_layer: AudioLayer,
            task_queue_factory: &UniquePtr<TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        /// Initializes libwebrtc [Audio Device Module].
        ///
        /// [Audio Device Module]: https://tinyurl.com/doc-adm
        pub fn init_audio_device_module(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        );

        /// Returns count of audio playout devices.
        pub fn playout_devices(
            audio_device_module: &UniquePtr<AudioDeviceModule>,
        ) -> i16;

        /// Returns count of audio recording devices.
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
    }

    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type VideoDeviceInfo;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        pub fn number_of_video_devices(
            device_info: &UniquePtr<VideoDeviceInfo>,
        ) -> u32;

        pub fn get_video_device_name(
            device_info: &UniquePtr<VideoDeviceInfo>,
            index: u32,
        ) -> Vec<String>;
    }
}

#[cfg(test)]
mod test {
    #[test]
    fn init_audio_device_module() {}
}
