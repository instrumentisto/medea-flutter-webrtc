#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]

mod bridge;

use std::{collections::HashMap, convert::TryFrom, mem};

use anyhow::{anyhow, bail};
use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};
use derive_more::From;

use self::bridge::webrtc;

pub use crate::webrtc::{
    candidate_to_string, get_candidate_pair,
    get_estimated_disconnected_time_ms, get_last_data_received_ms, get_reason,
    video_frame_to_abgr, video_frame_to_argb, AudioLayer, BundlePolicy,
    Candidate, CandidatePairChangeEvent, CandidateType, IceConnectionState,
    IceGatheringState, IceTransportsType, MediaType, PeerConnectionState,
    RTCStatsIceCandidatePairState, RtpTransceiverDirection, SdpType,
    SignalingState, TrackState, VideoFrame, VideoRotation,
};

/// Handler of events firing from a [`MediaStreamTrackInterface`].
pub trait TrackEventCallback {
    /// Called when an [`ended`][1] event occurs in the attached
    /// [`MediaStreamTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#event-mediastreamtrack-ended
    fn on_ended(&mut self);
}

/// Completion callback for a [`CreateSessionDescriptionObserver`], used to call
/// [`PeerConnectionInterface::create_offer()`] and
/// [`PeerConnectionInterface::create_answer()`].
pub trait CreateSdpCallback {
    /// Called when the related operation is successfully completed.
    fn success(&mut self, sdp: &CxxString, kind: webrtc::SdpType);

    /// Called when the related operation is completed with the `error`.
    fn fail(&mut self, error: &CxxString);
}

/// Completion callback for a [`SetLocalDescriptionObserver`] and
/// [`SetRemoteDescriptionObserver`], used to call
/// [`PeerConnectionInterface::set_local_description()`] and
/// [`PeerConnectionInterface::set_remote_description()`].
pub trait SetDescriptionCallback {
    /// Called when the related operation is successfully completed.
    fn success(&mut self);

    /// Called when the related operation is completed with the `error`.
    fn fail(&mut self, error: &CxxString);
}

/// Handler of [`VideoFrame`]s.
pub trait OnFrameCallback {
    /// Called when the attached [`VideoTrackInterface`] produces a new
    /// [`VideoFrame`].
    fn on_frame(&mut self, frame: UniquePtr<VideoFrame>);
}

/// Handler of [`VideoFrame`]s.
pub trait RTCStatsCollectorCallback {
    fn on_stats_delivered(&mut self, report: RtcStatsReport);
}

/// Handler of events that fire from a [`PeerConnectionInterface`].
pub trait PeerConnectionEventsHandler {
    /// Called when a [`signalingstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-signalingstatechange
    fn on_signaling_change(&mut self, new_state: SignalingState);

    /// Called when an [`iceconnectionstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-iceconnectionstatechange
    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: IceConnectionState,
    );

    /// Called when a [`connectionstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-connectionstatechange
    fn on_connection_change(&mut self, new_state: PeerConnectionState);

    /// Called when an [`icegatheringstatechange`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icegatheringstatechange
    fn on_ice_gathering_change(&mut self, new_state: IceGatheringState);

    /// Called when a [`negotiation`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-negotiation
    fn on_negotiation_needed_event(&mut self, event_id: u32);

    /// Called when an [`icecandidateerror`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icecandidateerror
    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    );

    /// Called when the ICE connection receiving status changes.
    fn on_ice_connection_receiving_change(&mut self, receiving: bool);

    /// Called when an [`icecandidate`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-icecandidate
    fn on_ice_candidate(&mut self, candidate: IceCandidateInterface);

    /// Called when some ICE candidates have been removed.
    fn on_ice_candidates_removed(&mut self, candidates: &CxxVector<Candidate>);

    /// Called when a [`selectedcandidatepairchange`][1] event occurs.
    ///
    /// [1]: https://tinyurl.com/w3-selectedcandidatepairchange
    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        event: &CandidatePairChangeEvent,
    );

    /// Called when a [`track`][1] event occurs.
    ///
    /// [1]: https://w3.org/TR/webrtc#event-track
    fn on_track(&mut self, transceiver: RtpTransceiverInterface);

    /// Called when signaling indicates that media will no longer be received on
    /// a track.
    ///
    /// With "Unified Plan" semantics, the receiver will remain but the
    /// transceiver will have changed its direction to either `sendonly` or
    /// `inactive`.
    fn on_remove_track(&mut self, receiver: RtpReceiverInterface);
}

/// [MediaStreamTrack.kind][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dfn-kind
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum TrackKind {
    Audio,
    Video,
}

impl TryFrom<&str> for TrackKind {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "audio" => Ok(Self::Audio),
            "video" => Ok(Self::Video),
            kind => Err(anyhow!("Unknown kind: {kind}")),
        }
    }
}

/// Completion callback for the [`PeerConnectionInterface::add_ice_candidate()`]
/// function.
pub trait AddIceCandidateCallback {
    /// Called when the operation is successfully completed.
    fn on_success(&mut self);

    /// Called when the operation fails with the `error`.
    fn on_fail(&mut self, error: &CxxString);
}

/// Thread safe task queue factory internally used in [`WebRtc`] that is capable
/// of creating [Task Queue]s.
///
/// [`WebRtc`]: https://webrtc.googlesource.com/src
/// [Task Queue]: https://tinyurl.com/doc-threads
pub struct TaskQueueFactory(UniquePtr<webrtc::TaskQueueFactory>);

impl TaskQueueFactory {
    /// Creates a default [`TaskQueueFactory`] based on the current platform.
    #[must_use]
    pub fn create_default_task_queue_factory() -> Self {
        Self(webrtc::create_default_task_queue_factory())
    }
}

unsafe impl Send for webrtc::TaskQueueFactory {}
unsafe impl Sync for webrtc::TaskQueueFactory {}

/// Available audio devices manager that is responsible for driving input
/// (microphone) and output (speaker) audio in `WebRtc`.
///
/// Backed by `WebRtc`'s [Audio Device Module].
///
/// [Audio Device Module]: https://tinyurl.com/doc-adm
pub struct AudioDeviceModule(UniquePtr<webrtc::AudioDeviceModule>);

impl AudioDeviceModule {
    /// Creates a new [`AudioDeviceModule`] for the given [`AudioLayer`].
    ///
    /// All invocations will be proxied to the provided `worker_thred`, thus
    /// making it thread-safe.
    pub fn create_proxy(
        worker_thread: &mut Thread,
        audio_layer: AudioLayer,
        task_queue_factory: &mut TaskQueueFactory,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_audio_device_module(
            worker_thread.0.pin_mut(),
            audio_layer,
            task_queue_factory.0.pin_mut(),
        );

        if ptr.is_null() {
            bail!("`null` pointer returned from `AudioDeviceModule::Create()`");
        }
        Ok(Self(ptr))
    }

    /// Creates a new fake [`AudioDeviceModule`], that will not try to access
    /// real media devices, but will generate pulsed noise.
    pub fn create_fake(task_queue_factory: &mut TaskQueueFactory) -> Self {
        Self(webrtc::create_fake_audio_device_module(
            task_queue_factory.0.pin_mut(),
        ))
    }

    /// Initializes the current [`AudioDeviceModule`].
    pub fn init(&self) -> anyhow::Result<()> {
        let result = webrtc::init_audio_device_module(&self.0);
        if result != 0 {
            bail!("`AudioDeviceModule::Init()` failed with `{result}` code");
        }
        Ok(())
    }

    /// Returns count of available audio playout devices.
    #[must_use]
    #[allow(clippy::cast_sign_loss)]
    pub fn playout_devices(&self) -> u32 {
        webrtc::playout_devices(&self.0).max(0) as u32
    }

    /// Returns count of available audio recording devices.
    #[must_use]
    #[allow(clippy::cast_sign_loss)]
    pub fn recording_devices(&self) -> u32 {
        webrtc::recording_devices(&self.0).max(0) as u32
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
                "`AudioDeviceModule::PlayoutDeviceName()` failed with \
                 `{result}` code",
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
                 `{result}` code",
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
                 `{result}` code",
            );
        }

        Ok(())
    }

    /// Sets the playout audio device according to the given `index`.
    pub fn set_playout_device(&self, index: u16) -> anyhow::Result<()> {
        let result = webrtc::set_audio_playout_device(&self.0, index);

        if result != 0 {
            bail!(
                "`AudioDeviceModule::SetPlayoutDevice()` failed with \
                 `{result}` code",
            );
        }

        Ok(())
    }

    /// Initializes the microphone in the [`AudioDeviceModule`].
    pub fn init_microphone(&self) -> anyhow::Result<()> {
        let result = webrtc::init_microphone(&self.0);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::InitMicrophone()` failed with `{result}` \
                 code",
            );
        }

        Ok(())
    }

    /// Indicates whether the microphone of the [`AudioDeviceModule`] is
    /// initialized.
    #[must_use]
    pub fn microphone_is_initialized(&self) -> bool {
        webrtc::microphone_is_initialized(&self.0)
    }

    /// Sets the volume of the initialized microphone.
    pub fn set_microphone_volume(&self, volume: u32) -> anyhow::Result<()> {
        let result = webrtc::set_microphone_volume(&self.0, volume);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::SetMicrophoneVolume()` failed with \
                 `{result}` code",
            );
        }

        Ok(())
    }

    /// Indicates whether the microphone is available to set volume.
    pub fn microphone_volume_is_available(&self) -> anyhow::Result<bool> {
        let mut is_available = false;

        let result =
            webrtc::microphone_volume_is_available(&self.0, &mut is_available);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::MicrophoneVolumeIsAvailable()` failed \
                 with `{result}` code",
            );
        }

        Ok(is_available)
    }

    /// Returns the lowest possible level of the microphone volume.
    pub fn min_microphone_volume(&self) -> anyhow::Result<u32> {
        let mut volume = 0;

        let result = webrtc::min_microphone_volume(&self.0, &mut volume);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::MinMicrophoneVolume()` failed with \
                 `{result}` code",
            );
        }

        Ok(volume)
    }

    /// Returns the highest possible level of the microphone volume.
    pub fn max_microphone_volume(&self) -> anyhow::Result<u32> {
        let mut volume = 0;

        let result = webrtc::max_microphone_volume(&self.0, &mut volume);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::MaxMicrophoneVolume()` failed with \
                 `{result}` code",
            );
        }

        Ok(volume)
    }

    /// Returns the current level of the microphone volume.
    pub fn microphone_volume(&self) -> anyhow::Result<u32> {
        let mut volume = 0;

        let result = webrtc::microphone_volume(&self.0, &mut volume);
        if result != 0 {
            bail!(
                "`AudioDeviceModule::MicrophoneVolume()` failed with \
                 `{result}` code",
            );
        }

        Ok(volume)
    }
}

unsafe impl Send for webrtc::AudioDeviceModule {}
unsafe impl Sync for webrtc::AudioDeviceModule {}

/// Representation of The Audio Processing Module, providing a collection of
/// voice processing components designed for real-time communications software.
pub struct AudioProcessing(UniquePtr<webrtc::AudioProcessing>);

impl AudioProcessing {
    /// Creates a new [`AudioProcessing`].
    pub fn new() -> anyhow::Result<Self> {
        let ptr = webrtc::create_audio_processing();

        if ptr.is_null() {
            bail!("`null` pointer returned from `AudioProcessing::Create()`");
        }

        Ok(Self(ptr))
    }

    /// Indicates intent to mute the output of this [`AudioProcessing`].
    ///
    /// Set it to `true` when the output of this [`AudioProcessing`] will be
    /// muted or in some other way not used. This hints the underlying AGC, AEC,
    /// NS processors to halt.
    pub fn set_output_will_be_muted(&self, muted: bool) {
        webrtc::set_output_will_be_muted(&self.0, muted);
    }
}

unsafe impl Send for webrtc::AudioProcessing {}
unsafe impl Sync for webrtc::AudioProcessing {}

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
                "`AudioDeviceModule::GetDeviceName()` failed with `{result}` \
                 code",
            );
        }

        Ok((name, guid))
    }
}

unsafe impl Send for webrtc::VideoDeviceInfo {}
unsafe impl Sync for webrtc::VideoDeviceInfo {}

/// Returns a list of all available [`VideoDisplaySource`]s.
#[must_use]
pub fn screen_capture_sources() -> Vec<VideoDisplaySource> {
    webrtc::screen_capture_sources()
        .into_iter()
        .map(|el| VideoDisplaySource(el.ptr))
        .collect()
}

/// Interface for receiving information about available display.
pub struct VideoDisplaySource(UniquePtr<webrtc::DisplaySource>);

impl VideoDisplaySource {
    /// Returns an `id` of this [`VideoDisplaySource`].
    #[must_use]
    pub fn id(&self) -> i64 {
        webrtc::display_source_id(&self.0)
    }

    /// Returns a `title` of this [`VideoDisplaySource`].
    #[must_use]
    pub fn title(&self) -> Option<String> {
        let title = webrtc::display_source_title(&self.0).to_string();
        (!title.is_empty()).then_some(title)
    }
}

/// [`RtcConfiguration`][1] wrapper.
///
/// Defines a set of parameters to configure how the peer-to-peer communication
/// via a [`PeerConnectionInterface`] is established or re-established.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration
pub struct RtcConfiguration(UniquePtr<webrtc::RTCConfiguration>);

impl RtcConfiguration {
    /// Sets the specified [`IceTransportsType`] configuration for this
    /// [`RtcConfiguration`].
    pub fn set_ice_transport_type(
        &mut self,
        transport_type: webrtc::IceTransportsType,
    ) {
        webrtc::set_rtc_configuration_ice_transport_type(
            self.0.pin_mut(),
            transport_type,
        );
    }

    /// Sets the specified [`BundlePolicy`] configuration for this
    /// [`RtcConfiguration`].
    pub fn set_bundle_policy(&mut self, bundle_policy: webrtc::BundlePolicy) {
        webrtc::set_rtc_configuration_bundle_policy(
            self.0.pin_mut(),
            bundle_policy,
        );
    }

    /// Adds the specified [`IceServer`] to the list of servers of this
    /// [`RtcConfiguration`].
    pub fn add_server(&mut self, mut server: IceServer) {
        webrtc::add_rtc_configuration_server(
            self.0.pin_mut(),
            server.0.pin_mut(),
        );
    }
}

impl Default for RtcConfiguration {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_configuration())
    }
}

/// [`RtcIceServer`][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtciceserver
pub struct IceServer(UniquePtr<webrtc::IceServer>);

impl IceServer {
    /// Adds a new `url` to the list of [urls][1] of this [`IceServer`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-urls
    pub fn add_url(&mut self, url: String) {
        webrtc::add_ice_server_url(self.0.pin_mut(), url);
    }

    /// Sets the [username][1] and [credential][2] of this [`IceServer`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-username
    /// [2]: https://w3.org/TR/webrtc#dom-rtciceserver-credential
    pub fn set_credentials(&mut self, username: String, credential: String) {
        webrtc::set_ice_server_credentials(
            self.0.pin_mut(),
            username,
            credential,
        );
    }
}

impl Default for IceServer {
    fn default() -> Self {
        Self(webrtc::create_ice_server())
    }
}

/// Member of [`PeerConnectionDependencies`] containing functions called on
/// events in a [`PeerConnectionInterface`]
pub struct PeerConnectionObserver(UniquePtr<webrtc::PeerConnectionObserver>);

impl PeerConnectionObserver {
    /// Creates a new [`PeerConnectionObserver`] backed by the provided
    /// [`PeerConnectionEventsHandler`]
    #[must_use]
    pub fn new(cb: Box<dyn PeerConnectionEventsHandler>) -> Self {
        Self(webrtc::create_peer_connection_observer(Box::new(cb)))
    }
}

unsafe impl Send for webrtc::PeerConnectionObserver {}
unsafe impl Sync for webrtc::PeerConnectionObserver {}

/// Contains all the [`PeerConnectionInterface`] dependencies.
pub struct PeerConnectionDependencies {
    /// Pointer to the C++ side `PeerConnectionDependencies` object.
    inner: UniquePtr<webrtc::PeerConnectionDependencies>,

    /// [`PeerConnectionObserver`] that these [`PeerConnectionDependencies`]
    /// depend on.
    ///
    /// It's stored here since it must outlive the dependencies object.
    observer: PeerConnectionObserver,
}

impl PeerConnectionDependencies {
    /// Creates a new [`PeerConnectionDependencies`] backed by the provided
    /// [`PeerConnectionObserver`].
    #[must_use]
    pub fn new(observer: PeerConnectionObserver) -> Self {
        Self {
            inner: webrtc::create_peer_connection_dependencies(&observer.0),
            observer,
        }
    }
}

/// Description of the options used to control an offer/answer creation process.
pub struct RTCOfferAnswerOptions(pub UniquePtr<webrtc::RTCOfferAnswerOptions>);

impl Default for RTCOfferAnswerOptions {
    fn default() -> Self {
        Self(webrtc::create_default_rtc_offer_answer_options())
    }
}

impl RTCOfferAnswerOptions {
    /// Creates a new [`RtcOfferAnswerOptions`].
    #[must_use]
    pub fn new(
        offer_to_receive_video: Option<bool>,
        offer_to_receive_audio: Option<bool>,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) -> Self {
        Self(webrtc::create_rtc_offer_answer_options(
            offer_to_receive_video.map_or(-1, |f| if f { 1 } else { 0 }),
            offer_to_receive_audio.map_or(-1, |f| if f { 1 } else { 0 }),
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        ))
    }
}

/// [`SessionDescriptionInterface`] class, used by a [`PeerConnectionInterface`]
/// to expose local and remote session descriptions.
pub struct SessionDescriptionInterface(
    UniquePtr<webrtc::SessionDescriptionInterface>,
);

impl SessionDescriptionInterface {
    /// Creates a new [`SessionDescriptionInterface`].
    #[must_use]
    pub fn new(kind: webrtc::SdpType, sdp: &str) -> Self {
        let_cxx_string!(cxx_sdp = sdp);
        Self(webrtc::create_session_description(kind, &cxx_sdp))
    }
}

/// [`PeerConnectionInterface::create_answer()`] and
/// [`PeerConnectionInterface::create_offer()`] completion callback.
pub struct CreateSessionDescriptionObserver(
    UniquePtr<webrtc::CreateSessionDescriptionObserver>,
);

impl CreateSessionDescriptionObserver {
    /// Creates a new [`CreateSessionDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn CreateSdpCallback>) -> Self {
        Self(webrtc::create_create_session_observer(Box::new(cb)))
    }
}

/// [`PeerConnectionInterface::set_local_description()`] completion callback.
pub struct SetLocalDescriptionObserver(
    UniquePtr<webrtc::SetLocalDescriptionObserver>,
);

impl SetLocalDescriptionObserver {
    /// Creates a new [`SetLocalDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_local_description_observer(Box::new(cb)))
    }
}

/// [`PeerConnectionInterface::set_remote_description()`] completion callback.
pub struct SetRemoteDescriptionObserver(
    UniquePtr<webrtc::SetRemoteDescriptionObserver>,
);

impl SetRemoteDescriptionObserver {
    /// Creates a new [`SetRemoteDescriptionObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn SetDescriptionCallback>) -> Self {
        Self(webrtc::create_set_remote_description_observer(Box::new(cb)))
    }
}

/// Representation of a combination of an [`RtpSenderInterface`] and an
/// [`RtpReceiverInterface`] sharing a common
/// [media stream "identification-tag"][1].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
pub struct RtpTransceiverInterface {
    /// Pointer to the C++ side [`RtpTransceiverInterface`] object.
    ///
    /// [`RtpTransceiverInterface`]: webrtc::PeerConnectionInterface
    inner: UniquePtr<webrtc::RtpTransceiverInterface>,

    /// Configured [`MediaType`] of this [`RtpTransceiverInterface`].
    ///
    /// It cannot be changed, so it's fetched from the C++ side once and cached
    /// here.
    media_type: MediaType,
}

impl RtpTransceiverInterface {
    /// Returns a [`mid`][0] of this [`RtpTransceiverInterface`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtptransceiver-mid
    #[must_use]
    pub fn mid(&self) -> Option<String> {
        let mid = webrtc::get_transceiver_mid(&self.inner);
        (!mid.is_empty()).then_some(mid)
    }

    /// Returns a [`direction`][0] of this [`RtpTransceiverInterface`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    #[must_use]
    pub fn direction(&self) -> webrtc::RtpTransceiverDirection {
        webrtc::get_transceiver_direction(&self.inner)
    }

    /// Returns a [`MediaType`] of this [`RtpTransceiverInterface`].
    #[must_use]
    pub fn media_type(&self) -> MediaType {
        self.media_type
    }

    /// Changes the preferred `direction` of this [`RtpTransceiverInterface`].
    pub fn set_direction(
        &self,
        direction: webrtc::RtpTransceiverDirection,
    ) -> anyhow::Result<()> {
        let err = webrtc::set_transceiver_direction(&self.inner, direction);
        if !err.is_empty() {
            bail!(
                "`RtpTransceiverInterface->SetDirectionWithError()` call \
                 failed: {err}",
            );
        }
        Ok(())
    }

    /// Returns the [`RtpSenderInterface`] object responsible for encoding and
    /// sending data to the remote peer.
    #[must_use]
    pub fn sender(&self) -> RtpSenderInterface {
        RtpSenderInterface(webrtc::transceiver_sender(&self.inner))
    }

    /// Returns the [`RtpReceiverInterface`] responsible for receiving and
    /// decoding incoming media data for the transceiver's stream.
    #[must_use]
    pub fn receiver(&self) -> RtpReceiverInterface {
        RtpReceiverInterface(webrtc::transceiver_receiver(&self.inner))
    }

    /// Irreversibly marks this [`RtpTransceiverInterface`] as stopping, unless
    /// it's already stopped.
    ///
    /// This will immediately cause this [`RtpTransceiverInterface`]'s sender to
    /// no longer send, and its receiver to no longer receive.
    pub fn stop(&self) -> anyhow::Result<()> {
        let err = webrtc::stop_transceiver(&self.inner);
        if !err.is_empty() {
            bail!(
                "`RtpTransceiverInterface->StopStandard()` call failed: {err}",
            );
        }
        Ok(())
    }
}

unsafe impl Send for webrtc::RtpTransceiverInterface {}
unsafe impl Sync for webrtc::RtpTransceiverInterface {}

/// [`RtcRtpSender`] allowing to control how a [MediaStreamTrack][1] is encoded
/// and transmitted to a remote peer.
///
/// [RtcRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct RtpSenderInterface(UniquePtr<webrtc::RtpSenderInterface>);

impl RtpSenderInterface {
    /// Replaces the track currently being used as the sender's source with a
    /// new [`VideoTrackInterface`].
    pub fn replace_video_track(
        &self,
        track: Option<&VideoTrackInterface>,
    ) -> anyhow::Result<()> {
        let success = webrtc::replace_sender_video_track(
            &self.0,
            track.map_or(&UniquePtr::null(), |t| &t.inner),
        );

        if !success {
            bail!("`RtpSenderInterface::SetTrack` failed");
        }

        Ok(())
    }

    /// Replaces the track currently being used as the sender's source with a
    /// new [`AudioTrackInterface`].
    pub fn replace_audio_track(
        &self,
        track: Option<&AudioTrackInterface>,
    ) -> anyhow::Result<()> {
        let success = webrtc::replace_sender_audio_track(
            &self.0,
            track.map_or(&UniquePtr::null(), |t| &t.inner),
        );

        if !success {
            bail!("`RtpSenderInterface::SetTrack` failed");
        }

        Ok(())
    }
}

unsafe impl Send for webrtc::RtpSenderInterface {}
unsafe impl Sync for webrtc::RtpSenderInterface {}

/// [`RtcRtpReceiver`][0] allowing to inspect the receipt of a
/// [MediaStreamTrack][1].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct RtpReceiverInterface(UniquePtr<webrtc::RtpReceiverInterface>);

impl RtpReceiverInterface {
    /// Returns the [`MediaStreamTrackInterface`] attribute, representing the
    /// track associated with this [`RtpReceiverInterface`] object receiver.
    #[must_use]
    pub fn track(&self) -> MediaStreamTrackInterface {
        MediaStreamTrackInterface(webrtc::rtp_receiver_track(&self.0))
    }

    /// Returns the [`RtpParameters`] object describing the current
    /// configuration for the encoding and transmission of media on the
    /// receiver's track.
    #[must_use]
    pub fn get_parameters(&self) -> RtpParameters {
        RtpParameters(webrtc::rtp_receiver_parameters(&self.0))
    }
}

unsafe impl Send for webrtc::RtpReceiverInterface {}
unsafe impl Sync for webrtc::RtpReceiverInterface {}

/// [`RtcRtpCodecParameters`][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters
pub struct RtpCodecParameters(webrtc::RtpCodecParametersContainer);

impl RtpCodecParameters {
    /// Returns the `name` of these [`RtpCodecParameters`].
    #[must_use]
    pub fn name(&self) -> String {
        webrtc::rtp_codec_parameters_name(&self.0.ptr).to_string()
    }

    /// Returns the [`payloadType`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-payloadtype
    #[must_use]
    pub fn payload_type(&self) -> i32 {
        webrtc::rtp_codec_parameters_payload_type(&self.0.ptr)
    }

    /// Returns the [`clockRate`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-clockrate
    #[must_use]
    pub fn clock_rate(&self) -> Option<i32> {
        webrtc::rtp_codec_parameters_clock_rate(&self.0.ptr).ok()
    }

    /// Returns the [`channels`][0] of these [`RtpCodecParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodecparameters-channels
    #[must_use]
    pub fn num_channels(&self) -> Option<i32> {
        webrtc::rtp_codec_parameters_num_channels(&self.0.ptr).ok()
    }

    /// Returns the `parameters` of these [`RtpCodecParameters`].
    #[must_use]
    pub fn parameters(&self) -> HashMap<String, String> {
        let mut result = HashMap::new();
        let mut params = webrtc::rtp_codec_parameters_parameters(&self.0.ptr);
        while let Some(pair) = params.pin_mut().pop() {
            result.insert(pair.first, pair.second);
        }
        result
    }

    /// Returns the [`MediaType`] of these [`RtpCodecParameters`].
    #[must_use]
    pub fn kind(&self) -> MediaType {
        webrtc::rtp_codec_parameters_kind(&self.0.ptr)
    }
}

/// [`RtcRtpHeaderExtensionParameters`][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters
pub struct RtpExtension(webrtc::RtpExtensionContainer);

impl RtpExtension {
    /// Returns the [`uri`][0] of this [`RtpExtension`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters-uri
    #[must_use]
    pub fn uri(&self) -> String {
        webrtc::rtp_extension_uri(&self.0.ptr).to_string()
    }

    /// Returns the [`id`][0] of this [`RtpExtension`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpheaderextensionparameters-id
    #[must_use]
    pub fn id(&self) -> i32 {
        webrtc::rtp_extension_id(&self.0.ptr)
    }

    /// Returns the [`encrypted`][0] property of this [`RtpExtension`].
    ///
    /// [0]: https://tinyurl.com/headerparameters-encrypted
    #[must_use]
    pub fn encrypt(&self) -> bool {
        webrtc::rtp_extension_encrypt(&self.0.ptr)
    }
}

/// [`RtcRtpEncodingParameters`][0] representation.
///
/// [0]: https://w3.org/TR/webrtc/#dom-rtcrtpencodingparameters
pub struct RtpEncodingParameters(webrtc::RtpEncodingParametersContainer);

impl RtpEncodingParameters {
    /// Returns the [`active`][0] property of these [`RtpEncodingParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpencodingparameters-active
    #[must_use]
    pub fn active(&self) -> bool {
        webrtc::rtp_encoding_parameters_active(&self.0.ptr)
    }

    /// Returns the [`maxBitrate`][0] of these [`RtpEncodingParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpencodingparameters-maxbitrate
    #[must_use]
    pub fn max_bitrate(&self) -> Option<i32> {
        webrtc::rtp_encoding_parameters_maxBitrate(&self.0.ptr).ok()
    }

    /// Returns the `minBitrate` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn min_bitrate(&self) -> Option<i32> {
        webrtc::rtp_encoding_parameters_minBitrate(&self.0.ptr).ok()
    }

    /// Returns the `maxFramerate` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn max_framerate(&self) -> Option<f64> {
        webrtc::rtp_encoding_parameters_maxFramerate(&self.0.ptr).ok()
    }

    /// Returns the `ssrc` of these [`RtpEncodingParameters`].
    #[must_use]
    pub fn ssrc(&self) -> Option<i64> {
        webrtc::rtp_encoding_parameters_ssrc(&self.0.ptr).ok()
    }

    /// Returns the [`scaleResolutionDownBy`][0] of these
    /// [`RtpEncodingParameters`].
    ///
    /// [0]: https://tinyurl.com/scaleresolutiondownby
    #[must_use]
    pub fn scale_resolution_down_by(&self) -> Option<f64> {
        webrtc::rtp_encoding_parameters_scale_resolution_down_by(&self.0.ptr)
            .ok()
    }
}

/// [`RtcRtcpParameters`][0] representation.
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters
pub struct RtcpParameters(UniquePtr<webrtc::RtcpParameters>);

impl RtcpParameters {
    /// Returns the [`cname`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters-cname
    #[must_use]
    pub fn cname(&self) -> String {
        webrtc::rtcp_parameters_cname(&self.0).to_string()
    }

    /// Returns the [`reducedSize`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtcpparameters-reducedsize
    #[must_use]
    pub fn reduced_size(&self) -> bool {
        webrtc::rtcp_parameters_reduced_size(&self.0)
    }
}

/// Parameters being used by an [`RtpReceiverInterface`]'s RTP
/// connection with a remote peer.
pub struct RtpParameters(UniquePtr<webrtc::RtpParameters>);

impl RtpParameters {
    /// Returns the `parameters` of these [`RtpParameters`].
    #[must_use]
    pub fn transaction_id(&self) -> String {
        webrtc::rtp_parameters_transaction_id(&self.0).to_string()
    }

    /// Returns the `mid` of these [`RtpParameters`].
    #[must_use]
    pub fn mid(&self) -> String {
        webrtc::rtp_parameters_mid(&self.0).to_string()
    }

    /// Returns the [`codecs`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-codecs
    #[must_use]
    pub fn codecs(&self) -> Vec<RtpCodecParameters> {
        webrtc::rtp_parameters_codecs(&self.0)
            .into_iter()
            .map(RtpCodecParameters)
            .collect()
    }

    /// Returns the [`headerExtensions`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-headerextensions
    #[must_use]
    pub fn header_extensions(&self) -> Vec<RtpExtension> {
        webrtc::rtp_parameters_header_extensions(&self.0)
            .into_iter()
            .map(RtpExtension)
            .collect()
    }

    /// Returns the `encodings` of these [`RtpParameters`].
    #[must_use]
    pub fn encodings(&self) -> Vec<RtpEncodingParameters> {
        webrtc::rtp_parameters_encodings(&self.0)
            .into_iter()
            .map(RtpEncodingParameters)
            .collect()
    }

    /// Returns the [`rtcp`][0] of these [`RtcpParameters`].
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpparameters-rtcp
    #[must_use]
    pub fn rtcp(&self) -> RtcpParameters {
        RtcpParameters(webrtc::rtp_parameters_rtcp(&self.0))
    }
}
/// This interface describes an ICE candidate, described in
/// [RFC 5245 Section 2][1].
///
/// [1]: https://datatracker.ietf.org/doc/html/rfc5245#section-2
pub struct IceCandidateInterface(UniquePtr<webrtc::IceCandidateInterface>);

impl IceCandidateInterface {
    /// Creates a new [`IceCandidateInterface`].
    pub fn new(
        sdp_mid: &str,
        sdp_mline_index: i32,
        candidate: &str,
    ) -> anyhow::Result<Self> {
        let mut error = String::new();
        let inner = webrtc::create_ice_candidate(
            sdp_mid,
            sdp_mline_index,
            candidate,
            &mut error,
        );

        if !error.is_empty() {
            bail!(error);
        }

        Ok(Self(inner))
    }

    /// Returns this [`IceCandidateInterface`]'s [`sdpMid`][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmid
    #[must_use]
    pub fn mid(&self) -> String {
        webrtc::sdp_mid_of_ice_candidate(&self.0).to_string()
    }

    /// Returns this [`IceCandidateInterface`] in a [string format][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-candidate
    #[must_use]
    pub fn candidate(&self) -> String {
        webrtc::ice_candidate_interface_to_string(&self.0).to_string()
    }

    /// Returns this [`IceCandidateInterface`]'s [`sdpMLineIndex`][1].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicecandidate-sdpmlineindex
    #[must_use]
    pub fn mline_index(&self) -> i32 {
        webrtc::sdp_mline_index_of_ice_candidate(&self.0)
    }
}

/// [`RtcPeerConnection`][1] implementation.
///
/// Calls to a [`PeerConnectionInterface`] APIs are proxied to the signaling
/// thread, meaning that an application can call those APIs from whatever
/// thread. See the "Threading Model" section in the
/// [Native APIs documentation][2].
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
/// [2]: https://webrtc.github.io/webrtc-org/native-code/native-apis
pub struct PeerConnectionInterface {
    /// Pointer to the C++ side [`PeerConnectionInterface`] object.
    ///
    /// [`PeerConnectionInterface`]: webrtc::PeerConnectionInterface
    inner: UniquePtr<webrtc::PeerConnectionInterface>,

    /// [`PeerConnectionObserver`] that this [`PeerConnectionInterface`]
    /// uses internally.
    ///
    /// It's stored here since it must outlive the peer connection object.
    _observer: PeerConnectionObserver,
}

unsafe impl Sync for webrtc::PeerConnectionInterface {}
unsafe impl Send for webrtc::PeerConnectionInterface {}

impl PeerConnectionInterface {
    /// [RtcPeerConnection.createOffer()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createoffer
    pub fn create_offer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_offer(self.inner.pin_mut(), &options.0, obs.0);
    }

    /// [RtcPeerConnection.createAnswer()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcpeerconnection-createanswer
    pub fn create_answer(
        &mut self,
        options: &RTCOfferAnswerOptions,
        obs: CreateSessionDescriptionObserver,
    ) {
        webrtc::create_answer(self.inner.pin_mut(), &options.0, obs.0);
    }

    /// [RtcPeerConnection.setLocalDescription()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setlocaldescription
    pub fn set_local_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetLocalDescriptionObserver,
    ) {
        webrtc::set_local_description(self.inner.pin_mut(), desc.0, obs.0);
    }

    /// [RtcPeerConnection.setRemoteDescription()][1] implementation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-peerconnection-setremotedescription
    pub fn set_remote_description(
        &mut self,
        desc: SessionDescriptionInterface,
        obs: SetRemoteDescriptionObserver,
    ) {
        webrtc::set_remote_description(self.inner.pin_mut(), desc.0, obs.0);
    }

    /// Creates a new [`RtpTransceiverInterface`] and adds it to the set of
    /// transceivers of this [`PeerConnectionInterface`].
    pub fn add_transceiver(
        &mut self,
        media_type: MediaType,
        direction: RtpTransceiverDirection,
    ) -> RtpTransceiverInterface {
        let inner = webrtc::add_transceiver(
            self.inner.pin_mut(),
            media_type,
            direction,
        );

        RtpTransceiverInterface { inner, media_type }
    }

    /// Returns a sequence of [`RtpTransceiverInterface`] objects representing
    /// the RTP transceivers currently attached to this
    /// [`PeerConnectionInterface`].
    #[must_use]
    pub fn get_transceivers(&self) -> Vec<RtpTransceiverInterface> {
        webrtc::get_transceivers(&self.inner)
            .into_iter()
            .map(|t| RtpTransceiverInterface {
                media_type: webrtc::get_transceiver_media_type(&t.ptr),
                inner: t.ptr,
            })
            .collect()
    }

    /// Adds an [`IceCandidateInterface`] to the [`PeerConnectionInterface`].
    pub fn add_ice_candidate(
        &self,
        candidate: IceCandidateInterface,
        cb: Box<dyn AddIceCandidateCallback>,
    ) {
        webrtc::add_ice_candidate(&self.inner, candidate.0, Box::new(cb));
    }

    /// Tells the [`PeerConnectionInterface`] that ICE should be restarted.
    pub fn restart_ice(&self) {
        webrtc::restart_ice(&self.inner);
    }

    /// Closes the [`PeerConnectionInterface`].
    pub fn close(&self) {
        webrtc::close_peer_connection(&self.inner);
    }

    /// Gets [`RtcStatsReport`] of the [`PeerConnectionInterface`].
    pub fn get_stats(&self, cb: Box<dyn RTCStatsCollectorCallback>) {
        webrtc::peer_connection_get_stats(&self.inner, Box::new(cb));
    }
}

/// Interface for using an Rtc [`Thread`][1].
///
/// [1]: https://tinyurl.com/doc-threads
pub struct Thread(UniquePtr<webrtc::Thread>);

impl Thread {
    /// Creates a new [`Thread`].
    ///
    /// If `with_socket_server` is `true`, then the created thread will have a
    /// socket server attached, thus it will be capable of serving as a network
    /// thread.
    pub fn create(with_socket_server: bool) -> anyhow::Result<Self> {
        let ptr = if with_socket_server {
            webrtc::create_thread_with_socket_server()
        } else {
            webrtc::create_thread()
        };

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

unsafe impl Send for webrtc::Thread {}
unsafe impl Sync for webrtc::Thread {}

/// [`PeerConnectionFactoryInterface`] is the main entry point to the
/// `PeerConnection API` for clients it is responsible for creating
/// [`AudioSourceInterface`], tracks ([`VideoTrackInterface`],
/// [`AudioTrackInterface`]), [`MediaStreamInterface`] and the
/// `PeerConnection`s.
pub struct PeerConnectionFactoryInterface(
    UniquePtr<webrtc::PeerConnectionFactoryInterface>,
);

impl PeerConnectionFactoryInterface {
    /// Creates a new [`PeerConnectionFactoryInterface`].
    pub fn create(
        network_thread: Option<&Thread>,
        worker_thread: Option<&Thread>,
        signaling_thread: Option<&Thread>,
        default_adm: Option<&AudioDeviceModule>,
        ap: Option<&AudioProcessing>,
    ) -> anyhow::Result<Self> {
        let inner = webrtc::create_peer_connection_factory(
            network_thread.map_or(&UniquePtr::null(), |t| &t.0),
            worker_thread.map_or(&UniquePtr::null(), |t| &t.0),
            signaling_thread.map_or(&UniquePtr::null(), |t| &t.0),
            default_adm.map_or(&UniquePtr::null(), |t| &t.0),
            ap.map_or(&UniquePtr::null(), |ap| &ap.0),
        );

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreatePeerConnectionFactory()`",
            );
        }
        Ok(Self(inner))
    }

    /// Creates a new [`PeerConnectionInterface`].
    pub fn create_peer_connection_or_error(
        &mut self,
        configuration: &RtcConfiguration,
        dependencies: PeerConnectionDependencies,
    ) -> anyhow::Result<PeerConnectionInterface> {
        let mut error = String::new();
        let inner = webrtc::create_peer_connection_or_error(
            self.0.pin_mut(),
            &configuration.0,
            dependencies.inner,
            &mut error,
        );

        if !error.is_empty() {
            bail!(error);
        }
        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::\
                 CreatePeerConnectionOrError()`",
            );
        }
        Ok(PeerConnectionInterface {
            inner,
            _observer: dependencies.observer,
        })
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
        let inner = webrtc::create_video_track(&self.0, id, &video_src.0);

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateVideoTrack()`",
            );
        }
        Ok(VideoTrackInterface {
            inner,
            observers: Vec::new(),
        })
    }

    /// Creates a new [`AudioTrackInterface`] sourced by the provided
    /// [`AudioSourceInterface`].
    pub fn create_audio_track(
        &self,
        id: String,
        audio_src: &AudioSourceInterface,
    ) -> anyhow::Result<AudioTrackInterface> {
        let inner = webrtc::create_audio_track(&self.0, id, &audio_src.0);

        if inner.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::PeerConnectionFactoryInterface::CreateAudioTrack()`",
            );
        }
        Ok(AudioTrackInterface {
            inner,
            observers: Vec::new(),
        })
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

unsafe impl Send for webrtc::PeerConnectionFactoryInterface {}
unsafe impl Sync for webrtc::PeerConnectionFactoryInterface {}

/// [`VideoTrackSourceInterface`] captures data from the specific video input
/// device.
///
/// It can be later used to create a [`VideoTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_video_track()`].
pub struct VideoTrackSourceInterface(
    UniquePtr<webrtc::VideoTrackSourceInterface>,
);

impl VideoTrackSourceInterface {
    /// Creates a new [`VideoTrackSourceInterface`] from the video input device
    /// with the specified constraints.
    ///
    /// The created capturer is wrapped in the `VideoTrackSourceProxy` that
    /// makes sure the real [`VideoTrackSourceInterface`] implementation is
    /// destroyed on the signaling thread and marshals all method calls to the
    /// signaling thread.
    pub fn create_proxy_from_device(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        width: usize,
        height: usize,
        fps: usize,
        device_index: u32,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_device_video_source(
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

    /// Creates a new fake [`VideoTrackSourceInterface`].
    pub fn create_fake(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        width: usize,
        height: usize,
        fps: usize,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_fake_device_video_source(
            worker_thread.0.pin_mut(),
            signaling_thread.0.pin_mut(),
            width,
            height,
            fps,
        );

        if ptr.is_null() {
            bail!(
                "`null` pointer returned from \
                 `webrtc::CreateVideoTrackSource()`",
            );
        }
        Ok(VideoTrackSourceInterface(ptr))
    }

    // TODO: Support screens enumeration.
    /// Starts screen capturing and creates a new [`VideoTrackSourceInterface`]
    /// with the specified constraints.
    ///
    /// The created capturer is wrapped in the `VideoTrackSourceProxy` that
    /// makes sure the real [`VideoTrackSourceInterface`] implementation is
    /// destroyed on the signaling thread and marshals all method calls to the
    /// signaling thread.
    pub fn create_proxy_from_display(
        worker_thread: &mut Thread,
        signaling_thread: &mut Thread,
        id: i64,
        width: usize,
        height: usize,
        fps: usize,
    ) -> anyhow::Result<Self> {
        let ptr = webrtc::create_display_video_source(
            worker_thread.0.pin_mut(),
            signaling_thread.0.pin_mut(),
            id,
            width,
            height,
            fps,
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

unsafe impl Send for webrtc::VideoTrackSourceInterface {}
unsafe impl Sync for webrtc::VideoTrackSourceInterface {}

/// [`VideoTrackSourceInterface`] captures data from the specific audio input
/// device.
///
/// It can be later used to create a [`AudioTrackInterface`] with
/// [`PeerConnectionFactoryInterface::create_audio_track()`].
pub struct AudioSourceInterface(UniquePtr<webrtc::AudioSourceInterface>);

unsafe impl Send for webrtc::AudioSourceInterface {}
unsafe impl Sync for webrtc::AudioSourceInterface {}

/// [MediaStreamTrack] object representing a media source in an User Agent.
///
/// An example source is a device connected to the User Agent.
///
/// [MediaStreamTrack]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
pub struct MediaStreamTrackInterface(
    UniquePtr<webrtc::MediaStreamTrackInterface>,
);

impl MediaStreamTrackInterface {
    /// Returns the [`String`] containing the unique identifier (GUID) of this
    /// track.
    #[must_use]
    pub fn id(&self) -> String {
        webrtc::media_stream_track_id(&self.0).to_string()
    }

    /// Returns the [`TrackState`] of this [`MediaStreamTrackInterface`].
    #[must_use]
    pub fn state(&self) -> webrtc::TrackState {
        webrtc::media_stream_track_state(&self.0)
    }

    /// Returns the `enabled` property of this [`MediaStreamTrackInterface`],
    /// which is a [`bool`] indicating `true` if this track is allowed to render
    /// the source stream, or `false` otherwise.
    #[must_use]
    pub fn enabled(&self) -> bool {
        webrtc::media_stream_track_enabled(&self.0)
    }

    /// Returns the [`TrackKind`] of this [`MediaStreamTrackInterface`].
    #[must_use]
    pub fn kind(&self) -> TrackKind {
        let kind = webrtc::media_stream_track_kind(&self.0).to_string();
        match kind.as_str() {
            "audio" => TrackKind::Audio,
            "video" => TrackKind::Video,
            _ => unreachable!(),
        }
    }
}

/// C++ side [`TrackEventCallback`] handling [`MediaStreamTrackInterface`]
/// events.
pub struct TrackEventObserver(UniquePtr<webrtc::TrackEventObserver>);

impl TrackEventObserver {
    /// Creates a new [`TrackEventObserver`].
    #[must_use]
    pub fn new(cb: Box<dyn TrackEventCallback>) -> Self {
        TrackEventObserver(webrtc::create_track_event_observer(Box::new(cb)))
    }

    /// Sets the observable track to the specified [`VideoTrackInterface`].
    pub fn set_video_track(&mut self, track: &VideoTrackInterface) {
        webrtc::set_track_observer_video_track(self.0.pin_mut(), &track.inner);
    }

    /// Sets the observable track to the specified [`AudioTrackInterface`].
    pub fn set_audio_track(&mut self, track: &AudioTrackInterface) {
        webrtc::set_track_observer_audio_track(self.0.pin_mut(), &track.inner);
    }
}

unsafe impl Send for webrtc::TrackEventObserver {}
unsafe impl Sync for webrtc::TrackEventObserver {}

/// Video [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct VideoTrackInterface {
    /// Pointer to the C++ side `VideoTrackInterface` object.
    inner: UniquePtr<webrtc::VideoTrackInterface>,

    /// [`TrackEventObserver`]s subscribed to this [`VideoTrackInterface`] state
    /// changes.
    observers: Vec<TrackEventObserver>,
}

impl VideoTrackInterface {
    /// Register the provided [`VideoSinkInterface`] for this
    /// [`VideoTrackInterface`].
    ///
    /// Used to connect this [`VideoTrackInterface`] to the underlying video
    /// engine.
    pub fn add_or_update_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::add_or_update_video_sink(&self.inner, sink.0.pin_mut());
    }

    /// Detaches the provided [`VideoSinkInterface`] from this
    /// [`VideoTrackInterface`].
    pub fn remove_sink(&self, sink: &mut VideoSinkInterface) {
        webrtc::remove_video_sink(&self.inner, sink.0.pin_mut());
    }

    /// Changes the [enabled][1] property of this [`VideoTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_video_track_enabled(&self.inner, enabled);
    }

    /// Registers the given [`TrackEventCallback`] as an observer of this
    /// [`MediaStreamTrackInterface`] events.
    pub fn register_observer(&mut self, mut obs: TrackEventObserver) {
        webrtc::video_track_register_observer(
            self.inner.pin_mut(),
            obs.0.pin_mut(),
        );
        self.observers.push(obs);
    }

    /// Returns the [`VideoTrackSourceInterface`] attached to this
    /// [`VideoTrackInterface`].
    #[must_use]
    pub fn source(&self) -> VideoTrackSourceInterface {
        VideoTrackSourceInterface(webrtc::get_video_track_source(&self.inner))
    }

    /// Returns the [readyState][0] property of this [`VideoTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    #[must_use]
    pub fn state(&self) -> TrackState {
        webrtc::video_track_state(&self.inner)
    }
}

impl Drop for VideoTrackInterface {
    fn drop(&mut self) {
        let observers = mem::take(&mut self.observers);

        for mut obs in observers {
            webrtc::video_track_unregister_observer(
                self.inner.pin_mut(),
                obs.0.pin_mut(),
            );
        }
    }
}

unsafe impl Send for webrtc::VideoTrackInterface {}
unsafe impl Sync for webrtc::VideoTrackInterface {}

impl TryFrom<MediaStreamTrackInterface> for VideoTrackInterface {
    type Error = anyhow::Error;

    fn try_from(track: MediaStreamTrackInterface) -> anyhow::Result<Self> {
        if track.kind() == TrackKind::Video {
            let inner =
                webrtc::media_stream_track_interface_downcast_video_track(
                    track.0,
                );
            Ok(VideoTrackInterface {
                inner,
                observers: Vec::new(),
            })
        } else {
            bail!(
                "The provided `MediaStreamTrackInterface` is not an instance \
                 of `VideoTrackInterface`"
            );
        }
    }
}

/// Audio [`MediaStreamTrack`][1].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrack
pub struct AudioTrackInterface {
    /// Pointer to the C++ side `AudioTrackInterface` object.
    inner: UniquePtr<webrtc::AudioTrackInterface>,

    /// [`TrackEventObserver`]s subscribed to this [`AudioTrackInterface`] state
    /// changes.
    observers: Vec<TrackEventObserver>,
}

impl AudioTrackInterface {
    /// Changes the [enabled][1] property of this [`AudioTrackInterface`].
    ///
    /// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
    pub fn set_enabled(&self, enabled: bool) {
        webrtc::set_audio_track_enabled(&self.inner, enabled);
    }

    /// Registers the provided [`TrackEventCallback`] as an observer of this
    /// [`MediaStreamTrackInterface`] events.
    pub fn register_observer(&mut self, mut obs: TrackEventObserver) {
        webrtc::audio_track_register_observer(
            self.inner.pin_mut(),
            obs.0.pin_mut(),
        );
        self.observers.push(obs);
    }

    /// Returns the [`AudioSourceInterface`] attached to this
    /// [`AudioTrackInterface`].
    #[must_use]
    pub fn source(&self) -> AudioSourceInterface {
        AudioSourceInterface(webrtc::get_audio_track_source(&self.inner))
    }

    /// Returns the [readyState][0] property of this [`AudioTrackInterface`].
    ///
    /// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
    #[must_use]
    pub fn state(&self) -> TrackState {
        webrtc::audio_track_state(&self.inner)
    }
}

impl Drop for AudioTrackInterface {
    fn drop(&mut self) {
        let observers = mem::take(&mut self.observers);

        for mut obs in observers {
            webrtc::audio_track_unregister_observer(
                self.inner.pin_mut(),
                obs.0.pin_mut(),
            );
        }
    }
}

unsafe impl Send for webrtc::AudioTrackInterface {}
unsafe impl Sync for webrtc::AudioTrackInterface {}

impl TryFrom<MediaStreamTrackInterface> for AudioTrackInterface {
    type Error = anyhow::Error;

    fn try_from(track: MediaStreamTrackInterface) -> anyhow::Result<Self> {
        if track.kind() == TrackKind::Audio {
            let inner =
                webrtc::media_stream_track_interface_downcast_audio_track(
                    track.0,
                );
            Ok(AudioTrackInterface {
                inner,
                observers: Vec::new(),
            })
        } else {
            bail!(
                "The provided `MediaStreamTrackInterface` is not an instance \
                 of `AudioTrackInterface`"
            );
        }
    }
}

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
        let result = webrtc::add_video_track(&self.0, &track.inner);

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
        let result = webrtc::add_audio_track(&self.0, &track.inner);

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
        let result = webrtc::remove_video_track(&self.0, &track.inner);

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
        let result = webrtc::remove_audio_track(&self.0, &track.inner);

        if !result {
            bail!("`webrtc::MediaStreamInterface::RemoveTrack()` failed");
        }
        Ok(())
    }
}

unsafe impl Send for webrtc::MediaStreamInterface {}
unsafe impl Sync for webrtc::MediaStreamInterface {}

/// End point of a video pipeline.
pub struct VideoSinkInterface(UniquePtr<webrtc::VideoSinkInterface>);

impl VideoSinkInterface {
    /// Creates a new [`VideoSinkInterface`] forwarding [`VideoFrame`]s to
    /// the provided [`OnFrameCallback`].
    #[must_use]
    pub fn create_forwarding(cb: Box<dyn OnFrameCallback>) -> Self {
        Self(webrtc::create_forwarding_video_sink(Box::new(cb)))
    }
}

unsafe impl Send for webrtc::VideoSinkInterface {}
unsafe impl Sync for webrtc::VideoSinkInterface {}

/// [`RtcStat`] fields of [`RtcStatsType::MediaSource`] type based on its
/// `kind`.
pub enum RtcMediaSourceStatsMediaType {
    /// [`RtcStat`] fields of [`RtcStatsType::MediaSource`]
    /// type based on video kind.
    RtcVideoSourceStats {
        /// Width (in pixels) of the last frame originating from the source.
        /// Before a frame has been produced this attribute is missing.
        width: Option<u32>,

        /// Height (in pixels) of the last frame originating from the source.
        /// Before a frame has been produced this attribute is missing.
        height: Option<u32>,

        /// The total number of frames originating from this source.
        frames: Option<u32>,

        /// Number of frames originating from the source, measured during the
        /// last second. For the first second of this object's lifetime this
        /// attribute is missing.
        frames_per_second: Option<f64>,
    },

    /// [`RtcStat`] fields of [`RtcStatsType::MediaSource`]
    /// type based on audio `kind`.
    RtcAudioSourceStats {
        /// Audio level of the media source.
        audio_level: Option<f64>,

        /// Audio energy of the media source.
        total_audio_energy: Option<f64>,

        /// Audio duration of the media source.
        total_samples_duration: Option<f64>,

        /// Only exists when the MediaStreamTrack is sourced
        /// from a microphone where echo cancellation is applied.
        echo_return_loss: Option<f64>,

        /// Only exists when the [`MediaStreamTrack`]
        /// is sourced from a microphone where
        /// echo cancellation is applied.
        echo_return_loss_enhancement: Option<f64>,
    },
}

pub enum RtcOutboundRTPStreamStatsMediaType {
    Audio {},
    Video {
        /// Width of the last encoded frame.
        ///
        /// The resolution of the encoded frame may be lower than the media
        /// source (see [RtcVideoSourceStats.width][1]).
        ///
        /// Before the first frame is encoded this attribute is missing.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats/#dom-rtcvideosourcestats-width
        frame_width: Option<u32>,

        /// Height of the last encoded frame.
        ///
        /// The resolution of the encoded frame may be lower than the media
        /// source (see [RtcVideoSourceStats.height][1]).
        ///
        /// Before the first frame is encoded this attribute is missing.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats/#dom-rtcvideosourcestats-height
        frame_height: Option<u32>,

        /// Number of encoded frames during the last second.
        ///
        /// This may be lower than the media source frame rate (see
        /// [RtcVideoSourceStats.framesPerSecond][1]).
        ///
        /// [1]: https://tinyurl.com/rrmkrfk
        frames_per_second: Option<f64>,
    },
}

/// Fields of [`RtcStatsType::InboundRtp`] variant.
pub enum RtcInboundRtpStreamMediaType {
    /// Fields when `mediaType` is `audio`.
    Audio {
        /// Total number of samples that have been received on this RTP stream.
        /// This includes [`concealedSamples`].
        ///
        /// [`concealedSamples`]: https://tinyurl.com/s6c4qe4
        total_samples_received: Option<u64>,

        /// Total number of samples that are concealed samples.
        ///
        /// A concealed sample is a sample that was replaced with synthesized
        /// samples generated locally before being played out.
        /// Examples of samples that have to be concealed are samples from lost
        /// packets (reported in [`packetsLost`]) or samples from packets that
        /// arrive too late to be played out (reported in
        /// [`packetsDiscarded`]).
        ///
        /// [`packetsLost`]: https://tinyurl.com/u2gq965
        /// [`packetsDiscarded`]: https://tinyurl.com/yx7qyox3
        concealed_samples: Option<u64>,

        /// Total number of concealed samples inserted that are "silent".
        ///
        /// Playing out silent samples results in silence or comfort noise.
        /// This is a subset of [`concealedSamples`].
        ///
        /// [`concealedSamples`]: https://tinyurl.com/s6c4qe4
        silent_concealed_samples: Option<u64>,

        /// Audio level of the receiving track.
        audio_level: Option<f64>,

        /// Audio energy of the receiving track.
        total_audio_energy: Option<f64>,

        /// Audio duration of the receiving track.
        ///
        /// For audio durations of tracks attached locally, see
        /// [RtcAudioSourceStats][1] instead.
        ///
        /// [1]: https://w3.org/TR/webrtc-stats/#dom-rtcaudiosourcestats
        total_samples_duration: Option<f64>,
    },

    /// Fields when `mediaType` is `video`.
    Video {
        /// Total number of frames correctly decoded for this RTP stream, i.e.
        /// frames that would be displayed if no frames are dropped.
        frames_decoded: Option<u32>,

        /// Total number of key frames, such as key frames in VP8 [RFC 6386] or
        /// IDR-frames in H.264 [RFC 6184], successfully decoded for this RTP
        /// media stream.
        ///
        /// This is a subset of [`framesDecoded`].
        /// [`framesDecoded`] - [`keyFramesDecoded`] gives you the number of
        /// delta frames decoded.
        ///
        /// [RFC 6386]: https://w3.org/TR/webrtc-stats/#bib-rfc6386
        /// [RFC 6184]: https://w3.org/TR/webrtc-stats/#bib-rfc6184
        /// [`framesDecoded`]: https://tinyurl.com/srfwrwt
        /// [`keyFramesDecoded`]: https://tinyurl.com/qtdmhtm
        key_frames_decoded: Option<u32>,

        /// Width of the last decoded frame.
        ///
        /// Before the first frame is decoded this attribute is missing.
        frame_width: Option<u32>,

        /// Height of the last decoded frame.
        ///
        /// Before the first frame is decoded this attribute is missing.
        frame_height: Option<u32>,

        /// Sum of the interframe delays in seconds between consecutively
        /// decoded frames, recorded just after a frame has been decoded.
        total_inter_frame_delay: Option<f64>,

        /// Number of decoded frames in the last second.
        frames_per_second: Option<f64>,

        /// Bit depth per pixel of the last decoded frame.
        ///
        /// Typical values are 24, 30, or 36 bits. Before the first frame is
        /// decoded this attribute is missing.
        frame_bit_depth: Option<u32>,

        /// Total number of Full Intra Request (FIR) packets sent by this
        /// receiver.
        fir_count: Option<u32>,

        /// Total number of Picture Loss Indication (PLI) packets sent by this
        /// receiver.
        pli_count: Option<u32>,

        /// Number of concealment events.
        ///
        /// This counter increases every time a concealed sample is synthesized
        /// after a non-concealed sample. That is, multiple consecutive
        /// concealed samples will increase the [`concealedSamples`] count
        /// multiple times but is a single concealment event.
        ///
        /// [`concealedSamples`]: https://tinyurl.com/s6c4qe4
        concealment_events: Option<u64>,

        /// Total number of complete frames received on this RTP stream.
        ///
        /// This metric is incremented when the complete frame is received.
        frames_received: Option<i32>,
    },
}

/// Protocols used in the `WebRtc`.
#[derive(Debug, Copy, Clone)]
pub enum Protocol {
    /// [Transmission Control Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
    Tcp,

    /// [User Datagram Protocol][1].
    ///
    /// [1]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
    Udp,
}

/// Variants of [ICE roles][1].
///
/// More info in the [RFC 5245].
///
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
#[derive(Debug, Copy, Clone)]
pub enum IceRole {
    /// Agent whose role as defined by [Section 3 in RFC 5245][1], has not yet
    /// been determined.
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Unknown,
    /// Controlling agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlling,
    /// Controlled agent as defined by [Section 3 in RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-3
    Controlled,
}

impl TryFrom<&str> for IceRole {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "unknown" => Ok(Self::Unknown),
            "controlling" => Ok(Self::Controlling),
            "controlled" => Ok(Self::Controlled),
            protocol => Err(anyhow!("Unknown ice role: {protocol}")),
        }
    }
}

impl TryFrom<&str> for Protocol {
    type Error = anyhow::Error;

    fn try_from(val: &str) -> Result<Self, Self::Error> {
        match val {
            "tcp" => Ok(Self::Tcp),
            "udp" => Ok(Self::Udp),
            protocol => Err(anyhow!("Unknown protocol: {protocol}")),
        }
    }
}

/// Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
/// It corresponds to a [`RtcIceTransport`] object.
///
/// [`RtcStatsType::LocalCandidate`] or [`RtcStatsType::RemoteCandidate`]
/// variant.
///
/// [Full doc on W3C][2].
///
/// [RtcIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
/// [2]: https://w3.org/TR/webrtc-stats/#icecandidate-dict%2A
pub struct IceCandidateStats {
    /// Unique ID that is associated to the object that was inspected to
    /// produce the [RtcTransportStats][1] associated with this candidate.
    ///
    /// [1]: https://w3.org/TR/webrtc-stats/#transportstats-dict%2A
    pub transport_id: Option<String>,

    /// Address of the candidate, allowing for IPv4 addresses, IPv6 addresses,
    /// and fully qualified domain names (FQDNs).
    pub address: Option<String>,

    /// Port number of the candidate.
    pub port: Option<i32>,

    /// Valid values for transport is one of `udp` and `tcp`.
    pub protocol: Protocol,

    /// Type of the ICE candidate.
    pub candidate_type: CandidateType,

    /// Calculated as defined in [Section 15.1 of RFC 5245][1].
    ///
    /// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
    pub priority: Option<i32>,

    /// For local candidates this is the URL of the ICE server from which the
    /// candidate was obtained. It is the same as the
    /// [url surfaced in the RtcPeerConnectionIceEvent][1].
    ///
    /// `None` for remote candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#rtcpeerconnectioniceevent
    pub url: Option<String>,
}

/// [`RtcStatsType::LocalCandidate`] or [`RtcStatsType::RemoteCandidate`]
/// variant.
pub enum RtcIceCandidateStats {
    /// [`RtcStatsType::LocalCandidate`].
    RtcLocalIceCandidateStats(IceCandidateStats),

    /// [`RtcStatsType::RemoteCandidate`].
    RtcRemoteIceCandidateStats(IceCandidateStats),
}

/// All known types of [`RtcStat`]s.
///
/// [List of all `RtcStats` types on W3C][1].
///
/// [1]: https://w3.org/TR/webrtc-stats/#rtctatstype-%2A
/// [`RtcStat`]: super::RtcStat
pub enum RtcStatsType {
    /// Statistics for the media produced by a [MediaStreamTrack][1] that
    /// is currently attached to an [RtcRtpSender]. This reflects
    /// the media that is fed to the encoder after [getUserMedia]
    /// constraints have been applied (i.e. not the raw media
    /// produced by the camera).
    ///
    /// [RtcRtpSender]: https://w3.org/TR/webrtc#rtcrtpsender-interface
    /// [getUserMedia]: https://tinyurl.com/sngpyr6
    /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
    RtcMediaSourceStats {
        /// Value of the [MediaStreamTrack][1]'s ID attribute.
        ///
        /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
        track_identifier: Option<String>,

        /// Fields which should be in the [`RtcStat`] based on `kind`.
        kind: RtcMediaSourceStatsMediaType,
    },

    /// ICE remote candidate statistics related to the [RtcIceTransport]
    /// objects.
    ///
    /// A remote candidate is [deleted][1] when the [RtcIceTransport] does
    /// an ICE restart, and the candidate is no longer a member of
    /// any non-deleted candidate pair.
    ///
    /// [RtcIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
    /// [1]: https://w3.org/TR/webrtc-stats/#dfn-deleted
    RtcIceCandidateStats(RtcIceCandidateStats),

    /// Statistics for an outbound [RTP] stream that is currently sent with
    /// [RtcPeerConnection] object.
    ///
    /// When there are multiple [RTP] streams connected to the same sender,
    /// such as when using simulcast or RTX, there will be one
    /// [`RtcOutboundRtpStreamStats`] per RTP stream, with distinct values
    /// of the `ssrc` attribute, and all these senders will have a
    /// reference to the same "sender" object (of type
    /// [RtcAudioSenderStats][1] or [RtcVideoSenderStats][2]) and
    /// "track" object (of type
    /// [RtcSenderAudioTrackAttachmentStats][3] or
    /// [RtcSenderVideoTrackAttachmentStats][4]).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    /// [1]: https://w3.org/TR/webrtc-stats/#dom-rtcaudiosenderstats
    /// [2]: https://w3.org/TR/webrtc-stats/#dom-rtcvideosenderstats
    /// [3]: https://tinyurl.com/sefa5z4
    /// [4]: https://tinyurl.com/rkuvpl4
    RtcOutboundRTPStreamStats {
        /// ID of the stats object representing the current track attachment
        /// to the sender of this stream.
        track_id: Option<String>,

        /// Fields which should be in the [`RtcStat`] based on `mediaType`.
        kind: RtcOutboundRTPStreamStatsMediaType,

        /// Total number of bytes sent for this SSRC.
        bytes_sent: Option<u64>,

        /// Total number of RTP packets sent for this SSRC.
        packets_sent: Option<u32>,

        /// ID of the stats object representing the track currently
        /// attached to the sender of this stream.
        media_source_id: Option<String>,
    },

    /// Statistics for an inbound [RTP] stream that is currently received
    /// with [RtcPeerConnection] object.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcInboundRTPStreamStats {
        /// ID of the stats object representing the receiving track.
        remote_id: Option<String>,

        /// Total number of bytes received for this SSRC.
        bytes_received: Option<u64>,

        /// Total number of RTP data packets received for this SSRC.
        packets_received: Option<u32>,

        /// Total number of seconds that have been spent decoding the
        /// [`framesDecoded`] frames of this stream.
        ///
        /// The average decode time can be calculated by dividing this value
        /// with [`framesDecoded`].
        /// The time it takes to decode one frame is the time
        /// passed between feeding the decoder a frame and the decoder returning
        /// decoded data for that frame.
        ///
        /// [`framesDecoded`]: https://tinyurl.com/srfwrwt
        total_decode_time: Option<f64>,

        /// Total number of audio samples or video frames
        /// that have come out of the
        /// jitter buffer (increasing [`jitterBufferDelay`]).
        ///
        /// [`jitterBufferDelay`]: https://tinyurl.com/qvoojt5
        jitter_buffer_emitted_count: Option<u64>,

        /// Fields which should be in the [`RtcStat`] based on `mediaType`.
        media_type: Option<RtcInboundRtpStreamMediaType>,
    },

    /// ICE candidate pair statistics related to the [RtcIceTransport]
    /// objects.
    ///
    /// A candidate pair that is not the current pair for a transport is
    /// [deleted][1] when the [RtcIceTransport] does an ICE restart, at the
    /// time the state changes to `new`.
    ///
    /// The candidate pair that is the current pair for a transport is
    /// deleted after an ICE restart when the [RtcIceTransport]
    /// switches to using a candidate pair generated from the new
    /// candidates; this time doesn't correspond to any other
    /// externally observable event.
    ///
    /// [RtcIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
    /// [1]: https://w3.org/TR/webrtc-stats/#dfn-deleted
    RtcIceCandidatePairStats {
        /// State of the checklist for the local
        /// and remote candidates in a pair.
        state: RTCStatsIceCandidatePairState,

        /// Related to updating the nominated flag described in
        /// [Section 7.1.3.2.4 of RFC 5245][1].
        ///
        /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
        nominated: Option<bool>,

        /// Total number of payload bytes sent on this candidate pair, i.e. not
        /// including headers or padding.
        bytes_sent: Option<u64>,

        /// Total number of payload bytes received on this candidate pair, i.e.
        /// not including headers or padding.
        bytes_received: Option<u64>,

        /// Sum of all round trip time measurements in seconds since
        /// the beginning of the session,
        /// based on STUN connectivity check [STUN-PATH-CHAR]
        /// responses (responsesReceived), including those that reply
        /// to requests that are sent in order to verify consent [RFC 7675].
        ///
        /// The average round trip time can be computed from
        /// [`totalRoundTripTime`][1] by dividing it
        /// by [`responsesReceived`][2].
        ///
        /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats/#bib-stun-path-char
        /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
        /// [1]: https://tinyurl.com/tgr543a
        /// [2]: https://tinyurl.com/r3zo2um
        total_round_trip_time: Option<f64>,

        /// Latest round trip time measured in seconds, computed from both STUN
        /// connectivity checks [STUN-PATH-CHAR],
        /// including those that are sent for consent verification [RFC 7675].
        ///
        /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats/#bib-stun-path-char
        /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
        current_round_trip_time: Option<f64>,

        /// Calculated by the underlying congestion control by combining the
        /// available bitrate for all the outgoing RTP streams using
        /// this candidate pair.
        /// The bitrate measurement does not count the size of the IP or
        /// other transport layers like TCP or UDP. It is similar to the TIAS
        /// defined in [RFC 3890], i.e. it is measured in bits per second and
        /// the bitrate is calculated over a 1 second window.
        ///
        /// Implementations that do not calculate a sender-side estimate
        /// MUST leave this undefined. Additionally, the value MUST be undefined
        /// for candidate pairs that were never used. For pairs in use,
        /// the estimate is normally
        /// no lower than the bitrate for the packets sent at
        /// [`lastPacketSentTimestamp`][1], but might be higher. For candidate
        /// pairs that are not currently in use but were used before,
        /// implementations MUST return undefined.
        ///
        /// [RFC 3890]: https://tools.ietf.org/html/rfc3890
        /// [1]: https://tinyurl.com/rfc72eh
        available_outgoing_bitrate: Option<f64>,
    },

    /// Transport statistics related to the [RtcPeerConnection] object.
    ///
    /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcTransportStats {
        /// Total number of packets sent over this transport.
        packets_sent: Option<u64>,

        /// Total number of packets received on this transport.
        packets_received: Option<u64>,

        /// Total number of payload bytes sent on this [RtcPeerConnection], i.e.
        /// not including headers or padding.
        ///
        /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
        bytes_sent: Option<u64>,

        /// Total number of bytes received on this [RtcPeerConnection], i.e. not
        /// including headers or padding.
        ///
        /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
        bytes_received: Option<u64>,
    },

    /// Statistics for the remote endpoint's inbound [RTP] stream
    /// corresponding to an outbound stream that is currently sent with
    /// [RtcPeerConnection] object.
    ///
    /// It is measured at the remote endpoint and reported in a RtcP
    /// Receiver Report (RR) or RtcP Extended Report (XR).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcRemoteInboundRtpStreamStats {
        /// [`localId`] is used for looking up the local
        /// [RtcOutboundRtpStreamStats] object for the same SSRC.
        ///
        /// [`localId`]: https://tinyurl.com/r8uhbo9
        /// [RtcOutBoundRtpStreamStats]: https://tinyurl.com/r6f5vqg
        local_id: Option<String>,

        /// Estimated round trip time for this SSRC based on
        /// the RtcP timestamps in
        /// the RtcP Receiver Report (RR) and measured in seconds.
        /// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
        /// If no RtcP Receiver Report
        /// is received with a DLSR value other than 0, the round trip time is
        /// left undefined.
        ///
        /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
        round_trip_time: Option<f64>,

        /// Fraction packet loss reported for this SSRC.
        /// Calculated as defined in
        /// [Section 6.4.1 of RFC 3550][1] and [Appendix A.3][2].
        ///
        /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
        /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
        fraction_lost: Option<f64>,

        /// Total number of RtcP RR blocks received for this SSRC that contain a
        /// valid round trip time. This counter will increment if the
        /// [`roundTripTime`] is undefined.
        ///
        /// [`roundTripTime`]: https://tinyurl.com/ssg83hq
        round_trip_time_measurements: Option<i32>,
    },

    /// Statistics for the remote endpoint's outbound [RTP] stream
    /// corresponding to an inbound stream that is currently received with
    /// [RtcPeerConnection] object.
    ///
    /// It is measured at the remote endpoint and reported in an RtcP
    /// Sender Report (SR).
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    /// [RtcPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
    RtcRemoteOutboundRtpStreamStats {
        /// [`localId`] is used for looking up the local
        /// [RtcInboundRtpStreamStats][1] object for the same SSRC.
        ///
        /// [`localId`]: https://tinyurl.com/vu9tb2e
        /// [1]: https://w3.org/TR/webrtc-stats/#dom-rtcinboundrtpstreamstats
        local_id: Option<String>,

        /// [`remoteTimestamp`] (as [HIGHRES-TIME]) is the remote timestamp at
        /// which these statistics were sent by the remote endpoint. This
        /// differs from timestamp, which represents the time at which the
        /// statistics were generated or received by the local endpoint. The
        /// [`remoteTimestamp`], if present, is derived from the NTP timestamp
        /// in an RtcP Sender Report (SR) block, which reflects the remote
        /// endpoint's clock. That clock may not be synchronized with the local
        /// clock.
        ///
        /// [`remoteTimestamp`]: https://tinyurl.com/rzlhs87
        /// [HIGRES-TIME]: https://w3.org/TR/webrtc-stats/#bib-highres-time
        remote_timestamp: Option<f64>,

        /// Total number of RtcP SR blocks sent for this SSRC.
        reports_sent: Option<u64>,
    },

    /// Unimplemented stats.
    Unimplemented,
}

#[allow(clippy::too_many_lines)]
impl TryFrom<webrtc::RTCStatsWrap> for RtcStatsType {
    type Error = anyhow::Error;
    fn try_from(stats: webrtc::RTCStatsWrap) -> anyhow::Result<Self> {
        use webrtc::RTCStatsType as T;
        let res = match stats.kind {
            T::RTCIceCandidatePairStats => {
                let mut stats =
                    webrtc::cast_to_rtc_ice_candidate_pair_stats(stats.stats)?;

                RtcStatsType::RtcIceCandidatePairStats {
                    state: stats.state,
                    nominated: stats.nominated.take(),
                    bytes_sent: stats.bytes_sent.take(),
                    bytes_received: stats.bytes_received.take(),
                    total_round_trip_time: stats.total_round_trip_time.take(),
                    current_round_trip_time: stats
                        .current_round_trip_time
                        .take(),
                    available_outgoing_bitrate: stats
                        .available_outgoing_bitrate
                        .take(),
                }
            }
            T::RTCIceCandidateStats => {
                let mut stats =
                    webrtc::cast_to_rtc_ice_candidate_stats(stats.stats)?;
                let is_remote = stats.is_remote;
                let protocol = stats.protocol.take().unwrap();
                let protocol = Protocol::try_from(protocol.as_ref())?;
                let stats = IceCandidateStats {
                    transport_id: stats.transport_id.take(),
                    address: stats.address.take(),
                    port: stats.port.take(),
                    protocol,
                    candidate_type: stats.candidate_type,
                    priority: stats.priority.take(),
                    url: stats.url.take(),
                };
                if is_remote {
                    RtcStatsType::RtcIceCandidateStats(
                        RtcIceCandidateStats::RtcRemoteIceCandidateStats(stats),
                    )
                } else {
                    RtcStatsType::RtcIceCandidateStats(
                        RtcIceCandidateStats::RtcLocalIceCandidateStats(stats),
                    )
                }
            }
            T::RTCInboundRTPStreamStats => {
                let mut stats =
                    webrtc::cast_to_rtc_inbound_rtp_stream_stats(stats.stats)?;

                let media_type =
                    if let webrtc::MediaKind::Audio = stats.media_type {
                        RtcInboundRtpStreamMediaType::Audio {
                            total_samples_received: stats
                                .total_samples_received
                                .take(),
                            concealed_samples: stats.concealed_samples.take(),
                            silent_concealed_samples: stats
                                .silent_concealed_samples
                                .take(),
                            audio_level: stats.audio_level.take(),
                            total_audio_energy: stats.total_audio_energy.take(),
                            total_samples_duration: stats
                                .total_samples_duration
                                .take(),
                        }
                    } else {
                        RtcInboundRtpStreamMediaType::Video {
                            frames_decoded: stats.frames_decoded.take(),
                            key_frames_decoded: stats.key_frames_decoded.take(),
                            frame_width: stats.frame_width.take(),
                            frame_height: stats.frame_height.take(),
                            total_inter_frame_delay: stats
                                .total_inter_frame_delay
                                .take(),
                            frames_per_second: stats.frames_per_second.take(),
                            frame_bit_depth: stats.frame_bit_depth.take(),
                            fir_count: stats.fir_count.take(),
                            pli_count: stats.pli_count.take(),
                            concealment_events: stats.concealment_events.take(),
                            frames_received: stats.frames_received.take(),
                        }
                    };

                RtcStatsType::RtcInboundRTPStreamStats {
                    remote_id: stats.remote_id.take(),
                    bytes_received: stats.bytes_received.take(),
                    packets_received: stats.packets_received.take(),
                    total_decode_time: stats.total_decode_time.take(),
                    jitter_buffer_emitted_count: stats
                        .jitter_buffer_emitted_count
                        .take(),
                    media_type: Some(media_type),
                }
            }
            T::RTCMediaSourceStats => {
                let mut stats =
                    webrtc::cast_to_rtc_media_source_stats(stats.stats)?;
                let track_identifier = stats.track_identifier.take();
                let kind = if let webrtc::MediaKind::Audio = stats.kind {
                    let mut stats =
                        webrtc::cast_to_rtc_audio_source_stats(stats.stats)?;
                    RtcMediaSourceStatsMediaType::RtcAudioSourceStats {
                        audio_level: stats.audio_level.take(),
                        total_audio_energy: stats.total_audio_energy.take(),
                        total_samples_duration: stats
                            .total_samples_duration
                            .take(),
                        echo_return_loss: stats.echo_return_loss.take(),
                        echo_return_loss_enhancement: stats
                            .echo_return_loss_enhancement
                            .take(),
                    }
                } else {
                    let mut stats =
                        webrtc::cast_to_rtc_video_source_stats(stats.stats)?;
                    RtcMediaSourceStatsMediaType::RtcVideoSourceStats {
                        width: stats.width.take(),
                        height: stats.height.take(),
                        frames: stats.frames.take(),
                        frames_per_second: stats.frames_per_second.take(),
                    }
                };
                RtcStatsType::RtcMediaSourceStats {
                    track_identifier,
                    kind,
                }
            }
            T::RTCOutboundRTPStreamStats => {
                let mut stats =
                    webrtc::cast_to_rtc_outbound_rtp_stream_stats(stats.stats)?;
                let kind = if let webrtc::MediaKind::Audio = stats.kind {
                    RtcOutboundRTPStreamStatsMediaType::Audio {}
                } else {
                    RtcOutboundRTPStreamStatsMediaType::Video {
                        frame_width: stats.frame_width.take(),
                        frame_height: stats.frame_height.take(),
                        frames_per_second: stats.frames_per_second.take(),
                    }
                };
                RtcStatsType::RtcOutboundRTPStreamStats {
                    track_id: stats.track_id.take(),
                    kind,
                    bytes_sent: stats.bytes_sent.take(),
                    packets_sent: stats.packets_sent.take(),
                    media_source_id: stats.media_source_id.take(),
                }
            }
            T::RTCRemoteInboundRtpStreamStats => {
                let mut stats =
                    webrtc::cast_to_rtc_remote_inbound_rtp_stream_stats(
                        stats.stats,
                    )?;
                RtcStatsType::RtcRemoteInboundRtpStreamStats {
                    local_id: stats.local_id.take(),
                    round_trip_time: stats.round_trip_time.take(),
                    fraction_lost: stats.fraction_lost.take(),
                    round_trip_time_measurements: stats
                        .round_trip_time_measurements
                        .take(),
                }
            }
            T::RTCRemoteOutboundRtpStreamStats => {
                let mut stats =
                    webrtc::cast_to_rtc_remote_outbound_rtp_stream_stats(
                        stats.stats,
                    )?;
                RtcStatsType::RtcRemoteOutboundRtpStreamStats {
                    local_id: stats.local_id.take(),
                    remote_timestamp: stats.remote_timestamp.take(),
                    reports_sent: stats.reports_sent.take(),
                }
            }
            T::RTCTransportStats => {
                let mut stats =
                    webrtc::cast_to_rtc_transport_stats(stats.stats)?;
                RtcStatsType::RtcTransportStats {
                    packets_sent: stats.packets_sent.take(),
                    packets_received: stats.packets_received.take(),
                    bytes_sent: stats.bytes_sent.take(),
                    bytes_received: stats.bytes_received.take(),
                }
            }
            _ => RtcStatsType::Unimplemented,
        };
        Ok(res)
    }
}

/// Represents the [stats object] constructed by inspecting a specific
/// [monitored object].
///
/// [Full doc on W3C][1].
///
/// [stats object]: https://w3.org/TR/webrtc-stats/#dfn-stats-object
/// [monitored object]: https://w3.org/TR/webrtc-stats/#dfn-monitored-object
/// [1]: https://w3.org/TR/webrtc#rtcstats-dictionary
pub struct RtcStats {
    /// Unique ID that is associated with the object that was inspected to
    /// produce this [RtcStats] object.
    ///
    /// [RtcStats]: https://w3.org/TR/webrtc#dom-rtcstats
    pub id: String,

    /// Timestamp associated with this object.
    ///
    /// The time is relative to the UNIX epoch (Jan 1, 1970, UTC).
    ///
    /// For statistics that came from a remote source (e.g., from received RtcP
    /// packets), timestamp represents the time at which the information
    /// arrived at the local endpoint. The remote timestamp can be found in an
    /// additional field in an [`RtcStat`]-derived dictionary, if applicable.
    pub timestamp_us: i64,

    /// Actual stats of this [`RtcStat`].
    ///
    /// All possible stats are described in the [`RtcStatsType`] enum.
    pub kind: RtcStatsType,
}

impl From<webrtc::RTCStatsWrap> for RtcStats {
    fn from(stats: webrtc::RTCStatsWrap) -> Self {
        let id = stats.id.clone();
        let timestamp_us = stats.timestamp_us;
        let kind = RtcStatsType::try_from(stats).unwrap();

        Self {
            id,
            timestamp_us,
            kind,
        }
    }
}

// A collection of [`RtcStats`].
#[derive(From)]
pub struct RtcStatsReport(UniquePtr<webrtc::RTCStatsReport>);

impl RtcStatsReport {
    #[must_use]
    pub fn get_stats(&self) -> Vec<RtcStats> {
        webrtc::rtc_stats_report_get_stats(&self.0)
            .into_iter()
            .map(RtcStats::from)
            .collect()
    }
}
