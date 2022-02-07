use std::sync::{Arc, Mutex};

use cxx::{let_cxx_string, CxxString, UniquePtr};
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;
use sys::{
    get_candidate_pair, get_estimated_disconnected_time_ms,
    get_last_data_received_ms, get_local_candidate, get_remote_candidate,
    PeerConnectionObserver, _AudioTrackInterface, _VideoTrackInterface,
    get_reason, media_stream_interface_get_audio_tracks,
    media_stream_interface_get_video_tracks,
};

use sys::{
    audio_track_truncation, media_stream_interface_get_id,
    media_stream_track_interface_get_enabled,
    media_stream_track_interface_get_id, media_stream_track_interface_get_kind,
    media_stream_track_interface_get_state, rtp_receiver_interface_streams,
    rtp_sender_interface_get_track, rtp_transceiver_interface_get_receiver,
    video_track_truncation,
};

use crate::Context;
use crate::api::{
    MediaStreamInterfaceSerialized, OnTrackSerialized,
    PeerConnectionOnEventInterface, TrackInterfaceSerialized,
};

use crate::{
    internal::{CreateSdpCallbackInterface, SetDescriptionCallbackInterface},
    next_id, Webrtc,
};

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        cb: UniquePtr<PeerConnectionOnEventInterface>,
        error: &mut String,
    ) -> u64 {
        let dependencies =
            sys::PeerConnectionDependencies::new(PeerConnectionObserver::new(
                Box::new(HandlerPeerConnectionOnEvent{cb}),
            ));
        let peer = PeerConnection::new(
            &mut self.0.peer_connection_factory,
            dependencies,
        );
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
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection {
    /// ID of this [`PeerConnection`].
    id: PeerConnectionId,

    /// Underlying [`sys::PeerConnectionInterface`].
    inner: sys::PeerConnectionInterface,
}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
        dependencies: sys::PeerConnectionDependencies,
    ) -> anyhow::Result<Self> {
        let inner = factory.create_peer_connection_or_error(
            &sys::RTCConfiguration::default(),
            dependencies,
        )?;

        Ok(Self {
            id: PeerConnectionId::from(next_id()),
            inner,
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

/// [`PeerConnectionOnEventInterface`] wrapper.
struct HandlerPeerConnectionOnEvent {
    cb: UniquePtr<PeerConnectionOnEventInterface>,
    //ctx: Arc<Mutex<Context>>,
}

impl sys::PeerConnectionOnEvent for HandlerPeerConnectionOnEvent {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_signaling_change(&new_state);
    }

    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: sys::IceConnectionState,
    ) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb
            .pin_mut()
            .on_standardized_ice_connection_change(&new_state);
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_connection_change(&new_state);
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_ice_gathering_change(&new_state);
    }

    fn on_negotiation_needed_event(&mut self, event_id: u32) {
        self.cb.pin_mut().on_negotiation_needed_event(event_id);
    }

    fn on_ice_candidate_error(
        &mut self,
        host_candidate: &CxxString,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.cb.pin_mut().on_ice_candidate_error(
            host_candidate,
            url,
            error_code,
            error_text,
        );
    }

    fn on_ice_candidate_address_port_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.cb.pin_mut().on_ice_candidate_address_port_error(
            address, port, url, error_code, error_text,
        );
    }

    fn on_ice_connection_receiving_change(&mut self, receiving: bool) {
        self.cb
            .pin_mut()
            .on_ice_connection_receiving_change(receiving);
    }

    fn on_interesting_usage(&mut self, usage_pattern: i32) {
        self.cb.pin_mut().on_interesting_usage(usage_pattern);
    }

    fn on_ice_candidate(
        &mut self,
        candidate: *const sys::IceCandidateInterface,
    ) {
        let mut str_ice_candidate =
            unsafe { sys::ice_candidate_interface_to_string(candidate) };
        self.cb
            .pin_mut()
            .on_ice_candidate(&str_ice_candidate.pin_mut());
    }

    fn on_ice_candidates_removed(
        &mut self,
        candidates: Vec<libwebrtc_sys::CandidateWrap>,
    ) {
        unsafe {
            self.cb.pin_mut().on_ice_candidates_removed(
                candidates
                    .into_iter()
                    .map(|mut c| {
                        sys::candidate_to_string(&c.c.pin_mut()).to_string()
                    })
                    .collect(),
            );
        };
    }

    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        event: &sys::CandidatePairChangeEvent,
    ) {
        let pair = get_candidate_pair(event);
        let local = get_local_candidate(pair);
        let remote = get_remote_candidate(pair);

        let pair = crate::api::CandidatePairSerialized {
            local: sys::candidate_to_string(local).to_string(),
            remote: sys::candidate_to_string(remote).to_string(),
        };
        let candidate_pair_change_event_serialized =
            crate::api::CandidatePairChangeEventSerialized {
                selected_candidate_pair: pair,
                last_data_received_ms: get_last_data_received_ms(event),
                reason: get_reason(event).pin_mut().to_string(),
                estimated_disconnected_time_ms:
                    get_estimated_disconnected_time_ms(event),
            };

        unsafe {
            self.cb.pin_mut().on_ice_selected_candidate_pair_changed(
                candidate_pair_change_event_serialized,
            );
        };
    }

    fn on_track(&mut self, event: &crate::RtpTransceiverInterface) {
        // todo add track to webrtc context
        let receiver = rtp_transceiver_interface_get_receiver(event);
        let mut streams = rtp_receiver_interface_streams(&receiver);

        let mut vec_streams = vec![];
        for i in streams.pin_mut() {
            let mut audio_tracks = vec![];
            let mut at = media_stream_interface_get_audio_tracks(&i);
            for track in at.pin_mut() {
                audio_tracks.push(TrackInterfaceSerialized::from(
                    &track as &_AudioTrackInterface,
                ));
            }

            let mut video_tracks = vec![];
            let mut vt = media_stream_interface_get_video_tracks(&i);
            for track in vt.pin_mut() {
                video_tracks.push(TrackInterfaceSerialized::from(
                    &track as &_VideoTrackInterface,
                ));
            }

            let media = MediaStreamInterfaceSerialized {
                id: media_stream_interface_get_id(&i).to_string(),
                audio_tracks,
                video_tracks,
            };
            vec_streams.push(media);
        }

        let track = rtp_sender_interface_get_track(&receiver);

        let result = OnTrackSerialized {
            streams: vec_streams,
            track: TrackInterfaceSerialized::from(track),
        };
        self.cb.pin_mut().on_track(result);
    }

    // fn on_remove_track(&mut self, event: &RtpReceiverInterface) {
    //     todo!()
    // }
}
