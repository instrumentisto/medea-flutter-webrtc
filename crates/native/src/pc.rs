use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};

use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;
use sys::{
    get_audio_track_sourse, get_media_stream_track_kind,
    get_rtp_receiver_track, get_transceiver_receiver, get_video_track_sourse,
    media_stream_track_interface_downcast_audio_track,
    media_stream_track_interface_downcast_video_track, AudioSourceInterface,
    AudioTrackInterface, MediaStreamTrackInterface, Sys_RtpReceiverInterface,
    Sys_RtpTransceiverInterface, VideoTrackInterface,
    VideoTrackSourceInterface,
};

use crate::{
    api::{
        self, OnTrackSerialized, RtpTransceiverInterfaceSerialized,
        TrackInterfaceSerialized,
    },
    AudioTrack, AudioTrackId, VideoTrack, VideoTrackId,
};

use crate::{
    internal::{
        CreateSdpCallbackInterface, PeerConnectionObserverInterface,
        SetDescriptionCallbackInterface,
    },
    next_id, Webrtc,
};

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        obs: UniquePtr<PeerConnectionObserverInterface>,
        error: &mut String,
    ) -> u64 {
        let peer = PeerConnection::new(
            &mut self.0.peer_connection_factory,
            obs,
            self.0.video_tracks.clone(),
            self.0.audio_tracks.clone(),
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

    /// Creates a new [`api::RtcRtpTransceiver`] and adds it to the set of
    /// transceivers of the specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot parse the given `media_type` and `direction` to a valid
    ///   [`sys::MediaType`] and [`sys::RtpTransceiverDirection`].
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    pub fn add_transceiver(
        &mut self,
        peer_id: u64,
        media_type: &str,
        direction: &str,
    ) -> api::RtcRtpTransceiver {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let transceiver = peer.inner.add_transceiver(
            media_type.try_into().unwrap(),
            direction.try_into().unwrap(),
        );

        let result = api::RtcRtpTransceiver {
            id: peer.transceivers.len() as u64,
            mid: transceiver.mid().unwrap_or_default(),
            direction: transceiver.direction().to_string(),
        };

        peer.transceivers.push(transceiver);

        result
    }

    /// Returns a sequence of [`api::RtcRtpTransceiver`] objects representing
    /// the RTP transceivers currently attached to specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    pub fn get_transceivers(
        &mut self,
        peer_id: u64,
    ) -> Vec<api::RtcRtpTransceiver> {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let transceivers = peer.inner.get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                id: index as u64,
                mid: transceiver.mid().unwrap_or_default(),
                direction: transceiver.direction().to_string(),
            };
            result.push(info);

            if index == peer.transceivers.len() {
                peer.transceivers.push(transceiver);
            }
        }

        result
    }

    /// Changes the preferred `direction` of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If cannot parse the given `direction` as a valid
    ///   [`sys::RtpTransceiverDirection`].
    pub fn set_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        direction: &str,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .set_direction(direction.try_into().unwrap())
            .map_or_else(|err| err.to_string(), |_| String::new())
    }

    /// Returns the [Negotiated media ID (mid)][1] of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub fn get_transceiver_mid(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .mid()
            .unwrap_or_default()
    }

    /// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    pub fn get_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .direction()
            .to_string()
    }

    /// Irreversibly marks the specified [`RtcRtpTransceiver`] as stopping,
    /// unless it's already stopped.
    ///
    /// This will immediately cause the transceiver's sender to no longer send,
    /// and its receiver to no longer receive.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    pub fn stop_transceiver(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        peer.transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap()
            .stop()
            .map_or_else(|err| err.to_string(), |_| String::new())
    }

    /// Frees the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    pub fn dispose_transceiver(&mut self, peer_id: u64, transceiver_id: u64) {
        self.0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap()
            .transceivers
            .remove(usize::try_from(transceiver_id).unwrap());
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

    /// [`sys::Transceiver`]s of this [`PeerConnection`].
    transceivers: Vec<sys::RtpTransceiverInterface>,
}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
        observer: UniquePtr<PeerConnectionObserverInterface>,
        remote_video_tracks: Arc<Mutex<HashMap<VideoTrackId, VideoTrack>>>,
        remote_audio_tracks: Arc<Mutex<HashMap<AudioTrackId, AudioTrack>>>,
    ) -> anyhow::Result<Self> {
        let observer = sys::PeerConnectionObserver::new(Box::new(
            PeerConnectionObserver {
                cb: observer,
                remote_video_tracks,
                remote_audio_tracks,
            },
        ));
        let inner = factory.create_peer_connection_or_error(
            &sys::RTCConfiguration::default(),
            sys::PeerConnectionDependencies::new(observer),
        )?;

        Ok(Self {
            id: PeerConnectionId::from(next_id()),
            inner,
            transceivers: Vec::new(),
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

/// [`PeerConnectionObserverInterface`] wrapper.
struct PeerConnectionObserver {
    cb: UniquePtr<PeerConnectionObserverInterface>,
    remote_video_tracks: Arc<Mutex<HashMap<VideoTrackId, VideoTrack>>>,
    remote_audio_tracks: Arc<Mutex<HashMap<AudioTrackId, AudioTrack>>>,
}

impl sys::PeerConnectionEventsHandler for PeerConnectionObserver {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_signaling_change(&new_state);
    }

    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: sys::IceConnectionState,
    ) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_ice_connection_state_change(&new_state);
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_connection_state_change(&new_state);
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.pin_mut().on_ice_gathering_change(&new_state);
    }

    fn on_negotiation_needed_event(&mut self, _: u32) {
        self.cb.pin_mut().on_negotiation_needed();
    }

    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.cb
            .pin_mut()
            .on_ice_candidate_error(address, port, url, error_code, error_text);
    }

    fn on_ice_connection_receiving_change(&mut self, _: bool) {
        // This is a non-spec-compliant event.
    }

    fn on_ice_candidate(
        &mut self,
        candidate: *const sys::IceCandidateInterface,
    ) {
        let mut string =
            unsafe { sys::ice_candidate_interface_to_string(candidate) };
        self.cb.pin_mut().on_ice_candidate(&string.pin_mut());
    }

    fn on_ice_candidates_removed(&mut self, _: &CxxVector<sys::Candidate>) {
        // This is a non-spec-compliant event.
    }

    fn on_ice_selected_candidate_pair_changed(
        &mut self,
        _: &sys::CandidatePairChangeEvent,
    ) {
        // This is a non-spec-compliant event.
    }

    fn on_track(&mut self, mut event: UniquePtr<Sys_RtpTransceiverInterface>) {
        let receiver = get_transceiver_receiver(&event);
        let track = get_rtp_receiver_track(&receiver);
        let id = next_id();

        if get_media_stream_track_kind(&track).to_string() == "video" {
            let inner = VideoTrackInterface::from((
                media_stream_track_interface_downcast_video_track(track),
                HashMap::new(),
            ));

            let source = get_video_track_sourse(inner.inner());
            let v = VideoTrack::new_from_video_interface(
                inner,
                VideoTrackSourceInterface::from(source),
                "remote".to_owned(),
            );
            self.remote_video_tracks
                .lock()
                .unwrap()
                .insert(id.into(), v);
        } else {
            let inner = AudioTrackInterface::from((
                media_stream_track_interface_downcast_audio_track(track),
                HashMap::new(),
            ));

            let source = get_audio_track_sourse(inner.inner());
            let a = AudioTrack::new_from_audio_interface(
                inner,
                AudioSourceInterface::from(source),
                "audio".to_owned(),
            );
            self.remote_audio_tracks
                .lock()
                .unwrap()
                .insert(id.into(), a);
        }

        let track = get_rtp_receiver_track(&receiver);
        let result = OnTrackSerialized {
            track: TrackInterfaceSerialized::from((
                &track as &MediaStreamTrackInterface,
                id,
                "remote".to_owned(),
            )),
            transceiver: RtpTransceiverInterfaceSerialized::from(
                &event.pin_mut() as &Sys_RtpTransceiverInterface,
            ),
        };
        self.cb.pin_mut().on_track(result);
    }

    fn on_remove_track(&mut self, _: &Sys_RtpReceiverInterface) {
        // Not required at the moment.
    }
}
