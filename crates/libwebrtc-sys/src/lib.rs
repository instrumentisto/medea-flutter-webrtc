#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use std::os::raw::c_char;

use anyhow::bail;
use cxx::{let_cxx_string, UniquePtr};

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

    pub fn create_null() -> Self {
        Self(webrtc::create_audio_device_module_null())
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

pub struct AudioEncoderFactory(UniquePtr<webrtc::AudioEncoderFactory>);

impl Default for AudioEncoderFactory {
    fn default() -> Self {
        AudioEncoderFactory(webrtc::create_builtin_audio_encoder_factory())
    }
}

pub struct AudioDecoderFactory(UniquePtr<webrtc::AudioDecoderFactory>);

impl Default for AudioDecoderFactory {
    fn default() -> Self {
        AudioDecoderFactory(webrtc::create_builtin_audio_decoder_factory())
    }
}

pub struct VideoEncoderFactory(UniquePtr<webrtc::VideoEncoderFactory>);

impl Default for VideoEncoderFactory {
    fn default() -> Self {
        VideoEncoderFactory(webrtc::create_builtin_video_encoder_factory())
    }
}

pub struct VideoDecoderFactory(UniquePtr<webrtc::VideoDecoderFactory>);

impl Default for VideoDecoderFactory {
    fn default() -> Self {
        VideoDecoderFactory(webrtc::create_builtin_video_decoder_factory())
    }
}

pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    pub fn create() -> Self {
        Thread(webrtc::create_thread())
    }

    pub fn start(&mut self) {
        webrtc::start_thread(self.0.pin_mut());
    }
}

pub struct AudioMixer(UniquePtr<webrtc::AudioMixer>);

impl AudioMixer {
    pub fn create_null() -> Self {
        Self(webrtc::create_audio_mixer_null())
    }
}

pub struct AudioProcessing(UniquePtr<webrtc::AudioProcessing>);

impl AudioProcessing {
    pub fn create_null() -> Self {
        Self(webrtc::create_audio_processing_null())
    }
}

pub struct AudioFrameProcessor(UniquePtr<webrtc::AudioFrameProcessor>);

impl AudioFrameProcessor {
    pub fn create_null() -> Self {
        Self(webrtc::create_audio_frame_processor_null())
    }
}

pub struct RTCConfiguration(UniquePtr<webrtc::RTCConfiguration>);

impl Default for RTCConfiguration {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_configuration())
    }
}

pub struct RTCError(UniquePtr<webrtc::RTCError>);

impl RTCError {
    pub fn message(&mut self) -> *const c_char {
        webrtc::rtc_error_or_message(self.0.pin_mut())
    }
}

pub struct MyObserver(UniquePtr<webrtc::MyObserver>);

impl Default for MyObserver {
    fn default() -> Self {
        Self(webrtc::create_my_observer())
    }
}

pub struct PeerConnectionDependencies(
    UniquePtr<webrtc::PeerConnectionDependencies>,
);

impl Default for PeerConnectionDependencies {
    fn default() -> Self {
        Self(webrtc::create_peer_connection_dependencies(
            MyObserver::default().0,
        ))
    }
}

pub struct RTCOfferAnswerOptions(UniquePtr<webrtc::RTCOfferAnswerOptions>);

impl Default for RTCOfferAnswerOptions {
    fn default() -> Self {
        RTCOfferAnswerOptions(webrtc::create_default_rtc_offer_answer_options())
    }
}

pub struct SessionDescriptionInterface(
    UniquePtr<webrtc::SessionDescriptionInterface>,
);

impl SessionDescriptionInterface {
    pub fn new(type_: webrtc::SdpType, sdp: &str) -> Self {
        let_cxx_string!(n_sdp = sdp);
        SessionDescriptionInterface(unsafe {
            webrtc::create_session_description(type_, &n_sdp)
        })
    }
}

pub struct PeerConnectionInterface(UniquePtr<webrtc::PeerConnectionInterface>);

impl PeerConnectionInterface {
    pub fn create_offer(self, options: RTCOfferAnswerOptions) {
        unsafe { webrtc::create_offer(self.0.into_raw(), &options.0) }
    }

    pub fn create_answer(self, options: RTCOfferAnswerOptions) {
        unsafe { webrtc::create_answer(self.0.into_raw(), &options.0) }
    }

    pub fn set_local_description(self, desc: SessionDescriptionInterface) {
        unsafe { webrtc::set_local_description(self.0.into_raw(), desc.0) }
    }

    pub fn set_remote_description(self, desc: SessionDescriptionInterface) {
        unsafe { webrtc::set_remote_description(self.0.into_raw(), desc.0) }
    }
}

pub struct RTCErrorOr(UniquePtr<webrtc::RTCErrorOr>);

impl RTCErrorOr {
    pub fn ok(&mut self) -> bool {
        webrtc::rtc_error_or_is_ok(self.0.pin_mut())
    }

    pub fn error(&mut self) -> RTCError {
        RTCError(webrtc::move_error(self.0.pin_mut()))
    }

    pub fn value(&mut self) -> PeerConnectionInterface {
        PeerConnectionInterface(webrtc::move_value(self.0.pin_mut()))
    }
}

pub struct PeerConnectionFactoryInterface(
    UniquePtr<webrtc::PeerConnectionFactoryInterface>,
);

impl PeerConnectionFactoryInterface {
    pub fn create_whith_null() -> Self {
        let mut thread = Thread::create();
        thread.start();
        let thread_ptr = thread.0.into_raw();
        Self(unsafe {
            webrtc::create_peer_connection_factory(
                thread_ptr.clone(),
                thread_ptr.clone(),
                thread_ptr,
                AudioDeviceModule::create_null().0.into_raw(),
                AudioEncoderFactory::default().0.pin_mut(),
                AudioDecoderFactory::default().0.pin_mut(),
                VideoEncoderFactory::default().0,
                VideoDecoderFactory::default().0,
                AudioMixer::create_null().0.into_raw(),
                AudioProcessing::create_null().0.into_raw(),
                AudioFrameProcessor::create_null().0.into_raw(),
            )
        })
    }

    pub fn create_peer_connection_or_error(
        &mut self,
        configuration: RTCConfiguration,
        dependencies: PeerConnectionDependencies,
    ) -> RTCErrorOr {
        RTCErrorOr(webrtc::create_peer_connection_or_error(
            self.0.pin_mut(),
            &configuration.0,
            dependencies.0,
        ))
    }
}

#[cfg(test)]
mod test {
    use crate::bridge::webrtc::*;
    use cxx::{let_cxx_string, CxxString, UniquePtr};
    use std::ffi::CStr;

    #[test]
    fn video_encode_decode_factory() {
        let ve = create_builtin_video_encoder_factory();
        let vd = create_builtin_video_decoder_factory();
    }

    #[test]
    fn audio_encode_decode_factory() {
        let ae = create_builtin_audio_decoder_factory();
        let ad = create_builtin_audio_encoder_factory();
    }

    #[test]
    fn thread() {
        let mut thread = create_thread();
        let run = start_thread(thread.pin_mut());
        assert!(run)
    }

    #[test]
    fn create_peer_connection_factory_test() {
        pcf();
    }

    #[test]
    fn create_default_rtc() {
        let rtc_config = create_default_rtc_configuration();
    }

    #[test]
    fn create_myobserver() {
        let obs = create_my_observer();
    }

    #[test]
    fn create_peer_connection_dependencies_test() {
        let obs = create_my_observer();
        let pcd = create_peer_connection_dependencies(obs);
    }

    fn pcf() -> UniquePtr<PeerConnectionFactoryInterface> {
        let mut thread = create_thread();
        start_thread(thread.pin_mut());
        let thread = thread.into_raw();

        let ve = create_builtin_video_encoder_factory();
        let vd = create_builtin_video_decoder_factory();
        let mut ae = create_builtin_audio_encoder_factory();
        let mut ad = create_builtin_audio_decoder_factory();

        let afp = create_audio_frame_processor_null();
        let default_adm = create_audio_device_module_null();
        let am = create_audio_mixer_null();
        let ap = create_audio_processing_null();

        let mut pcf = unsafe {
            create_peer_connection_factory(
                thread.clone(),
                thread.clone(),
                thread,
                default_adm.into_raw(),
                ae.pin_mut(),
                ad.pin_mut(),
                ve,
                vd,
                am.into_raw(),
                ap.into_raw(),
                afp.into_raw(),
            )
        };
        pcf
    }

    fn pcoe() -> UniquePtr<RTCErrorOr> {
        let mut pcf = pcf();
        let obs = create_my_observer();
        let pcd = create_peer_connection_dependencies(obs);
        let rtc_config = create_default_rtc_configuration();

        let mut pc = {
            create_peer_connection_or_error(pcf.pin_mut(), &rtc_config, pcd)
        };
        pc
    }

    #[test]
    fn create_peer_connection_or_error_test() {
        let mut pc = pcoe();
        assert!(rtc_error_or_is_ok(pc.pin_mut()));
    }

    //#[test]
    fn create_peer_connection_error_test() {
        let mut pc = pcoe();

        let mut err = move_error(pc.pin_mut());
        let message = rtc_error_or_message(err.pin_mut());
        let cstr = unsafe { CStr::from_ptr(message) };

        println!("{:?}", cstr);
    }

    fn pc() -> UniquePtr<PeerConnectionInterface> {
        let mut pc = pcoe();
        move_value(pc.pin_mut())
    }

    #[test]
    fn get_peer_connection_test() {
        pc();
    }

    #[test]
    fn create_offer_test() {
        let options = create_default_rtc_offer_answer_options();
        let mut pc = pc();

        unsafe { create_offer(pc.into_raw(), &options) };
    }

    #[test]
    fn create_answer_test() {
        let options = create_default_rtc_offer_answer_options();
        let mut pc = pc();

        unsafe { create_answer(pc.into_raw(), &options) };
    }

    #[test]
    fn create_session_description_test() {
        let type_ = SdpType::kAnswer;
        let_cxx_string!(sdp = "test");
        let des = unsafe { create_session_description(type_, &sdp) };
    }

    #[test]
    fn set_local_description_test() {
        let type_ = SdpType::kAnswer;
        let_cxx_string!(sdp = "test");
        let des = unsafe { create_session_description(type_, &sdp) };
        let pc = pc();
        unsafe {
            set_local_description(pc.into_raw(), des);
        }
    }

    #[test]
    fn set_remote_description_test() {
        let type_ = SdpType::kAnswer;
        let_cxx_string!(sdp = "test");
        let des = unsafe { create_session_description(type_, &sdp) };
        let pc = pc();
        unsafe {
            set_remote_description(pc.into_raw(), des);
        }
    }
}
