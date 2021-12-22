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

        /// Creates a default [TaskQueueFactory] based on the current platform
        /// capabilities.
        #[namespace = "webrtc"]
        #[cxx_name = "CreateDefaultTaskQueueFactory"]
        pub fn create_default_task_queue_factory()
            -> UniquePtr<TaskQueueFactory>;
    }

    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type AudioDeviceModule;
        type AudioLayer;

        /// Creates a default [AudioDeviceModule].
        pub fn create_audio_device_module(
            audio_layer: AudioLayer,
            task_queue_factory: Pin<&mut TaskQueueFactory>,
        ) -> UniquePtr<AudioDeviceModule>;

        /// Initializes current [AudioDeviceModule].
        pub fn init_audio_device_module(
            audio_device_module: &AudioDeviceModule,
        );

        /// Returns count of available audio playout devices.
        pub fn playout_devices(
            audio_device_module: &AudioDeviceModule,
        ) -> i16;

        /// Returns count of available audio recording devices.
        pub fn recording_devices(
            audio_device_module: &AudioDeviceModule,
        ) -> i16;

        /// Returns a tuple with an audio playout device information `(id, name)`.
        pub fn playout_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            guid: &mut String
        ) -> i32;

        pub fn recording_device_name(
            audio_device_module: &AudioDeviceModule,
            index: i16,
            name: &mut String,
            guid: &mut String
        ) -> i32;
    }

    unsafe extern "C++" {
        include!("libwebrtc-sys/include/bridge.h");

        type VideoDeviceInfo;

        pub fn create_video_device_info() -> UniquePtr<VideoDeviceInfo>;

        #[namespace = "webrtc"]
        #[cxx_name = "NumberOfDevices"]
        pub fn number_of_video_devices(
            self: Pin<&mut VideoDeviceInfo>,
        ) -> u32;

        pub fn video_device_name(
            device_info: Pin<&mut VideoDeviceInfo>,
            index: u32,
            name: &mut String,
            guid: &mut String
        ) -> i32;
    }
}

#[cfg(test)]
mod test {
    #[test]
    fn init_audio_device_module() {}
}
