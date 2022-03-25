use crate::{cpp_api, Webrtc};
use anyhow::bail;
use cxx::UniquePtr;

use flutter_rust_bridge::{StreamSink, SyncReturn};
use libwebrtc_sys::{self as sys};
use std::sync::{
    mpsc::{self, Receiver, Sender},
    Mutex,
};

static TIMEOUT: std::time::Duration = std::time::Duration::from_secs(1);

lazy_static::lazy_static! {
    static ref WEBRTC: Mutex<Webrtc> = Mutex::new(Webrtc::new().unwrap());
}

pub enum TrackEvent {
    Ended,
}

pub enum IceGatheringState {
    New,
    Gathering,
    Complete,
}

impl From<sys::IceGatheringState> for IceGatheringState {
    fn from(state: sys::IceGatheringState) -> Self {
        match state {
            sys::IceGatheringState::kIceGatheringNew => IceGatheringState::New,
            sys::IceGatheringState::kIceGatheringGathering => IceGatheringState::Gathering,
            sys::IceGatheringState::kIceGatheringComplete => IceGatheringState::Complete,
            _ => unreachable!(),
        }
    }
}

pub enum PeerConnectionEvent {
    OnIceCandidate {
        sdp_mid: String,
        sdp_mline_index: i64,
        candidate: String,
    },
    OnIceGatheringStateChange(IceGatheringState),
    OnIceCandidateError {
        address: String,
        port: i64,
        url: String,
        error_code: i64,
        error_text: String,
    },
    OnNegotiationNeeded,
    OnSignallingChange(SignalingState),
    OnIceConnectionStateChange(IceConnectionState),
    OnConnectionStateChange(PeerConnectionState),
    OnTrack(RtcTrackEvent),
}

pub enum SignalingState {
    Stable,
    HaveLocalOffer,
    HaveLocalPrAnswer,
    HaveRemoteOffer,
    HaveRemotePrAnswer,
    Closed,
}

impl From<sys::SignalingState> for SignalingState {
    fn from(state: sys::SignalingState) -> Self {
        match state {
            sys::SignalingState::kStable => SignalingState::Stable,
            sys::SignalingState::kHaveLocalOffer => SignalingState::HaveLocalOffer,
            sys::SignalingState::kHaveLocalPrAnswer => SignalingState::HaveLocalPrAnswer,
            sys::SignalingState::kHaveRemoteOffer => SignalingState::HaveRemoteOffer,
            sys::SignalingState::kHaveRemotePrAnswer => SignalingState::HaveRemotePrAnswer,
            sys::SignalingState::kClosed => SignalingState::Closed,
            _ => unreachable!(),
        }
    }
}

pub enum IceConnectionState {
    New,
    Checking,
    Connected,
    Completed,
    Failed,
    Disconnected,
    Closed,
}

impl From<sys::IceConnectionState> for IceConnectionState {
    fn from(state: sys::IceConnectionState) -> Self {
        match state {
            sys::IceConnectionState::kIceConnectionNew => IceConnectionState::New,
            sys::IceConnectionState::kIceConnectionChecking => IceConnectionState::Checking,
            sys::IceConnectionState::kIceConnectionConnected => {
                IceConnectionState::Connected
            }
            sys::IceConnectionState::kIceConnectionCompleted => {
                IceConnectionState::Completed
            }
            sys::IceConnectionState::kIceConnectionFailed => IceConnectionState::Failed,
            sys::IceConnectionState::kIceConnectionDisconnected => {
                IceConnectionState::Disconnected
            }
            sys::IceConnectionState::kIceConnectionClosed => IceConnectionState::Closed,
            _ => unreachable!(),
        }
    }
}

pub enum PeerConnectionState {
    New,
    Connecting,
    Connected,
    Disconnected,
    Failed,
    Closed,
}

impl From<sys::PeerConnectionState> for PeerConnectionState {
    fn from(state: sys::PeerConnectionState) -> Self {
        match state {
            sys::PeerConnectionState::kNew => PeerConnectionState::New,
            sys::PeerConnectionState::kConnecting => PeerConnectionState::Connecting,
            sys::PeerConnectionState::kConnected => PeerConnectionState::Connected,
            sys::PeerConnectionState::kDisconnected => PeerConnectionState::Disconnected,
            sys::PeerConnectionState::kFailed => PeerConnectionState::Failed,
            sys::PeerConnectionState::kClosed => PeerConnectionState::Closed,
            _ => unreachable!(),
        }
    }
}

/// Possible kinds of media devices.
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum MediaDeviceKind {
    AudioInput,
    AudioOutput,
    VideoInput,
}

/// [RTCRtpTransceiverDirection][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverdirection
#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum RtpTransceiverDirection {
    SendRecv,
    SendOnly,
    RecvOnly,
    Inactive,
    Stopped,
}

impl From<sys::RtpTransceiverDirection> for RtpTransceiverDirection {
    fn from(state: sys::RtpTransceiverDirection) -> Self {
        match state {
            sys::RtpTransceiverDirection::kSendRecv => Self::SendRecv,
            sys::RtpTransceiverDirection::kSendOnly => Self::SendOnly,
            sys::RtpTransceiverDirection::kRecvOnly => Self::RecvOnly,
            sys::RtpTransceiverDirection::kInactive => Self::Inactive,
            sys::RtpTransceiverDirection::kStopped => Self::Stopped,
            _ => unreachable!(),
        }
    }
}

impl From<RtpTransceiverDirection> for sys::RtpTransceiverDirection {
    fn from(state: RtpTransceiverDirection) -> Self {
        match state {
            RtpTransceiverDirection::SendRecv => Self::kSendRecv,
            RtpTransceiverDirection::SendOnly => Self::kSendOnly,
            RtpTransceiverDirection::RecvOnly => Self::kRecvOnly,
            RtpTransceiverDirection::Inactive => Self::kInactive,
            RtpTransceiverDirection::Stopped => Self::kStopped,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum MediaType {
    Audio,
    Video,
}

impl From<MediaType> for sys::MediaType {
    fn from(state: MediaType) -> Self {
        match state {
            MediaType::Audio => sys::MediaType::MEDIA_TYPE_AUDIO,
            MediaType::Video => sys::MediaType::MEDIA_TYPE_VIDEO,
        }
    }
}

/// [RTCSdpType] representation.
///
/// [RTCSdpType]: https://w3.org/TR/webrtc#dom-rtcsdptype
#[derive(Debug, Eq, Hash, PartialEq)]
pub enum SdpType {
    /// [RTCSdpType.offer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-offer
    Offer,

    /// [RTCSdpType.pranswer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-pranswer
    PrAnswer,

    /// [RTCSdpType.answer][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-answer
    Answer,

    /// [RTCSdpType.rollback][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcsdptype-rollback
    Rollback,
}

impl From<SdpType> for sys::SdpType {
    fn from(kind: SdpType) -> Self {
        match kind {
            SdpType::Offer => sys::SdpType::kOffer,
            SdpType::PrAnswer => sys::SdpType::kPrAnswer,
            SdpType::Answer => sys::SdpType::kAnswer,
            SdpType::Rollback => sys::SdpType::kRollback,
        }
    }
}

impl From<sys::SdpType> for SdpType {
    fn from(kind: sys::SdpType) -> Self {
        match kind {
            sys::SdpType::kOffer => SdpType::Offer,
            sys::SdpType::kPrAnswer => SdpType::PrAnswer,
            sys::SdpType::kAnswer => SdpType::Answer,
            sys::SdpType::kRollback => SdpType::Rollback,
            _ => unreachable!(),
        }
    }
}

pub struct RtcSessionDescription {
    pub sdp: String,
    pub kind: SdpType,
}

impl RtcSessionDescription {
    pub fn new(sdp: String, kind: sys::SdpType) -> Self {
        Self {
            sdp,
            kind: kind.into(),
        }
    }
}

/// Information describing a single media input or output device.
#[derive(Debug)]
pub struct MediaDeviceInfo {
    /// Unique identifier for the represented device.
    pub device_id: String,

    /// Kind of the represented device.
    pub kind: MediaDeviceKind,

    /// Label describing the represented device.
    pub label: String,
}

/// The [MediaStreamConstraints] is used to instruct what sort of
/// [`MediaStreamTrack`]s to include in the [`MediaStream`] returned by
/// [`Webrtc::get_users_media()`].
pub struct MediaStreamConstraints {
    /// Specifies the nature and settings of the video [`MediaStreamTrack`].
    pub audio: Option<AudioConstraints>,
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub video: Option<VideoConstraints>,
}

/// Specifies the nature and settings of the video [`MediaStreamTrack`]
/// returned by [`Webrtc::get_users_media()`].
pub struct VideoConstraints {
    /// The identifier of the device generating the content of the
    /// [`MediaStreamTrack`]. First device will be chosen if empty
    /// [`String`] is provided.
    pub device_id: String,

    /// The width, in pixels.
    pub width: u32,

    /// The height, in pixels.
    pub height: u32,

    /// The exact frame rate (frames per second).
    pub frame_rate: u32,

    pub is_display: bool,
}

/// Specifies the nature and settings of the audio [`MediaStreamTrack`]
/// returned by [`Webrtc::get_users_media()`].
pub struct AudioConstraints {
    /// The identifier of the device generating the content of the
    /// [`MediaStreamTrack`]. First device will be chosen if empty
    /// [`String`] is provided.
    ///
    /// __NOTE__: There can be only one active recording device at a time,
    /// so changing device will affect all previously obtained audio tracks.
    pub device_id: String,
}

/// Representation of a single media track within a [`MediaStream`].
///
/// Typically, these are audio or video tracks, but other track types may
/// exist as well.
pub struct MediaStreamTrack {
    /// Unique identifier (GUID) for the track
    pub id: u64,

    /// Label that identifies the track source, as in "internal microphone".
    pub device_id: String,

    /// [`MediaType`] of the current [`MediaStreamTrack`].
    pub kind: MediaType,

    /// The `enabled` property on the [`MediaStreamTrack`] interface is a
    /// `enabled` value which is `true` if the track is allowed to render
    /// the source stream or `false` if it is not. This can be used to
    /// intentionally mute a track.
    pub enabled: bool,
}

/// Representation of a permanent pair of an [RTCRtpSender] and an
/// [RTCRtpReceiver], along with some shared state.
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub struct RtcRtpTransceiver {
    /// ID of the [`PeerConnection`] that this [`RtcRtpTransceiver`] belongs to.
    pub peer_id: u64,

    /// ID of this [`RtcRtpTransceiver`].
    ///
    /// It's not unique across all possible [`RtcRtpTransceiver`]s, but only
    /// within a specific peer.
    pub index: u64,

    /// [Negotiated media ID (mid)][1] which the local and remote peers have
    /// agreed upon to uniquely identify the [`MediaStream`]'s pairing of
    /// sender and receiver.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub mid: Option<String>,

    /// Preferred [`direction`][1] of this [`RtcRtpTransceiver`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    pub direction: RtpTransceiverDirection,
}

/// [`RtcTrackEvent`] representing a track event, sent when a new
/// [`MediaStreamTrack`] is added to an [`RtcRtpTransceiver`] as part of a
/// [`PeerConnection`].
pub struct RtcTrackEvent {
    /// [`MediaStreamTrack`] associated with the [RTCRtpReceiver] identified
    /// by the receiver.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    pub track: MediaStreamTrack,

    /// [`RtcRtpTransceiver`] object associated with the event.
    pub transceiver: RtcRtpTransceiver,
}

/// [`PeerConnection`]'s configuration.
pub struct RtcConfiguration {
    /// [iceTransportPolicy][1] configuration.
    ///
    /// Indicates which candidates the [ICE Agent][2] is allowed to use.
    ///
    /// [1]: https://tinyurl.com/icetransportpolicy
    /// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
    pub ice_transport_policy: IceTransportsType,

    /// [bundlePolicy][1] configuration.
    ///
    /// Indicates which media-bundling policy to use when gathering ICE
    /// candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-bundlepolicy
    pub bundle_policy: BundlePolicy,

    /// [iceServers][1] configuration.
    ///
    /// An array of objects describing servers available to be used by ICE,
    /// such as STUN and TURN servers.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-iceservers
    pub ice_servers: Vec<RtcIceServer>,
}

/// [RTCIceTransportPolicy][1] representation.
///
/// It defines an ICE candidate policy the [ICE Agent][2] uses to surface
/// the permitted candidates to the application. Only these candidates will
/// be used for connectivity checks.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy
/// [2]: https://w3.org/TR/webrtc#dfn-ice-agent
#[derive(Debug, Eq, Hash, PartialEq)]
pub enum IceTransportsType {
    /// [RTCIceTransportPolicy.relay][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-relay
    Relay,

    /// ICE Agent can't use `typ host` candidates when this value is
    /// specified.
    ///
    /// Non-spec-compliant variant.
    NoHost,

    /// [RTCIceTransportPolicy.all][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportpolicy-all
    All,
}

impl From<IceTransportsType> for sys::IceTransportsType {
    fn from(kind: IceTransportsType) -> Self {
        match kind {
            IceTransportsType::Relay => Self::kRelay,
            IceTransportsType::NoHost => Self::kNoHost,
            IceTransportsType::All => Self::kAll,
        }
    }
}

/// [RTCBundlePolicy][1] representation.
///
/// Affects which media tracks are negotiated if the remote endpoint is not
/// bundle-aware, and what ICE candidates are gathered. If the remote
/// endpoint is bundle-aware, all media tracks and data channels are bundled
/// onto the same transport.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(i32)]
pub enum BundlePolicy {
    /// [RTCBundlePolicy.balanced][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-balanced
    Balanced,

    /// [RTCBundlePolicy.max-bundle][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-bundle
    MaxBundle,

    /// [RTCBundlePolicy.max-compat][1] representation.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcbundlepolicy-max-compat
    MaxCompat,
}

impl From<BundlePolicy> for sys::BundlePolicy {
    fn from(policy: BundlePolicy) -> Self {
        match policy {
            BundlePolicy::Balanced => Self::kBundlePolicyBalanced,
            BundlePolicy::MaxBundle => Self::kBundlePolicyMaxBundle,
            BundlePolicy::MaxCompat => Self::kBundlePolicyMaxCompat,
        }
    }
}

/// Describes the STUN and TURN servers that can be used by the
/// [ICE Agent][1] to establish a connection with a peer.
///
/// [1]: https://w3.org/TR/webrtc#dfn-ice-agent
pub struct RtcIceServer {
    /// STUN or TURN URI(s).
    pub urls: Vec<String>,

    /// If this [`RtcIceServer`] object represents a TURN server, then this
    /// attribute specifies the [username][1] to use with that TURN server.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-username
    pub username: String,

    /// If this [`RtcIceServer`] object represents a TURN server, then this
    /// attribute specifies the [credential][1] to use with that TURN
    /// server.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtciceserver-credential
    pub credential: String,
}

/// Returns a list of all available media input and output devices, such
/// as microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
}

/// Creates a new [`PeerConnection`] and returns its ID.
///
/// Writes an error to the provided `err`, if any.
pub fn create_peer_connection(
    cb: StreamSink<PeerConnectionEvent>,
    configuration: RtcConfiguration,
    id: u64,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .create_peer_connection(cb, configuration, id)
}

/// Initiates the creation of a SDP offer for the purpose of starting
/// a new WebRTC connection to a remote peer.
///
/// Returns an empty [`String`] if operation succeeds or an error
/// otherwise.
pub fn create_offer(
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx): (
        Sender<anyhow::Result<RtcSessionDescription>>,
        Receiver<anyhow::Result<RtcSessionDescription>>,
    ) = mpsc::channel();

    WEBRTC.lock().unwrap().create_offer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        tx,
    )?;

    rx.recv_timeout(TIMEOUT)?
}

/// Creates a SDP answer to an offer received from a remote peer during
/// the offer/answer negotiation of a WebRTC connection.
///
/// Returns an empty [`String`] in operation succeeds or an error
/// otherwise.
pub fn create_answer(
    peer_id: u64,
    voice_activity_detection: bool,
    ice_restart: bool,
    use_rtp_mux: bool,
) -> anyhow::Result<RtcSessionDescription> {
    let (tx, rx): (
        Sender<anyhow::Result<RtcSessionDescription>>,
        Receiver<anyhow::Result<RtcSessionDescription>>,
    ) = mpsc::channel();

    WEBRTC.lock().unwrap().create_answer(
        peer_id,
        voice_activity_detection,
        ice_restart,
        use_rtp_mux,
        tx,
    )?;

    rx.recv_timeout(TIMEOUT)?
}

/// Changes the local description associated with the connection.
///
/// Returns an empty [`String`] in operation succeeds or an error
/// otherwise.
pub fn set_local_description(
    peer_id: u64,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    let (tx, rx): (Sender<anyhow::Result<()>>, Receiver<anyhow::Result<()>>) =
        mpsc::channel();

    WEBRTC
        .lock()
        .unwrap()
        .set_local_description(peer_id, kind.into(), sdp, tx)?;

    rx.recv_timeout(TIMEOUT)?
}

/// Sets the specified session description as the remote peer's current
/// offer or answer.
///
/// Returns an empty [`String`] in operation succeeds or an error
/// otherwise.
pub fn set_remote_description(
    peer_id: u64,
    kind: SdpType,
    sdp: String,
) -> anyhow::Result<()> {
    let (tx, rx): (Sender<anyhow::Result<()>>, Receiver<anyhow::Result<()>>) =
        mpsc::channel();

    WEBRTC
        .lock()
        .unwrap()
        .set_remote_description(peer_id, kind.into(), sdp, tx)?;

    rx.recv_timeout(TIMEOUT)?
}

/// Creates a new [`RtcRtpTransceiver`] and adds it to the set of
/// transceivers of the specified [`PeerConnection`].
pub fn add_transceiver(
    peer_id: u64,
    media_type: MediaType,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<RtcRtpTransceiver> {
    WEBRTC
        .lock()
        .unwrap()
        .add_transceiver(peer_id, media_type.into(), direction.into())
}

/// Returns a sequence of [`RtcRtpTransceiver`] objects representing
/// the RTP transceivers currently attached to the specified
/// [`PeerConnection`].
pub fn get_transceivers(peer_id: u64) -> anyhow::Result<Vec<RtcRtpTransceiver>> {
    WEBRTC.lock().unwrap().get_transceivers(peer_id)
}

/// Changes the preferred `direction` of the specified
/// [`RtcRtpTransceiver`].
pub fn set_transceiver_direction(
    peer_id: u64,
    transceiver_id: u64,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .set_transceiver_direction(peer_id, transceiver_id, direction)
}

/// Returns the [Negotiated media ID (mid)][1] of the specified
/// [`RtcRtpTransceiver`].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
pub fn get_transceiver_mid(
    peer_id: u64,
    transceiver_id: u64,
) -> anyhow::Result<Option<String>> {
    WEBRTC
        .lock()
        .unwrap()
        .get_transceiver_mid(peer_id, transceiver_id)
}

/// Returns the preferred direction of the specified
/// [`RtcRtpTransceiver`].
pub fn get_transceiver_direction(
    peer_id: u64,
    transceiver_id: u64,
) -> anyhow::Result<RtpTransceiverDirection> {
    WEBRTC
        .lock()
        .unwrap()
        .get_transceiver_direction(peer_id, transceiver_id)
        .map(Into::into)
}

/// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping,
/// unless it's already stopped.
///
/// This will immediately cause the transceiver's sender to no longer
/// send, and its receiver to no longer receive.
pub fn stop_transceiver(peer_id: u64, transceiver_id: u64) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .stop_transceiver(peer_id, transceiver_id)
}

/// Replaces the specified [`AudioTrack`] (or [`VideoTrack`]) on
/// the [`sys::Transceiver`]'s `sender`.
pub fn sender_replace_track(
    peer_id: u64,
    transceiver_id: u64,
    track_id: Option<u64>,
) -> anyhow::Result<()> {
    WEBRTC
        .lock()
        .unwrap()
        .sender_replace_track(peer_id, transceiver_id, track_id)
}

/// Adds the new ICE candidate to the given [`PeerConnection`].
pub fn add_ice_candidate(
    peer_id: u64,
    candidate: String,
    sdp_mid: String,
    sdp_mline_index: i32,
) -> anyhow::Result<()> {
    let (tx, rx): (Sender<anyhow::Result<()>>, Receiver<anyhow::Result<()>>) =
        mpsc::channel();

    WEBRTC.lock().unwrap().add_ice_candidate(
        peer_id,
        &candidate,
        &sdp_mid,
        sdp_mline_index,
        tx,
    )?;

    rx.recv_timeout(TIMEOUT).unwrap()
}

/// Tells the [`PeerConnection`] that ICE should be restarted.
pub fn restart_ice(peer_id: u64) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().restart_ice(peer_id)
}

/// Closes the [`PeerConnection`].
pub fn dispose_peer_connection(peer_id: u64) {
    WEBRTC.lock().unwrap().dispose_peer_connection(peer_id);
}

/// Creates a [`MediaStream`] with tracks according to provided
/// [`MediaStreamConstraints`].
pub fn get_media(
    constraints: MediaStreamConstraints,
) -> anyhow::Result<Vec<MediaStreamTrack>> {
    WEBRTC.lock().unwrap().get_media(constraints)
}

pub fn set_audio_playout_device(device_id: String) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_audio_playout_device(device_id)
}

/// Disposes the specified [`MediaStreamTrack`].
pub fn dispose_track(track_id: u64) {
    WEBRTC.lock().unwrap().dispose_track(track_id);
}

/// Changes the [enabled][1] property of the media track by its ID.
///
/// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
pub fn set_track_enabled(track_id: u64, enabled: bool) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_track_enabled(track_id, enabled)
}

pub fn clone_track(track_id: u64) -> anyhow::Result<MediaStreamTrack> {
    WEBRTC.lock().unwrap().clone_track(track_id)
}

/// Registers an observer to the media track events.
pub fn register_track_observer(
    cb: StreamSink<TrackEvent>,
    track_id: u64,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().register_track_observer(track_id, cb)
}

/// Sets the provided [`OnDeviceChangeCallback`] as the callback to be
/// called whenever a set of available media devices changes.
///
/// Only one callback can be set at a time, so the previous one will be
/// dropped, if any.
pub fn set_on_device_changed(cb: StreamSink<()>) -> anyhow::Result<()> {
    // WEBRTC.lock().unwrap().set_on_device_changed(cb);

    Ok(())
}

/// Creates a new [`VideoSink`] attached to the specified media stream
/// backed by the provided [`OnFrameCallbackInterface`].
pub fn create_video_sink(sink_id: i64, track_id: u64, callback_ptr: u64) {
    let handler: *mut cpp_api::OnFrameCallbackInterface =
        unsafe { std::mem::transmute(callback_ptr) };
    let handler = unsafe { UniquePtr::from_raw(handler) };
    WEBRTC
        .lock()
        .unwrap()
        .create_video_sink(sink_id, track_id, handler);
}

/// Destroys the [`VideoSink`] by the given ID.
pub fn dispose_video_sink(sink_id: i64) -> SyncReturn<Vec<u8>> {
    WEBRTC.lock().unwrap().dispose_video_sink(sink_id);
    SyncReturn(vec![])
}

#[cfg(test)]
mod test {
    use std::thread;

    use super::Webrtc;

    #[test]
    fn webrtc_drops_on_another_thread() {
        let webrtc = thread::spawn(|| Webrtc::new()).join().unwrap().unwrap();

        let temp = webrtc.audio_device_module.playout_devices();
        println!("{:?}", temp);
        drop(webrtc);
    }
}
