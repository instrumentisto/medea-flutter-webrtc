use std::{cell::RefCell, rc::Rc};

use cxx::UniquePtr;

use crate::{
    init, Webrtc, api_::OnFrameCallbackInterface,
};


pub static mut WEBRTC: Option<Rc<RefCell<Box<Webrtc>>>> = None;

pub fn webrtc_init() {
    unsafe {
        match WEBRTC {
            None => WEBRTC = Some(Rc::new(RefCell::new(init()))),
            _ => (),
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

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum MediaType {
    Audio,
    Video,
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
    pub audio: Box<AudioConstraints>,
    /// Specifies the nature and settings of the audio [`MediaStreamTrack`].
    pub video: Box<VideoConstraints>,
}

/// Specifies the nature and settings of the video [`MediaStreamTrack`]
/// returned by [`Webrtc::get_users_media()`].
pub struct VideoConstraints {
    /// Indicates whether [`Webrtc::get_users_media()`] should obtain video
    /// track. All other args will be ignored if `required` is set to
    /// `false`.
    pub required: bool,

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
}

/// Specifies the nature and settings of the audio [`MediaStreamTrack`]
/// returned by [`Webrtc::get_users_media()`].
pub struct AudioConstraints {
    /// Indicates whether [`Webrtc::get_users_media()`] should obtain video
    /// track. All other args will be ignored if `required` is set to
    /// `false`.
    pub required: bool,

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
    pub label: String,

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
    /// ID of this [`RtcRtpTransceiver`].
    ///
    /// It's not unique across all possible [`RtcRtpTransceiver`]s, but only
    /// within a specific peer.
    pub id: u64,

    /// [Negotiated media ID (mid)][1] which the local and remote peers have
    /// agreed upon to uniquely identify the [`MediaStream`]'s pairing of
    /// sender and receiver.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub mid: String,

    /// Preferred [`direction`][1] of this [`RtcRtpTransceiver`].
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcrtptransceiver-direction
    pub direction: String,

    /// [`RtcRtpSender`] responsible for encoding and sending outgoing
    /// media data for the transceiver's stream.
    pub sender: RtcRtpSender,
}

/// [`RtcRtpSender`] object allowing to control how a [`MediaStreamTrack`]
/// is encoded and transmitted to a remote peer.
#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub struct RtcRtpSender {
    /// ID of this [`RtcRtpSender`].
    pub id: u64,
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
    pub ice_transport_policy: String,

    /// [bundlePolicy][1] configuration.
    ///
    /// Indicates which media-bundling policy to use when gathering ICE
    /// candidates.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-bundlepolicy
    pub bundle_policy: String,

    /// [iceServers][1] configuration.
    ///
    /// An array of objects describing servers available to be used by ICE,
    /// such as STUN and TURN servers.
    ///
    /// [1]: https://w3.org/TR/webrtc#dom-rtcconfiguration-iceservers
    pub ice_servers: Vec<RtcIceServer>,
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


pub fn create_video_sink(sink_id: i64, stream_id: u64, callback_ptr: u64) {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    let handler: UniquePtr<OnFrameCallbackInterface> =
        unsafe { std::mem::transmute(callback_ptr) };
    webrtc.create_video_sink(sink_id, stream_id, handler);
}

pub fn dispose_video_sink(sink_id: i64) {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    webrtc.dispose_video_sink(sink_id);
}

pub fn enumerate_devices() -> Vec<MediaDeviceInfo> {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    webrtc.enumerate_devices()
}

pub fn get_media(
    constraints: MediaStreamConstraints,
    is_display: bool,
) -> Vec<MediaStreamTrack> {
    webrtc_init();
    let mut webrtc = unsafe { WEBRTC.as_mut().unwrap().borrow_mut() };
    webrtc.get_media(&constraints, is_display)
}