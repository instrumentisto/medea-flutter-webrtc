#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use std::ops::{Deref, DerefMut};

use anyhow::bail;
use cxx::{let_cxx_string, UniquePtr};

use self::bridge::webrtc;

pub use crate::{
    bridge::{CreateSdpCallback, SetDescriptionCallback},
    webrtc::{AudioLayer, MediaType, RtpTransceiverDirection, SdpType},
};

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

impl Default for PeerConnectionObserver {
    /// Creates default [`PeerConnectionObserver`] without handle events
    fn default() -> Self {
        Self(webrtc::create_peer_connection_observer())
    }
}

/// `PeerConnectionDependencies` holds all of `PeerConnections` dependencies.
/// A dependency is distinct from a configuration as it defines significant
/// executable code that can be provided by a user of the API.
pub struct PeerConnectionDependencies(
    UniquePtr<webrtc::PeerConnectionDependencies>,
);

impl Default for PeerConnectionDependencies {
    /// Creates a [`PeerConnectionDependencies`]
    /// whith default [`PeerConnectionObserver`]
    fn default() -> Self {
        Self(webrtc::create_peer_connection_dependencies(
            PeerConnectionObserver::default().0,
        ))
    }
}

/// `RTCOfferAnswerOptions` used for create `Offer`s, `Answer`s.
pub struct RTCOfferAnswerOptions(UniquePtr<webrtc::RTCOfferAnswerOptions>);

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
        offer_to_receive_video: Option<bool>,
        offer_to_receive_audio: Option<bool>,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) -> Self {
        RTCOfferAnswerOptions(webrtc::create_rtc_offer_answer_options(
            offer_to_receive_video.map_or(-1, |f| if f { 1 } else { 0 }),
            offer_to_receive_audio.map_or(-1, |f| if f { 1 } else { 0 }),
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
        let_cxx_string!(cxx_sdp = sdp);
        SessionDescriptionInterface(webrtc::create_session_description(
            type_, &cxx_sdp,
        ))
    }
}

/// `CreateSessionDescriptionObserver` used
/// for calling callback when create `Offer` or `Answer`
/// success or fail.
pub struct CreateSessionDescriptionObserver(
    UniquePtr<webrtc::CreateSessionDescriptionObserver>,
);

impl CreateSessionDescriptionObserver {
    /// Creates a [`CreateSessionDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn CreateSdpCallback>) -> Self {
        Self(webrtc::create_create_session_observer(Box::new(cb)))
    }
}

/// `SetLocalDescriptionObserver` used
/// for calling callback when set local description is
/// success or fail.
pub struct SetLocalDescriptionObserver(
    UniquePtr<webrtc::SetLocalDescriptionObserver>,
);

impl SetLocalDescriptionObserver {
    /// Creates a [`SetLocalDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_local_description_observer(Box::new(cb)))
    }
}

/// `SetLocalDescriptionObserver` used
/// for calling callback when set remote description is
/// success or fail.
pub struct SetRemoteDescriptionObserver(
    UniquePtr<webrtc::SetRemoteDescriptionObserver>,
);

impl SetRemoteDescriptionObserver {
    /// Creates a [`SetRemoteDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_remote_description_observer(Box::new(cb)))
    }
}

/// A struct contains [`RTCRtpTransceiver`][1]'s information.
///
/// [1]: https://tinyurl.com/2p88ajym
pub struct Transceiver(UniquePtr<webrtc::RtpTransceiverInterface>);

impl Transceiver {
    /// Returns [`Transceiver`]'s `mid`.
    pub fn mid(&self) -> String {
        webrtc::get_transceiver_mid(&self.0)
    }

    // /// Returns [`Transceiver`]'s `direction`.
    // pub fn direction(&self) -> webrtc::RtpTransceiverDirection {
    //     &self
    // }
}

/// A struct contains a [`Vec`] of [`Transceiver`]s.
pub struct Transceivers(Box<Vec<Transceiver>>);

impl Transceivers {
    /// Adds a new [`Transceiver`].
    pub fn add(
        &mut self,
        transceiver: UniquePtr<webrtc::RtpTransceiverInterface>
    ) {
        self.0.push(Transceiver(transceiver));
    }
}

impl Deref for Transceivers {
    type Target = Vec<Transceiver>;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl DerefMut for Transceivers {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.0
    }
}

/// Creates a new `boxed` [`Transceivers`].
pub fn create_transceivers() -> Box<Transceivers> {
    Box::new(Transceivers(Box::new(Vec::new())))
}

/// Peer Connection Interface internally used in `Webrtc` that is
/// capable of creating `Offer`s, `Answer`s
/// and setting `Remote`, `Local` Description.
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
        obs: SetLocalDescriptionObserver,
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
        obs: SetRemoteDescriptionObserver,
    ) {
        webrtc::set_remote_description(self.0.pin_mut(), desc.0, obs.0);
    }

    /// Adds a new [`RTCRtpTransceiver`][1] to some
    /// [`PeerConnectionInterface`]. The [`RTCRtpTransceiver`][1]
    /// interface represents a combination of an `RTCRtpSender` and an `RTCRtpReceiver`.
    ///
    /// [1]: https://tinyurl.com/2p88ajym
    pub fn add_transceiver(
        &mut self,
        media_type: MediaType,
        direction: RtpTransceiverDirection,
    ) -> Transceiver {
        Transceiver(webrtc::add_transceiver(self.0.pin_mut(), media_type, direction))
    }

    /// Gets information about [`PeerConnectionInterface`]'s [`Transceiver`]s.
    #[must_use]
    pub fn get_transceivers(&self) -> Box<Transceivers> {
        webrtc::get_transceivers(&self.0)
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
    #[must_use]
    pub fn create(
        network_thread: Option<&Thread>,
        worker_thread: Option<&Thread>,
        signaling_thread: Option<&Thread>,
        default_adm: Option<&AudioDeviceModule>,
    ) -> Self {
        Self(webrtc::create_peer_connection_factory(
            network_thread.map_or(&UniquePtr::null(), |t| &t.0),
            worker_thread.map_or(&UniquePtr::null(), |t| &t.0),
            signaling_thread.map_or(&UniquePtr::null(), |t| &t.0),
            default_adm.map_or(&UniquePtr::null(), |t| &t.0),
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
        configuration: &RTCConfiguration,
        dependencies: PeerConnectionDependencies,
    ) -> anyhow::Result<PeerConnectionInterface> {
        let mut error = String::new();
        let pc = webrtc::create_peer_connection_or_error(
            self.0.pin_mut(),
            &configuration.0,
            dependencies.0,
            &mut error,
        );
        if error.is_empty() {
            Ok(PeerConnectionInterface(pc))
        } else {
            bail!(error);
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

pub fn testsk(pc: &mut PeerConnectionInterface) {
    webrtc::ustest(pc.0.as_ref().unwrap());
}
