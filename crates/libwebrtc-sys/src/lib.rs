#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use anyhow::bail;
use cxx::{let_cxx_string, CxxString, UniquePtr};

use self::bridge::webrtc;

pub use webrtc::{AudioLayer, SdpType};

/// Thread safe task queue factory internally used in [`WebRTC`] that is capable
/// of creating [Task Queue]s.
///
/// [`WebRTC`]: https://webrtc.googlesource.com/src
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

    /// Sets the recording audio device according to the given `index`.
    pub fn set_recording_device(&self, index: u16) -> anyhow::Result<()> {
        let result = webrtc::set_audio_recording_device(&self.0, index);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::SetRecordingDevice()` failed with \
                 `{}` code.",
                result,
            );
        }

        Ok(())
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

/// A factory that creates [`AudioEncoder`]s.
pub struct AudioEncoderFactory(UniquePtr<webrtc::AudioEncoderFactory>);

impl Default for AudioEncoderFactory {
    /// Creates a new [Builtin] [`AudioEncoderFactory`]
    fn default() -> Self {
        AudioEncoderFactory(webrtc::create_builtin_audio_encoder_factory())
    }
}

/// A factory that creates [`AudioDecoder`]s.
pub struct AudioDecoderFactory(UniquePtr<webrtc::AudioDecoderFactory>);

impl Default for AudioDecoderFactory {
    /// Creates a new [Builtin] [`AudioDecoderFactory`]
    fn default() -> Self {
        AudioDecoderFactory(webrtc::create_builtin_audio_decoder_factory())
    }
}

/// A factory that creates [`VideoEncoder`]s.
pub struct VideoEncoderFactory(UniquePtr<webrtc::VideoEncoderFactory>);

impl Default for VideoEncoderFactory {
    /// Creates a new [Builtin] [`VideoEncoderFactory`]
    fn default() -> Self {
        VideoEncoderFactory(webrtc::create_builtin_video_encoder_factory())
    }
}

/// A factory that creates [`VideoDecoder`]s.
pub struct VideoDecoderFactory(UniquePtr<webrtc::VideoDecoderFactory>);

impl Default for VideoDecoderFactory {
    /// Creates a new [Builtin] [`VideoDecoderFactory`]
    fn default() -> Self {
        VideoDecoderFactory(webrtc::create_builtin_video_decoder_factory())
    }
}

/// Webrtc audio mixer.
pub struct AudioMixer(UniquePtr<webrtc::AudioMixer>);

/// The Audio Processing Module (APM) provides a collection of voice processing
/// components designed for real-time communications software.
///
/// APM operates on two audio streams on a frame-by-frame basis. Frames of the
/// primary stream, on which all processing is applied, are passed to
/// `ProcessStream()`. Frames of the reverse direction stream are passed to
/// `ProcessReverseStream()`. On the client-side, this will typically be the
/// near-end (capture) and far-end (render) streams, respectively. APM should be
/// placed in the signal chain as close to the audio hardware abstraction layer
/// (HAL) as possible.
///
/// On the server-side, the reverse stream will normally not be used, with
/// processing occurring on each incoming stream.
///
/// Component interfaces follow a similar pattern and are accessed through
/// corresponding getters in APM. All components are disabled at create-time,
/// with default settings that are recommended for most situations. New settings
/// can be applied without enabling a component. Enabling a component triggers
/// memory allocation and initialization to allow it to start processing the
/// streams.
pub struct AudioProcessing(UniquePtr<webrtc::AudioProcessing>);

/// Audio frame processor. If passed into `PeerConnectionFactory`,
/// will be used for additional
/// processing of captured audio frames, performed before encoding.
/// # Warning
/// Implementations must be thread-safe.
pub struct AudioFrameProcessor(UniquePtr<webrtc::AudioFrameProcessor>);

/// RTCConfiguration used for creating [`PeerConnectionInterface`]
pub struct RTCConfiguration(UniquePtr<webrtc::RTCConfiguration>);

impl Default for RTCConfiguration {
    /// Create default [`RTCConfiguration`]
    fn default() -> Self {
        Self(webrtc::create_default_rtc_configuration())
    }
}

/// `PeerConnectionObserver` used for calling callback RTCPeerConnection events.
pub struct PeerConnectionObserver(UniquePtr<webrtc::PeerConnectionObserver>);

impl PeerConnectionObserver {
    /// Creates default [`PeerConnectionObserver`] without handle events
    fn new(e: fn(&CxxString)) -> Self {
        Self(webrtc::create_peer_connection_observer(e))
    }
}

/// `PeerConnectionDependencies` holds all of `PeerConnections` dependencies.
/// A dependency is distinct from a configuration as it defines significant
/// executable code that can be provided by a user of the API.
pub struct PeerConnectionDependencies(
    UniquePtr<webrtc::PeerConnectionDependencies>,
);

impl PeerConnectionDependencies {
    /// Creates a [`PeerConnectionDependencies`]
    /// whith default [`PeerConnectionObserver`]
    pub fn new(e: fn(&CxxString)) -> Self {
        Self(webrtc::create_peer_connection_dependencies(
            PeerConnectionObserver::new(e).0,
        ))
    }
}

/// `RTCOfferAnswerOptions` used for create [Offer]s, [Answer]s.
pub struct RTCOfferAnswerOptions(pub UniquePtr<webrtc::RTCOfferAnswerOptions>);

impl Default for RTCOfferAnswerOptions {
    /// Creates a [`RTCOfferAnswerOptions`]
    /// whith `voice_activity_detection` = true,
    /// `ice_restart` = false,
    /// `use_rtp_mux` = true,
    /// `receive_audio` = true,
    /// `receive_video` = true,
    fn default() -> Self {
        RTCOfferAnswerOptions(webrtc::create_default_rtc_offer_answer_options())
    }
}

impl RTCOfferAnswerOptions {
    /// Creates a new [`RTCOfferAnswerOptions`]
    #[must_use]
    pub fn new(
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) -> Self {
        RTCOfferAnswerOptions(webrtc::create_rtc_offer_answer_options(
            offer_to_receive_video,
            offer_to_receive_audio,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        ))
    }
}

/// `SessionDescription` interface describes one
/// end of a connection—or potential connection—and
/// how it's configured.
/// Each `SessionDescription` consists of a description type
/// indicating which part of the offer/answer
/// negotiation process it describes and of
/// the SDP descriptor of the session.
pub struct SessionDescriptionInterface(
    UniquePtr<webrtc::SessionDescriptionInterface>,
);

impl SessionDescriptionInterface {
    /// Create new [`SessionDescriptionInterface`]
    #[must_use]
    pub fn new(type_: webrtc::SdpType, sdp: &str) -> Self {
        let_cxx_string!(n_sdp = sdp);
        SessionDescriptionInterface(webrtc::create_session_description(
            type_, &n_sdp,
        ))
    }
}

/// Create Session Description Observer used
/// for calling callback when create [Offer] or [Answer]
/// success or fail.
pub struct CreateSessionDescriptionObserver(
    pub UniquePtr<webrtc::CreateSessionDescriptionObserver>,
);

impl CreateSessionDescriptionObserver {
    /// Creates a [`CreateSessionDescriptionObserver`].
    /// Where
    /// `success` for callback when 'CreateOffer\Answer' is success,
    /// `fail` for callback when 'CreateOffer\Answer' is fail.
    #[must_use]
    pub fn new(
        success: fn(&CxxString, &CxxString),
        fail: fn(&CxxString),
    ) -> Self {
        Self(webrtc::create_create_session_observer(success, fail))
    }
}

pub struct SetLocalDescriptionObserverInterface(
    UniquePtr<webrtc::SetLocalDescriptionObserverInterface>,
);

impl SetLocalDescriptionObserverInterface {
    #[must_use]
    pub fn new(success: fn(), fail: fn(&CxxString)) -> Self {
        Self(webrtc::create_set_local_description_observer_interface(
            success, fail,
        ))
    }
}

pub struct SetRemoteDescriptionObserverInterface(
    UniquePtr<webrtc::SetRemoteDescriptionObserverInterface>,
);

impl SetRemoteDescriptionObserverInterface {
    pub fn new(success: fn(), fail: fn(&CxxString)) -> Self {
        Self(webrtc::create_set_remote_description_observer_interface(
            success, fail,
        ))
    }
}

/// Peer Connection Interface internally used in [`webrtc`] that is
/// capable of creating [Offer]s, [Answer]s
/// and setting [Remote], [Local] Description.
pub struct PeerConnectionInterface(UniquePtr<webrtc::PeerConnectionInterface>);

impl PeerConnectionInterface {
    /// Create a new offer.
    /// The [`CreateSessionDescriptionObserver`]
    /// callback will be called when done.
    /// # Panic
    /// Panic if `self` - PeerConnectionInterface(null)
    /// Panic if obs is not init
    pub fn create_offer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_offer(self.0.pin_mut(), &options.0, obs.0);
    }

    /// Create a new answer.
    /// The [`CreateSessionDescriptionObserver`]
    /// callback will be called when done.
    /// # Warning
    /// Can't be create before offer.
    /// # Panic
    /// Panic if `self` - PeerConnectionInterface(null)
    pub fn create_answer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_answer(self.0.pin_mut(), &options.0, obs.0);
    }

    /// Sets the local session description.
    /// According to spec, the local session description MUST be the same as was
    /// returned by `CreateOffer` or `CreateAnswer` or else the operation should
    /// fail. The observer is invoked as soon as
    /// the operation completes, which could be
    /// before or after the `SetLocalDescription` method has exited.
    /// # Panic
    /// Panic if `self` - `PeerConnectionInterface`(null)
    pub fn set_local_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetLocalDescriptionObserverInterface,
    ) {
        webrtc::set_local_description(self.0.pin_mut(), desc.0, obs.0);
    }

    /// Sets the remote session description.
    /// The observer is invoked as soon as
    /// the operation completes, which could be
    /// before or after the `SetRemoteDescription` method has exited.
    /// # Panic
    /// Panic if `self` - `PeerConnectionInterface`(null)
    pub fn set_remote_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetRemoteDescriptionObserverInterface,
    ) {
        webrtc::set_remote_description(self.0.pin_mut(), desc.0, obs.0);
    }
}

/// Interface for using an RTC [`Thread`][1].
///
/// [1]: https://tinyurl.com/doc-threads
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a new [`Thread`].
    pub fn create() -> anyhow::Result<Self> {
        let ptr = webrtc::create_thread();

        if ptr.is_null() {
            bail!("`null` pointer returned from `rtc::Thread::Create()`");
        }
        Ok(Self(ptr))
    }

    /// Starts the [`Thread`].
    pub fn start(&mut self) -> anyhow::Result<()> {
        if !self.0.pin_mut().start_thread() {
            bail!("`rtc::Thread::Start()` failed");
        }
        Ok(())
    }
}

/// [`PeerConnectionFactoryInterface`] is the main entry point to the
/// `PeerConnection API` for clients it is responsible for creating
/// [`AudioSourceInterface`], tracks ([`VideoTrackInterface`],
/// [`AudioTrackInterface`]), [`MediaStreamInterface`] and the
/// `PeerConnection`s.
pub struct PeerConnectionFactoryInterface(
    UniquePtr<webrtc::PeerConnectionFactoryInterface>,
);

impl PeerConnectionFactoryInterface {
    /// Creates a [`PeerConnectionFactoryInterface`] whith default
    /// [`AudioEncoderFactory`], [`AudioDecoderFactory`],
    /// [`VideoEncoderFactory`], [`VideoDecoderFactory`],
    /// one new [`Thread`] for `network_thread`, `worker_thread`,
    /// `signaling_thread`.
    /// `default_adm` - NULL, `audio_mixer` - NULL, `audio_processing` - NULL,
    /// `audio_frame_processor` - NULL.
    #[must_use]
    pub fn create_whith_null(
        network_thread: Option<&Thread>,
        worker_thread: Option<&Thread>,
        signaling_thread: Option<&Thread>,
    ) -> Self {
        Self(webrtc::create_peer_connection_factory(
            network_thread.map_or(&UniquePtr::null(), |t| &t.0),
            worker_thread.map_or(&UniquePtr::null(), |t| &t.0),
            signaling_thread.map_or(&UniquePtr::null(), |t| &t.0),
            UniquePtr::null(),
            AudioEncoderFactory::default().0.pin_mut(),
            AudioDecoderFactory::default().0.pin_mut(),
            VideoEncoderFactory::default().0,
            VideoDecoderFactory::default().0,
            UniquePtr::null(),
            UniquePtr::null(),
            UniquePtr::null(),
        ))
    }

    /// Creates a [`PeerConnectionInterface`].
    /// Where `error` for error handle without c++ exception.
    ///
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be default or NULL.
    pub fn create_peer_connection_or_error(
        &mut self,
        error: &mut String,
        configuration: &RTCConfiguration,
        dependencies: PeerConnectionDependencies,
    ) -> PeerConnectionInterface {
        let res = webrtc::create_peer_connection_or_error(
            self.0.pin_mut(),
            error,
            &configuration.0,
            dependencies.0,
        );
        if error.is_empty() {
            PeerConnectionInterface(res)
        } else {
            PeerConnectionInterface(UniquePtr::null())
        }
    }

    /// Creates a new [`AudioSourceInterface`], which provides sound recording
    /// from native platform.
    pub fn create_audio_source(&self) -> anyhow::Result<AudioSourceInterface> {
        let ptr = webrtc::create_audio_source(&self.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioSource()`",
            );
        }
        Ok(AudioSourceInterface(ptr))
    }

    /// Creates a new [`VideoTrackInterface`] sourced by the provided
    /// [`VideoTrackSourceInterface`].
    pub fn create_video_track(
        &self,
        id: String,
        video_src: &VideoTrackSourceInterface,
    ) -> anyhow::Result<VideoTrackInterface> {
        let ptr = webrtc::create_video_track(&self.0, id, &video_src.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateVideoTrack()`",
            );
        }
        Ok(VideoTrackInterface(ptr))
    }

    /// Creates a new [`AudioTrackInterface`] sourced by the provided
    /// [`AudioSourceInterface`].
    pub fn create_audio_track(
        &self,
        id: String,
        audio_src: &AudioSourceInterface,
    ) -> anyhow::Result<AudioTrackInterface> {
        let ptr = webrtc::create_audio_track(&self.0, id, &audio_src.0);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioTrack()`",
            );
        }
        Ok(AudioTrackInterface(ptr))
    }

    /// Creates a new empty [`MediaStreamInterface`].
    pub fn create_local_media_stream(
        &self,
        id: String,
    ) -> anyhow::Result<MediaStreamInterface> {
        let ptr = webrtc::create_local_media_stream(&self.0, id);

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::\
                 CreateLocalMediaStream()`",
            );
        }
        Ok(MediaStreamInterface(ptr))
    }
}

/// [`VideoTrackSourceInterface`] captures data from the specific video input
/// device.
///
/// It can be later used to create a [`VideoTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_video_track()`].
pub struct VideoTrackSourceInterface(
    UniquePtr<webrtc::VideoTrackSourceInterface>,
);

impl VideoTrackSourceInterface {
    /// Creates a new [`VideoTrackSourceInterface`] with the specified
    /// constraints.
    ///
    /// The created capturer is wrapped in the `VideoTrackSourceProxy` that
    /// makes sure the real [`VideoTrackSourceInterface`] implementation is
    /// destroyed on the signaling thread and marshals all method calls to the
    /// signaling thread.
    pub fn create_proxy(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        width: usize,
        height: usize,
        fps: usize,
        device_index: u32,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_video_source(
            worker_thread.0.pin_mut(),
            signaling_thread.0.pin_mut(),
            width,
            height,
            fps,
            device_index,
        );

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreateVideoTrackSourceProxy()`",
            );
        }
        Ok(VideoTrackSourceInterface(ptr))
    }
}

/// [`VideoTrackSourceInterface`] captures data from the specific audio input
/// device.
///
/// It can be later used to create a [`AudioTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_audio_track()`].
pub struct AudioSourceInterface(UniquePtr<webrtc::AudioSourceInterface>);

/// Video [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct VideoTrackInterface(UniquePtr<webrtc::VideoTrackInterface>);

/// Audio [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct AudioTrackInterface(UniquePtr<webrtc::AudioTrackInterface>);

/// [`MediaStreamInterface`][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#mediastream
pub struct MediaStreamInterface(UniquePtr<webrtc::MediaStreamInterface>);

impl MediaStreamInterface {
    /// Adds the provided [`VideoTrackInterface`] to this
    /// [`MediaStreamInterface`].
    pub fn add_video_track(
        &self,
        track: &VideoTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::add_video_track(&self.0, &track.0);

        if !result {
            bail!("`webrtc::MediaStreamInterface::AddTrack()` failed");
        }
        Ok(())
    }

    /// Adds the provided  [`AudioTrackInterface`] to this
    /// [`MediaStreamInterface`].
    pub fn add_audio_track(
        &self,
        track: &AudioTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::add_audio_track(&self.0, &track.0);

        if !result {
            bail!("`webrtc::MediaStreamInterface::AddTrack()` failed");
        }
        Ok(())
    }

    /// Removes the provided [`VideoTrackInterface`] from this
    /// [`MediaStreamInterface`].
    pub fn remove_video_track(
        &self,
        track: &VideoTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::remove_video_track(&self.0, &track.0);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }

    /// Removes the provided [`AudioTrackInterface`] from this
    /// [`MediaStreamInterface`].
    pub fn remove_audio_track(
        &self,
        track: &AudioTrackInterface,
    ) -> anyhow::Result<()> {
        let result = webrtc::remove_audio_track(&self.0, &track.0);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }
}
