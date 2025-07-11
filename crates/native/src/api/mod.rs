//! API surface and implementation for Flutter.

pub mod media_info;
pub mod peer;
pub mod stats;

#[cfg(doc)]
use std::sync::mpsc;
use std::{
    sync::{
        Arc, LazyLock, Mutex,
        atomic::{AtomicBool, Ordering},
    },
    time::Duration,
};

use flutter_rust_bridge::for_generated::FLUTTER_RUST_BRIDGE_RUNTIME_VERSION;
use libwebrtc_sys as sys;

pub use self::{
    media_info::{MediaDeviceInfo, MediaDeviceKind, MediaDisplayInfo},
    peer::{
        BundlePolicy, IceConnectionState, IceGatheringState, IceTransportsType,
        PeerConnectionEvent, PeerConnectionState, RtcConfiguration,
        RtcIceServer, RtcSessionDescription, RtcTrackEvent, SdpType,
        SignalingState, VideoCodec, VideoCodecInfo, add_ice_candidate,
        create_answer, create_offer, create_peer_connection,
        dispose_peer_connection, restart_ice, set_local_description,
        set_remote_description, video_decoders, video_encoders,
    },
    stats::{
        CandidateType, IceCandidateStats, IceRole, Protocol,
        RtcIceCandidateStats, RtcInboundRtpStreamMediaType,
        RtcMediaSourceStatsMediaType, RtcOutboundRtpStreamStatsMediaType,
        RtcStats, RtcStatsIceCandidatePairState, RtcStatsType, get_peer_stats,
    },
};
// Re-exporting since it is used in the generated code.
pub use crate::{
    PeerConnection, RtpEncodingParameters, RtpParameters, RtpTransceiver,
    renderer::TextureEvent,
};
use crate::{
    Webrtc, devices,
    frb::{FrbHandler, new_frb_handler},
    frb_generated::{
        FLUTTER_RUST_BRIDGE_CODEGEN_VERSION, RustOpaque, StreamSink,
    },
    media::TrackOrigin,
    pc::PeerConnectionId,
    renderer::FrameHandler,
};

/// Custom [`Handler`] for executing Rust code called from Dart.
///
/// [`Handler`]: flutter_rust_bridge::Handler
// Must be named `FLUTTER_RUST_BRIDGE_HANDLER` for `flutter_rust_bridge` to
// discover it.
pub static FLUTTER_RUST_BRIDGE_HANDLER: LazyLock<FrbHandler> =
    LazyLock::new(|| {
        const {
            if !crate::str_eq(
                FLUTTER_RUST_BRIDGE_CODEGEN_VERSION,
                FLUTTER_RUST_BRIDGE_RUNTIME_VERSION,
            ) {
                panic!("`flutter_rust_bridge` versions mismatch");
            }
        }

        new_frb_handler()
    });

pub(crate) static WEBRTC: LazyLock<Mutex<Webrtc>> =
    LazyLock::new(|| Mutex::new(Webrtc::new().unwrap()));

/// Timeout for [`mpsc::Receiver::recv_timeout()`] operations.
pub static RX_TIMEOUT: Duration = Duration::from_secs(5);

/// Indicator whether application is configured to use fake media devices.
static FAKE_MEDIA: AtomicBool = AtomicBool::new(false);

/// [MediaStreamTrack.kind][1] representation.
///
/// [1]: https://w3.org/TR/mediacapture-streams#dfn-kind
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackKind {
    /// Audio track.
    Audio,

    /// Video track.
    Video,
}

impl From<sys::TrackKind> for TrackKind {
    fn from(kind: sys::TrackKind) -> Self {
        match kind {
            sys::TrackKind::Audio => Self::Audio,
            sys::TrackKind::Video => Self::Video,
        }
    }
}

/// Representation of the static capabilities of an endpoint.
///
/// Applications can use these capabilities to construct [`RtpParameters`].
#[derive(Debug)]
pub struct RtpCapabilities {
    /// Supported codecs.
    pub codecs: Vec<RtpCodecCapability>,

    /// Supported [RTP] header extensions.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub header_extensions: Vec<RtpHeaderExtensionCapability>,
}

impl From<sys::RtpCapabilities> for RtpCapabilities {
    fn from(value: sys::RtpCapabilities) -> Self {
        Self {
            codecs: value.codecs().into_iter().map(Into::into).collect(),
            header_extensions: value
                .header_extensions()
                .into_iter()
                .map(Into::into)
                .collect(),
        }
    }
}

impl From<sys::RtcpFeedbackType> for RtcpFeedbackType {
    fn from(value: sys::RtcpFeedbackType) -> Self {
        match value {
            sys::RtcpFeedbackType::CCM => Self::Ccm,
            sys::RtcpFeedbackType::LNTF => Self::Lntf,
            sys::RtcpFeedbackType::NACK => Self::Nack,
            sys::RtcpFeedbackType::REMB => Self::Remb,
            sys::RtcpFeedbackType::TRANSPORT_CC => Self::TransportCC,
            _ => unreachable!(),
        }
    }
}
impl From<sys::RtcpFeedbackMessageType> for RtcpFeedbackMessageType {
    fn from(value: sys::RtcpFeedbackMessageType) -> Self {
        match value {
            sys::RtcpFeedbackMessageType::GENERIC_NACK => Self::GenericNACK,
            sys::RtcpFeedbackMessageType::PLI => Self::Pli,
            sys::RtcpFeedbackMessageType::FIR => Self::Fir,
            _ => unreachable!(),
        }
    }
}

/// [RTCP] feedback message intended to enable congestion control for
/// interactive real-time traffic using [RTP].
///
/// [RTCP]: https://en.wikipedia.org/wiki/RTP_Control_Protocol
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[derive(Debug)]
pub struct RtcpFeedback {
    /// Message type of this [`RtcpFeedback`].
    pub message_type: Option<RtcpFeedbackMessageType>,

    /// Kind of this [`RtcpFeedback`].
    pub kind: RtcpFeedbackType,
}

impl From<sys::RtcpFeedback> for RtcpFeedback {
    fn from(value: sys::RtcpFeedback) -> Self {
        Self {
            message_type: value.message_type().map(Into::into),
            kind: value.kind().into(),
        }
    }
}

/// [ScalabilityMode][0] representation.
///
/// [0]: https://tinyurl.com/35ae3mbe
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(u8)]
pub enum ScalabilityMode {
    /// [ScalabilityMode.L1T1][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L1T1*
    L1T1 = 0,

    /// [ScalabilityMode.L1T2][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L1T2*
    L1T2,

    /// [ScalabilityMode.L1T3][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L1T3*
    L1T3,

    /// [ScalabilityMode.L2T1][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T1*
    L2T1,

    /// [ScalabilityMode.L2T1h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T1*
    L2T1h,

    /// [ScalabilityMode.L2T1_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T1_KEY*
    L2t1Key,

    /// [ScalabilityMode.L2T2][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T2h*
    L2T2,

    /// [ScalabilityMode.L2T2h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T2*
    L2T2h,

    /// [ScalabilityMode.L2T2_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T2_KEY*
    L2T2Key,

    /// [ScalabilityMode.L2T2_KEY_SHIFT][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T2_KEY_SHIFT*
    L2T2KeyShift,

    /// [ScalabilityMode.L2T3][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T3*
    L2T3,

    /// [ScalabilityMode.L2T3h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T3*
    L2T3h,

    /// [ScalabilityMode.L2T3_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L2T3_KEY*
    L2T3Key,

    /// [ScalabilityMode.L3T1][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T1*
    L3T1,

    /// [ScalabilityMode.L3T1h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T1*
    L3T1h,

    /// [ScalabilityMode.L3T1_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T1_KEY*
    L3T1Key,

    /// [ScalabilityMode.L3T2][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T2h*
    L3T2,

    /// [ScalabilityMode.L3T2h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T2*
    L3T2h,

    /// [ScalabilityMode.L3T2_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T2_KEY*
    L3T2Key,

    /// [ScalabilityMode.kL3T3][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kL3T3*
    L3T3,

    /// [ScalabilityMode.kL3T3h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kL3T3*
    L3T3h,

    /// [ScalabilityMode.kL3T3_KEY][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#L3T3_KEY*
    L3T3Key,

    /// [ScalabilityMode.kS2T1][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kS2T1*
    S2T1,

    /// [ScalabilityMode.kS2T1h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kS2T1*
    S2T1h,

    /// [ScalabilityMode.kS2T2][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kS2T2*
    S2T2,

    /// [ScalabilityMode.kS2T2h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#kS2T2*
    S2T2h,

    /// [ScalabilityMode.S2T3][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S2T3h*
    S2T3,

    /// [ScalabilityMode.S2T3h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S2T3*
    S2T3h,

    /// [ScalabilityMode.S3T1h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T1*
    S3T1,

    /// [ScalabilityMode.S3T1h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T1*
    S3T1h,

    /// [ScalabilityMode.S3T2][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T2*
    S3T2,

    /// [ScalabilityMode.S3T2h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T2*
    S3T2h,

    /// [ScalabilityMode.S3T3][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T3*
    S3T3,

    /// [ScalabilityMode.S3T3h][0] mode.
    ///
    /// [0]: https://w3.org/TR/webrtc-svc#S3T3*
    S3T3h,
}

/// Possible types of an [`RtcpFeedback`].
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(i32)]
pub enum RtcpFeedbackType {
    /// Codec control messages.
    Ccm,

    /// Loss notification feedback.
    Lntf,

    /// Negative acknowledgemen.
    Nack,

    /// Receiver estimated maximum bitrate.
    Remb,

    /// Transport wide congestion control.
    TransportCC,
}

/// Possible message types of an [`RtcpFeedback`], when is type is
/// [`RtcpFeedbackType::Nack`] or [`RtcpFeedbackType::Ccm`].
#[derive(Debug, Eq, Hash, PartialEq)]
#[repr(i32)]
pub enum RtcpFeedbackMessageType {
    /// Equivalent to `{ type: "nack", parameter: undefined }` in ORTC.
    GenericNACK,

    /// Usable with [`RtcpFeedbackType::Nack`].
    Pli,

    /// Usable with [`RtcpFeedbackType::Ccm`].
    Fir,
}

impl From<sys::ScalabilityMode> for ScalabilityMode {
    fn from(value: sys::ScalabilityMode) -> Self {
        match value {
            sys::ScalabilityMode::kL1T1 => Self::L1T1,
            sys::ScalabilityMode::kL1T2 => Self::L1T2,
            sys::ScalabilityMode::kL1T3 => Self::L1T3,
            sys::ScalabilityMode::kL2T1 => Self::L2T1,
            sys::ScalabilityMode::kL2T1h => Self::L2T1h,
            sys::ScalabilityMode::kL2T1_KEY => Self::L2t1Key,
            sys::ScalabilityMode::kL2T2 => Self::L2T2,
            sys::ScalabilityMode::kL2T2h => Self::L2T2h,
            sys::ScalabilityMode::kL2T2_KEY => Self::L2T2Key,
            sys::ScalabilityMode::kL2T2_KEY_SHIFT => Self::L2T2KeyShift,
            sys::ScalabilityMode::kL2T3 => Self::L2T3,
            sys::ScalabilityMode::kL2T3h => Self::L2T3h,
            sys::ScalabilityMode::kL2T3_KEY => Self::L2T3Key,
            sys::ScalabilityMode::kL3T1 => Self::L3T1,
            sys::ScalabilityMode::kL3T1h => Self::L3T1h,
            sys::ScalabilityMode::kL3T1_KEY => Self::L3T1Key,
            sys::ScalabilityMode::kL3T2 => Self::L3T2,
            sys::ScalabilityMode::kL3T2h => Self::L3T2h,
            sys::ScalabilityMode::kL3T2_KEY => Self::L3T2Key,
            sys::ScalabilityMode::kL3T3 => Self::L3T3,
            sys::ScalabilityMode::kL3T3h => Self::L3T3h,
            sys::ScalabilityMode::kL3T3_KEY => Self::L3T3Key,
            sys::ScalabilityMode::kS2T1 => Self::S2T1,
            sys::ScalabilityMode::kS2T1h => Self::S2T1h,
            sys::ScalabilityMode::kS2T2 => Self::S2T2,
            sys::ScalabilityMode::kS2T2h => Self::S2T2h,
            sys::ScalabilityMode::kS2T3 => Self::S2T3,
            sys::ScalabilityMode::kS2T3h => Self::S2T3h,
            sys::ScalabilityMode::kS3T1 => Self::S3T1,
            sys::ScalabilityMode::kS3T1h => Self::S3T1h,
            sys::ScalabilityMode::kS3T2 => Self::S3T2,
            sys::ScalabilityMode::kS3T2h => Self::S3T2h,
            sys::ScalabilityMode::kS3T3 => Self::S3T3,
            sys::ScalabilityMode::kS3T3h => Self::S3T3h,
            _ => unreachable!(),
        }
    }
}

/// Representation of capabilities/preferences of an implementation for a header
/// extension of [`RtpCapabilities`].
#[derive(Debug)]
pub struct RtpHeaderExtensionCapability {
    /// [URI] of this extension, as defined in [RFC 8285].
    ///
    /// [RFC 8285]: https://tools.ietf.org/html/rfc8285
    /// [URI]: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier
    pub uri: String,

    /// Preferred value of ID that goes in the packet.
    pub preferred_id: Option<i32>,

    /// If [`true`], it's preferred that the value in the header is encrypted.
    pub preferred_encrypted: bool,

    /// Direction of the extension.
    ///
    /// [`RtpTransceiverDirection::Stopped`] value is only used with
    /// `RtpTransceiverInterface::SetHeaderExtensionsToNegotiate()` and
    /// `SetHeaderExtensionsToNegotiate()`.
    pub direction: RtpTransceiverDirection,
}

impl From<sys::RtpHeaderExtensionCapability> for RtpHeaderExtensionCapability {
    fn from(value: sys::RtpHeaderExtensionCapability) -> Self {
        Self {
            uri: value.uri(),
            preferred_id: value.preferred_id(),
            preferred_encrypted: value.preferred_encrypted(),
            direction: value.direction().into(),
        }
    }
}

/// Representation of static capabilities of an endpoint's implementation of a
/// codec.
#[derive(Debug)]
pub struct RtpCodecCapability {
    /// Default payload type for the codec.
    ///
    /// Mainly needed for codecs that have statically assigned payload types.
    pub preferred_payload_type: Option<i32>,

    /// List of [`ScalabilityMode`]s supported by the video codec.
    pub scalability_modes: Vec<ScalabilityMode>,

    /// Built [MIME "type/subtype"][0] string from `name` and `kind`.
    ///
    /// [0]: https://en.wikipedia.org/wiki/Media_type
    pub mime_type: String,

    /// Used to identify the codec. Equivalent to [MIME subtype][0].
    ///
    /// [0]: https://en.wikipedia.org/wiki/Media_type#Subtypes
    pub name: String,

    /// [`MediaType`] of this codec. Equivalent to [MIME] top-level type.
    ///
    /// [MIME]: https://en.wikipedia.org/wiki/Media_type
    pub kind: MediaType,

    /// If [`None`], the implementation default is used.
    pub clock_rate: Option<i32>,

    /// Number of audio channels used.
    ///
    /// [`None`] for video codecs.
    ///
    /// If [`None`] for audio, the implementation default is used.
    pub num_channels: Option<i32>,

    /// Codec-specific parameters that must be signaled to the remote party.
    ///
    /// Corresponds to `a=fmtp` parameters in [SDP].
    ///
    /// Contrary to ORTC, these parameters are named using all lowercase
    /// strings. This helps make the mapping to [SDP] simpler, if an application
    /// is using [SDP]. Boolean values are represented by the string "1".
    ///
    /// [SDP]: https://en.wikipedia.org/wiki/Session_Description_Protocol
    pub parameters: Vec<(String, String)>,

    /// Feedback mechanisms to be used for this codec.
    pub feedback: Vec<RtcpFeedback>,
}

impl From<sys::RtpCodecCapability> for RtpCodecCapability {
    fn from(value: sys::RtpCodecCapability) -> Self {
        Self {
            preferred_payload_type: value.preferred_payload_type(),
            scalability_modes: value
                .scalability_modes()
                .into_iter()
                .map(Into::into)
                .collect(),
            mime_type: value.mime_type(),
            name: value.name(),
            kind: value.kind().into(),
            clock_rate: value.clock_rate(),
            num_channels: value.num_channels(),
            parameters: value.parameters().into_iter().collect(),
            feedback: value
                .rtcp_feedback()
                .into_iter()
                .map(Into::into)
                .collect(),
        }
    }
}

/// Indicator of the current state of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackEvent {
    /// Ended event of the [`MediaStreamTrack`] interface is fired when playback
    /// or streaming has stopped because the end of the media was reached or
    /// because no further data is available.
    Ended,

    /// Event indicating an audio level change in the [`MediaStreamTrack`].
    AudioLevelUpdated(u32),

    /// Event indicating that the [`MediaStreamTrack`] has completely
    /// initialized and can be used on Flutter side.
    TrackCreated,
}

/// Indicator of the current [MediaStreamTrackState][0] of a
/// [`MediaStreamTrack`].
///
/// [0]: https://w3.org/TR/mediacapture-streams#dom-mediastreamtrackstate
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TrackState {
    /// [MediaStreamTrackState.live][0] representation.
    ///
    /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.live
    Live,

    /// [MediaStreamTrackState.ended][0] representation.
    ///
    /// [0]: https://tinyurl.com/w3mcs#idl-def-MediaStreamTrackState.ended
    Ended,
}

impl From<sys::TrackState> for TrackState {
    fn from(state: sys::TrackState) -> Self {
        match state {
            sys::TrackState::kLive => Self::Live,
            sys::TrackState::kEnded => Self::Ended,
            _ => unreachable!(),
        }
    }
}

/// [RTCRtpTransceiverDirection][1] representation.
///
/// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverdirection
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RtpTransceiverDirection {
    /// The [RTCRtpTransceiver]'s [RTCRtpSender] will offer to send RTP, and
    /// will send RTP if the remote peer accepts. The [RTCRtpTransceiver]'s
    /// [RTCRtpReceiver] will offer to receive RTP, and will receive RTP if the
    /// remote peer accepts.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    SendRecv,

    /// The [RTCRtpTransceiver]'s [RTCRtpSender] will offer to send RTP, and
    /// will send RTP if the remote peer accepts. The [RTCRtpTransceiver]'s
    /// [RTCRtpReceiver] will not offer to receive RTP, and will not receive
    /// RTP.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    SendOnly,

    /// The [RTCRtpTransceiver]'s [RTCRtpSender] will not offer to send RTP,
    /// and will not send RTP. The [RTCRtpTransceiver]'s [RTCRtpReceiver] will
    /// offer to receive RTP, and will receive RTP if the remote peer accepts.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    RecvOnly,

    /// The [RTCRtpTransceiver]'s [RTCRtpSender] will not offer to send RTP,
    /// and will not send RTP. The [RTCRtpTransceiver]'s [RTCRtpReceiver] will
    /// not offer to receive RTP, and will not receive RTP.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    Inactive,

    /// The [RTCRtpTransceiver] will neither send nor receive RTP. It will
    /// generate a zero port in the offer. In answers, its [RTCRtpSender] will
    /// not offer to send RTP, and its [RTCRtpReceiver] will not offer to
    /// receive RTP. This is a terminal state.
    ///
    /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
    /// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
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

/// Possible media types of a [`MediaStreamTrack`].
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MediaType {
    /// Audio [`MediaStreamTrack`].
    Audio,

    /// Video [`MediaStreamTrack`].
    Video,
}

impl From<MediaType> for sys::MediaType {
    fn from(state: MediaType) -> Self {
        match state {
            MediaType::Audio => Self::MEDIA_TYPE_AUDIO,
            MediaType::Video => Self::MEDIA_TYPE_VIDEO,
        }
    }
}

impl From<sys::MediaType> for MediaType {
    fn from(state: sys::MediaType) -> Self {
        match state {
            sys::MediaType::MEDIA_TYPE_AUDIO => Self::Audio,
            sys::MediaType::MEDIA_TYPE_VIDEO => Self::Video,
            _ => unreachable!(),
        }
    }
}

/// [MediaStreamConstraints], used to instruct what sort of
/// [`MediaStreamTrack`]s to return by the [`Webrtc::get_media()`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#dom-mediastreamconstraints
#[derive(Debug)]
pub struct MediaStreamConstraints {
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub audio: Option<AudioConstraints>,

    /// Specifies the nature and settings of the video [`MediaStreamTrack`].
    pub video: Option<VideoConstraints>,
}

/// Nature and settings of the video [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct VideoConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// The first device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Width in pixels.
    pub width: u32,

    /// Height in pixels.
    pub height: u32,

    /// Exact frame rate (frames per second).
    pub frame_rate: u32,

    /// Indicator whether the request video track should be acquired via screen
    /// capturing.
    pub is_display: bool,
}

/// Nature and settings of the audio [`MediaStreamTrack`] returned by
/// [`Webrtc::get_media()`].
#[derive(Debug)]
pub struct AudioConstraints {
    /// Identifier of the device generating the content of the
    /// [`MediaStreamTrack`].
    ///
    /// First device will be chosen if an empty [`String`] is provided.
    pub device_id: Option<String>,

    /// Audio processing configuration constraints of the [`MediaStreamTrack`].
    pub processing: AudioProcessingConstraints,
}

/// Constraints of an [`AudioProcessingConfig`].
#[derive(Debug, Default)]
pub struct AudioProcessingConstraints {
    /// Indicator whether the audio volume level should be automatically tuned
    /// to maintain a steady overall volume level.
    pub auto_gain_control: Option<bool>,

    /// Indicator whether a high-pass filter should be enabled to eliminate
    /// low-frequency noise.
    pub high_pass_filter: Option<bool>,

    /// Indicator whether noise suppression should be enabled to reduce
    /// background sounds.
    pub noise_suppression: Option<bool>,

    /// Level of aggressiveness for noise suppression.
    pub noise_suppression_level: Option<NoiseSuppressionLevel>,

    /// Indicator whether echo cancellation should be enabled to prevent
    /// feedback.
    pub echo_cancellation: Option<bool>,
}

/// Audio processing configuration for some local audio [`MediaStreamTrack`].
#[expect(clippy::struct_excessive_bools, reason = "that's ok")]
#[derive(Debug)]
pub struct AudioProcessingConfig {
    /// Indicator whether the audio volume level should be automatically tuned
    /// to maintain a steady overall volume level.
    pub auto_gain_control: bool,

    /// Indicator whether a high-pass filter should be enabled to eliminate
    /// low-frequency noise.
    pub high_pass_filter: bool,

    /// Indicator whether noise suppression should be enabled to reduce
    /// background sounds.
    pub noise_suppression: bool,

    /// Level of aggressiveness for noise suppression.
    pub noise_suppression_level: NoiseSuppressionLevel,

    /// Indicator whether echo cancellation should be enabled to prevent
    /// feedback.
    pub echo_cancellation: bool,
}

/// [`AudioProcessingConfig`] noise suppression aggressiveness.
#[derive(Clone, Copy, Debug)]
pub enum NoiseSuppressionLevel {
    /// Minimal noise suppression.
    Low,

    /// Moderate level of suppression.
    Moderate,

    /// Aggressive noise suppression.
    High,

    /// Maximum suppression.
    VeryHigh,
}

impl From<NoiseSuppressionLevel> for sys::NoiseSuppressionLevel {
    fn from(level: NoiseSuppressionLevel) -> Self {
        match level {
            NoiseSuppressionLevel::Low => Self::kLow,
            NoiseSuppressionLevel::Moderate => Self::kModerate,
            NoiseSuppressionLevel::High => Self::kHigh,
            NoiseSuppressionLevel::VeryHigh => Self::kVeryHigh,
        }
    }
}

impl From<sys::NoiseSuppressionLevel> for NoiseSuppressionLevel {
    fn from(level: sys::NoiseSuppressionLevel) -> Self {
        match level {
            sys::NoiseSuppressionLevel::kLow => Self::Low,
            sys::NoiseSuppressionLevel::kModerate => Self::Moderate,
            sys::NoiseSuppressionLevel::kHigh => Self::High,
            sys::NoiseSuppressionLevel::kVeryHigh => Self::VeryHigh,
            _ => unreachable!(),
        }
    }
}

/// Representation of a single media track within a [MediaStream].
///
/// Typically, these are audio or video tracks, but other track types may exist
/// as well.
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[derive(Clone, Debug)]
pub struct MediaStreamTrack {
    /// Unique identifier (GUID) of this [`MediaStreamTrack`].
    pub id: String,

    /// Unique identifier of the [`PeerConnection`] from which this
    /// [`MediaStreamTrack`] was received.
    ///
    /// Always [`None`] for local [`MediaStreamTrack`]s.
    pub peer_id: Option<u32>,

    /// Label identifying the track source, as in "internal microphone".
    pub device_id: String,

    /// [`MediaType`] of this [`MediaStreamTrack`].
    pub kind: MediaType,

    /// Indicator whether this [`MediaStreamTrack`] is allowed to render the
    /// source stream.
    ///
    /// This can be used to intentionally mute a track.
    pub enabled: bool,
}

/// Representation of [RTCRtpEncodingParameters][0].
///
/// [0]: https://w3.org/TR/webrtc#rtcrtpencodingparameters
pub struct RtcRtpEncodingParameters {
    /// [RTP stream ID (RID)][0] to be sent using the RID header extension.
    ///
    /// [0]: https://w3.org/TR/webrtc#dom-rtcrtpcodingparameters-rid
    pub rid: String,

    /// Indicator whether the described [`RtcRtpEncodingParameters`] are
    /// currently actively being used.
    pub active: bool,

    /// Maximum number of bits per second to allow for these
    /// [`RtcRtpEncodingParameters`].
    pub max_bitrate: Option<i32>,

    /// Maximum number of frames per second to allow for these
    /// [`RtcRtpEncodingParameters`].
    pub max_framerate: Option<f64>,

    /// Factor for scaling down the video with these
    /// [`RtcRtpEncodingParameters`].
    pub scale_resolution_down_by: Option<f64>,

    /// Scalability mode describing layers within the media stream.
    pub scalability_mode: Option<String>,
}

impl From<&sys::RtpEncodingParameters> for RtcRtpEncodingParameters {
    fn from(sys: &sys::RtpEncodingParameters) -> Self {
        Self {
            rid: sys.rid(),
            active: sys.active(),
            max_bitrate: sys.max_bitrate(),
            max_framerate: sys.max_framerate(),
            scale_resolution_down_by: sys.scale_resolution_down_by(),
            scalability_mode: sys.scalability_mode(),
        }
    }
}

/// Representation of an [RTCRtpTransceiverInit][0].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtptransceiverinit
pub struct RtpTransceiverInit {
    /// Direction of the [RTCRtpTransceiver].
    ///
    /// [RTCRtpTransceiver]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver
    pub direction: RtpTransceiverDirection,

    /// Sequence containing parameters for sending [RTP] encodings of media.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub send_encodings: Vec<RtcRtpEncodingParameters>,
}

/// Representation of a permanent pair of an [RTCRtpSender] and an
/// [RTCRtpReceiver], along with some shared state.
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#dom-rtcrtpsender
/// [RTCRtpReceiver]: https://w3.org/TR/webrtc#dom-rtcrtpreceiver
#[derive(Clone)]
pub struct RtcRtpTransceiver {
    /// [`PeerConnection`] that this [`RtcRtpTransceiver`] belongs to.
    pub peer: RustOpaque<Arc<PeerConnection>>,

    /// Rust side [`RtpTransceiver`].
    pub transceiver: RustOpaque<Arc<RtpTransceiver>>,

    /// [Negotiated media ID (mid)][1] which the local and remote peers have
    /// agreed upon to uniquely identify the [MediaStream]'s pairing of sender
    /// and receiver.
    ///
    /// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub mid: Option<String>,

    /// Preferred [`direction`][1] of this [`RtcRtpTransceiver`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    pub direction: RtpTransceiverDirection,
}

/// Representation of [RTCRtpSendParameters][0].
///
/// [0]: https://w3.org/TR/webrtc#dom-rtcrtpsendparameters
pub struct RtcRtpSendParameters {
    /// Sequence containing parameters for sending [RTP] encodings of media.
    ///
    /// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
    pub encodings:
        Vec<(RtcRtpEncodingParameters, RustOpaque<Arc<RtpEncodingParameters>>)>,

    /// Reference to the Rust side [`RtpParameters`].
    pub inner: RustOpaque<Arc<RtpParameters>>,
}

impl From<RtpParameters> for RtcRtpSendParameters {
    fn from(v: RtpParameters) -> Self {
        let encodings = v
            .get_encodings()
            .into_iter()
            .map(|e| {
                (
                    RtcRtpEncodingParameters::from(&e),
                    RustOpaque::new(Arc::new(RtpEncodingParameters::from(e))),
                )
            })
            .collect();

        Self { encodings, inner: RustOpaque::new(Arc::new(v)) }
    }
}

/// [`get_media()`] function result.
pub enum GetMediaResult {
    /// Requested media tracks.
    Ok(Vec<MediaStreamTrack>),

    /// Failed to get requested media.
    Err(GetMediaError),
}

/// Media acquisition error.
pub enum GetMediaError {
    /// Could not acquire audio track.
    Audio(String),

    /// Could not acquire video track.
    Video(String),
}

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
pub fn enable_fake_media() {
    FAKE_MEDIA.store(true, Ordering::Release);
}

/// Indicates whether application is configured to use fake media devices.
pub fn is_fake_media() -> bool {
    FAKE_MEDIA.load(Ordering::Acquire)
}

/// Returns a list of all available media input and output devices, such as
/// microphones, cameras, headsets, and so forth.
pub fn enumerate_devices() -> anyhow::Result<Vec<MediaDeviceInfo>> {
    WEBRTC.lock().unwrap().enumerate_devices()
}

/// Returns a list of all available displays that can be used for screen
/// capturing.
#[must_use]
pub fn enumerate_displays() -> Vec<MediaDisplayInfo> {
    devices::enumerate_displays()
}

/// Creates a new [`RtcRtpTransceiver`] and adds it to the set of transceivers
/// of the specified [`PeerConnection`].
pub fn add_transceiver(
    peer: RustOpaque<Arc<PeerConnection>>,
    media_type: MediaType,
    init: RtpTransceiverInit,
) -> anyhow::Result<RtcRtpTransceiver> {
    PeerConnection::add_transceiver(peer, media_type.into(), init)
}

/// Returns a sequence of [`RtcRtpTransceiver`] objects representing the RTP
/// transceivers currently attached to the specified [`PeerConnection`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceivers(
    peer: RustOpaque<Arc<PeerConnection>>,
) -> Vec<RtcRtpTransceiver> {
    Webrtc::get_transceivers(&peer)
}

/// Changes the preferred `direction` of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_direction(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    direction: RtpTransceiverDirection,
) -> anyhow::Result<()> {
    transceiver.set_direction(direction)
}

/// Changes the receive direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_recv(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    recv: bool,
) -> anyhow::Result<()> {
    transceiver.set_recv(recv)
}

/// Changes the send direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_transceiver_send(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    send: bool,
) -> anyhow::Result<()> {
    transceiver.set_send(send)
}

/// Returns the [negotiated media ID (mid)][1] of the specified
/// [`RtcRtpTransceiver`].
///
/// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceiver_mid(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> Option<String> {
    transceiver.mid()
}

/// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn get_transceiver_direction(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> RtpTransceiverDirection {
    transceiver.direction().into()
}

/// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping, unless
/// it's already stopped.
///
/// This will immediately cause the transceiver's sender to no longer send, and
/// its receiver to no longer receive.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn stop_transceiver(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> anyhow::Result<()> {
    transceiver.stop()
}

/// Changes the preferred [`RtpTransceiver`] codecs to the provided
/// [`Vec`]`<`[`RtpCodecCapability`]`>`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn set_codec_preferences(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    codecs: Vec<RtpCodecCapability>,
) {
    transceiver.set_codec_preferences(codecs);
}

/// Replaces the specified [`AudioTrack`] (or [`VideoTrack`]) on the
/// [`sys::RtpTransceiverInterface`]'s `sender`.
///
/// [`AudioTrack`]: crate::AudioTrack
/// [`VideoTrack`]: crate::VideoTrack
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn sender_replace_track(
    peer: RustOpaque<Arc<PeerConnection>>,
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    track_id: Option<String>,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().sender_replace_track(&peer, &transceiver, track_id)
}

/// Returns [`RtpParameters`] from the provided [`RtpTransceiver`]'s `sender`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
#[must_use]
pub fn sender_get_parameters(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
) -> RtcRtpSendParameters {
    RtcRtpSendParameters::from(transceiver.sender_get_parameters())
}

/// Returns the capabilities of an [RTP] sender of the provided [`MediaType`].
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[must_use]
pub fn get_rtp_sender_capabilities(kind: MediaType) -> RtpCapabilities {
    RtpCapabilities::from(
        WEBRTC
            .lock()
            .unwrap()
            .peer_connection_factory
            .get_rtp_sender_capabilities(kind.into()),
    )
}

/// Returns the capabilities of an [RTP] receiver of the provided [`MediaType`].
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
#[must_use]
pub fn get_rtp_receiver_capabilities(kind: MediaType) -> RtpCapabilities {
    RtpCapabilities::from(
        WEBRTC
            .lock()
            .unwrap()
            .peer_connection_factory
            .get_rtp_receiver_capabilities(kind.into()),
    )
}

/// Sets [`RtpParameters`] into the provided [`RtpTransceiver`]'s `sender`.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn sender_set_parameters(
    transceiver: RustOpaque<Arc<RtpTransceiver>>,
    params: RtcRtpSendParameters,
) -> anyhow::Result<()> {
    transceiver.sender_set_parameters(params)
}

/// Creates a [MediaStream] with tracks according to provided
/// [`MediaStreamConstraints`].
///
/// [MediaStream]: https://w3.org/TR/mediacapture-streams#dom-mediastream
#[must_use]
pub fn get_media(constraints: MediaStreamConstraints) -> GetMediaResult {
    #[expect(clippy::significant_drop_in_scrutinee, reason = "no problems")]
    match WEBRTC.lock().unwrap().get_media(constraints) {
        Ok(tracks) => GetMediaResult::Ok(tracks),
        Err(err) => GetMediaResult::Err(err),
    }
}

/// Sets the specified `audio playout` device.
pub fn set_audio_playout_device(device_id: String) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_audio_playout_device(device_id)
}

/// Indicates whether the microphone is available to set volume.
pub fn microphone_volume_is_available() -> anyhow::Result<bool> {
    WEBRTC.lock().unwrap().microphone_volume_is_available()
}

/// Sets the microphone system volume according to the specified `level` in
/// percents.
///
/// Valid values range is `[0; 100]`.
pub fn set_microphone_volume(level: u8) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().set_microphone_volume(level)
}

/// Returns the current level of the microphone volume in `[0; 100]` range.
pub fn microphone_volume() -> anyhow::Result<u32> {
    WEBRTC.lock().unwrap().microphone_volume()
}

/// Disposes the specified [`MediaStreamTrack`].
pub fn dispose_track(track_id: String, peer_id: Option<u32>, kind: MediaType) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().dispose_track(track_origin, track_id, kind, false);
}

/// Returns the [readyState][0] property of the [`MediaStreamTrack`] by its ID
/// and [`MediaType`].
///
/// [0]: https://w3.org/TR/mediacapture-streams#dfn-readystate
pub fn track_state(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> TrackState {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_state(track_id, track_origin, kind)
}

/// Returns the [height] property of the media track by its ID and
/// [`MediaType`].
///
/// Blocks until the [height] is initialized.
///
/// [height]: https://w3.org/TR/mediacapture-streams#dfn-height
pub fn track_height(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<i32> {
    if kind == MediaType::Audio {
        return None;
    }

    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_height(track_id, track_origin)
}

/// Returns the [width] property of the media track by its ID and [`MediaType`].
///
/// Blocks until the [width] is initialized.
///
/// [width]: https://w3.org/TR/mediacapture-streams#dfn-height
pub fn track_width(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<i32> {
    if kind == MediaType::Audio {
        return None;
    }

    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().track_width(track_id, track_origin)
}

/// Changes the [enabled][1] property of the [`MediaStreamTrack`] by its ID and
/// [`MediaType`].
///
/// [1]: https://w3.org/TR/mediacapture-streams#track-enabled
pub fn set_track_enabled(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
    enabled: bool,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().set_track_enabled(
        track_id,
        track_origin,
        kind,
        enabled,
    );
}

/// Clones the specified [`MediaStreamTrack`].
pub fn clone_track(
    track_id: String,
    peer_id: Option<u32>,
    kind: MediaType,
) -> Option<MediaStreamTrack> {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().clone_track(track_id, track_origin, kind)
}

/// Registers an observer to the [`MediaStreamTrack`] events.
pub fn register_track_observer(
    cb: StreamSink<TrackEvent>,
    peer_id: Option<u32>,
    track_id: String,
    kind: MediaType,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().register_track_observer(
        track_id,
        track_origin,
        kind,
        cb,
    );
}

/// Enables or disables audio level observing of the audio [`MediaStreamTrack`]
/// with the provided `track_id`.
pub fn set_audio_level_observer_enabled(
    track_id: String,
    peer_id: Option<u32>,
    enabled: bool,
) {
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));
    WEBRTC.lock().unwrap().set_audio_level_observer_enabled(
        track_id,
        track_origin,
        enabled,
    );
}

/// Applies the provided [`AudioProcessingConstraints`] to specified local audio
/// track.
#[expect(clippy::needless_pass_by_value, reason = "FFI")]
pub fn update_audio_processing(
    track_id: String,
    conf: AudioProcessingConstraints,
) -> anyhow::Result<()> {
    WEBRTC.lock().unwrap().apply_audio_processing_config(track_id, &conf)
}

/// Returns the current [`AudioProcessingConfig`] for the specified local audio
/// track.
pub fn get_audio_processing_config(
    track_id: String,
) -> anyhow::Result<AudioProcessingConfig> {
    WEBRTC.lock().unwrap().get_audio_processing_config(track_id)
}

/// Sets the provided `OnDeviceChangeCallback` as the callback to be called
/// whenever a set of available media devices changes.
///
/// Only one callback can be set at a time, so the previous one will be dropped,
/// if any.
pub fn set_on_device_changed(cb: StreamSink<()>) {
    WEBRTC.lock().unwrap().set_on_device_changed(cb);
}

/// Creates a new [`VideoSink`] attached to the specified video track.
///
/// `callback_ptr` argument should be a pointer to an [`UniquePtr`] pointing to
/// an [`sys::OnFrameCallback`].
///
/// [`UniquePtr`]: cxx::UniquePtr
/// [`VideoSink`]: crate::VideoSink
pub fn create_video_sink(
    cb: StreamSink<TextureEvent>,
    sink_id: i64,
    peer_id: Option<u32>,
    track_id: String,
    callback_ptr: i64,
    texture_id: i64,
) {
    let handler = FrameHandler::new(callback_ptr as _, cb, texture_id);
    let track_origin = TrackOrigin::from(peer_id.map(PeerConnectionId::from));

    WEBRTC.lock().unwrap().create_video_sink(
        sink_id,
        track_id,
        track_origin,
        handler,
    );
}

/// Destroys a [`VideoSink`] by the provided ID.
///
/// [`VideoSink`]: crate::VideoSink
pub fn dispose_video_sink(sink_id: i64) {
    WEBRTC.lock().unwrap().dispose_video_sink(sink_id);
}
