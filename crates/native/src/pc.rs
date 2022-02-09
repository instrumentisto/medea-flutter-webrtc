use std::collections::HashMap;

use cxx::{let_cxx_string, CxxString, UniquePtr};
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;

use crate::{
    internal::{CreateSdpCallbackInterface, SetDescriptionCallbackInterface},
    next_id, Webrtc,
};

use crate::api::TransceiverInfo;

/// Converts [`sys::RtpTransceiverDirection`] into [`String`].
fn direction_to_string(direction: sys::RtpTransceiverDirection) -> String {
    match direction {
        sys::RtpTransceiverDirection::kSendRecv => "sendrecv".to_string(),
        sys::RtpTransceiverDirection::kSendOnly => "sendonly".to_string(),
        sys::RtpTransceiverDirection::kRecvOnly => "recvonly".to_string(),
        sys::RtpTransceiverDirection::kInactive => "inactive".to_string(),
        sys::RtpTransceiverDirection::kStopped => "stopped".to_string(),
        _ => unreachable!(),
    }
}

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        error: &mut String,
    ) -> u64 {
        let peer = PeerConnection::new(&mut self.0.peer_connection_factory);
        match peer {
            Ok(peer) => self
                .0
                .peer_connections
                .entry(peer.id)
                .or_insert(peer)
                .id
                .into(),
            Err(err) => {
                error.push_str(&err.to_string());
                0
            }
        }
    }

    /// Initiates the creation of a SDP offer for the purpose of starting a new
    /// WebRTC connection to a remote peer.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    pub fn create_offer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(cb),
        ));
        peer.inner.create_offer(&options, obs);

        String::new()
    }

    /// Creates a SDP answer to an offer received from a remote peer during an
    /// offer/answer negotiation of a WebRTC connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    pub fn create_answer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
            CreateSdpCallback(cb),
        ));
        peer.inner.create_answer(&options, obs);

        String::new()
    }

    /// Changes the local description associated with the connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_local_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let sdp_kind = match sys::SdpType::try_from(kind.as_str()) {
            Ok(kind) => kind,
            Err(e) => {
                return e.to_string();
            }
        };

        let desc = sys::SessionDescriptionInterface::new(sdp_kind, &sdp);
        let obs =
            sys::SetLocalDescriptionObserver::new(Box::new(SetSdpCallback(cb)));
        peer.inner.set_local_description(desc, obs);

        String::new()
    }

    /// Sets the specified session description as the remote peer's current
    /// offer or answer.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_remote_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "`PeerConnection` with ID `{peer_id}` does not exist",
            );
        };

        let sdp_kind = match sys::SdpType::try_from(kind.as_str()) {
            Ok(kind) => kind,
            Err(e) => {
                return e.to_string();
            }
        };

        let desc = sys::SessionDescriptionInterface::new(sdp_kind, &sdp);
        let obs = sys::SetRemoteDescriptionObserver::new(Box::new(
            SetSdpCallback(cb),
        ));
        peer.inner.set_remote_description(desc, obs);

        String::new()
    }

    /// Creates and adds a [`sys::Transceiver`] to the [`PeerConnection`],
    /// returns the [`TransceiverInfo`] of that [`sys::Transceiver`].
    ///
    /// # Panics
    ///
    /// May panic on getting [`PeerConnection`].
    pub fn add_transceiver(
        &mut self,
        peer_id: u64,
        media_type: &str,
        direction: &str,
    ) -> TransceiverInfo {
        let media_type: sys::MediaType = match media_type {
            "audio" => sys::MediaType::MEDIA_TYPE_AUDIO,
            "video" => sys::MediaType::MEDIA_TYPE_VIDEO,
            "data" => sys::MediaType::MEDIA_TYPE_DATA,
            "unsupported" => sys::MediaType::MEDIA_TYPE_UNSUPPORTED,
            _ => unreachable!(),
        };

        let direction: sys::RtpTransceiverDirection = match direction {
            "sendrecv" => sys::RtpTransceiverDirection::kSendRecv,
            "sendonly" => sys::RtpTransceiverDirection::kSendOnly,
            "recvonly" => sys::RtpTransceiverDirection::kRecvOnly,
            "stopped" => sys::RtpTransceiverDirection::kStopped,
            "inactive" => sys::RtpTransceiverDirection::kInactive,
            _ => unreachable!(),
        };

        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let transceiver = peer.inner.add_transceiver(media_type, direction);

        let info = TransceiverInfo {
            id: next_id(),
            mid: transceiver.mid(),
            direction: direction_to_string(transceiver.direction()),
        };

        peer.transceivers
            .insert(TransceiverId(info.id), transceiver);

        info
    }

    /// Returns the [`sys::Transceiver`]'s of some [`PeerConnection`] according
    /// to the given `id`.
    ///
    /// # Panics
    ///
    /// May panic on getting [`PeerConnection`].
    pub fn get_transceivers(&mut self, peer_id: u64) -> Vec<TransceiverInfo> {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let mut transceivers = peer.inner.get_transceivers();

        let mut out_info: Vec<TransceiverInfo> = Vec::new();

        for _index in 0..transceivers.len() {
            let transceiver = transceivers.pop().unwrap();
            let mut is_in = false;
            let mut id = 0;

            for written_transceiver in &peer.transceivers {
                is_in = written_transceiver.1 == &transceiver;
                id = written_transceiver.0 .0;
            }

            let info = TransceiverInfo {
                id: if is_in { id } else { next_id() },
                mid: transceiver.mid(),
                direction: direction_to_string(transceiver.direction()),
            };

            if !is_in {
                peer.transceivers
                    .insert(TransceiverId(info.id), transceiver);
            }

            out_info.push(info);
        }

        out_info
    }
}

/// ID of a [`sys::Transceiver`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct TransceiverId(u64);

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection {
    /// ID of this [`PeerConnection`].
    id: PeerConnectionId,

    /// Underlying [`sys::PeerConnectionInterface`].
    inner: sys::PeerConnectionInterface,

    /// The [`sys::Transceiver`]s of this [`PeerConnection`].
    transceivers: HashMap<TransceiverId, sys::Transceiver>,
}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
    ) -> anyhow::Result<Self> {
        let inner = factory.create_peer_connection_or_error(
            &sys::RTCConfiguration::default(),
            sys::PeerConnectionDependencies::default(),
        )?;

        Ok(Self {
            id: PeerConnectionId::from(next_id()),
            inner,
            transceivers: HashMap::new(),
        })
    }
}

/// [`CreateSdpCallbackInterface`] wrapper.
struct CreateSdpCallback(UniquePtr<CreateSdpCallbackInterface>);

impl sys::CreateSdpCallback for CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: sys::SdpType) {
        let_cxx_string!(kind = kind.to_string());
        self.0.pin_mut().on_create_sdp_success(sdp, &kind.as_ref());
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_create_sdp_fail(error);
    }
}

/// [`SetDescriptionCallbackInterface`] wrapper.
struct SetSdpCallback(UniquePtr<SetDescriptionCallbackInterface>);

impl sys::SetDescriptionCallback for SetSdpCallback {
    fn success(&mut self) {
        self.0.pin_mut().on_set_description_sucess();
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_set_description_fail(error);
    }
}
