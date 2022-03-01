use std::{sync::{Arc, Mutex}, thread};

use cxx::{let_cxx_string, CxxString, CxxVector, UniquePtr};
use dashmap::DashMap;
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;
use crate::{
    api,
    internal::{
        CreateSdpCallbackInterface, PeerConnectionObserverInterface,
        SetDescriptionCallbackInterface,
    },
    next_id, AudioTrack, AudioTrackId, VideoTrack, VideoTrackId, Webrtc,
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
            Arc::clone(&self.0.video_tracks),
            Arc::clone(&self.0.audio_tracks),
        );
        match peer {
            Ok(peer) => {
                let id = peer.0.lock().unwrap().id;
                self
                .0
                .peer_connections
                .entry(id)
                .or_insert(peer)
                .0.lock().unwrap()
                .id
                .into()}
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
        peer.0.lock().unwrap().inner.create_offer(&options, obs);

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
        peer.0.lock().unwrap().inner.create_answer(&options, obs);

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
        peer.0.lock().unwrap().inner.set_local_description(desc, obs);

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
        let mut lock = peer.0.lock().unwrap();

        // very dirty 
        {
            let ptr: *mut InnerPeer = &mut *lock;
            drop(lock);
            unsafe {(*ptr).inner.set_remote_description(desc, obs)};
        }


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

        let transceiver = peer.0.lock().unwrap().inner.add_transceiver(
            media_type.try_into().unwrap(),
            direction.try_into().unwrap(),
        );

        let mut lock = peer.0.lock().unwrap();
        let transceivers = &mut lock.transceivers;
        let mid = transceiver.mid().unwrap_or_default();
        let direction = transceiver.direction().to_string();
        let id = if let Some((id, _)) = transceivers
            .iter()
            .enumerate()
            .find(|(_, a)| transceiver.eq(a))
        {
            id
        } else {
            transceivers.push(transceiver);
            transceivers.len() - 1
        };

        api::RtcRtpTransceiver {
            id: id as u64,
            mid,
            direction,
            sender: api::RtcRtpSender { id: id as u64 },
        }
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

        let transceivers = peer.0.lock().unwrap().inner.get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                id: index as u64,
                mid: transceiver.mid().unwrap_or_default(),
                direction: transceiver.direction().to_string(),
                sender: api::RtcRtpSender { id: index as u64 },
            };
            result.push(info);
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

        peer.0.lock().unwrap()
            .transceivers
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

        peer.0.lock().unwrap()
            .transceivers
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

        peer.0.lock().unwrap()
            .transceivers
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

        peer.0.lock().unwrap()
            .transceivers
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
            .0.lock().unwrap()
            .transceivers
            .remove(usize::try_from(transceiver_id).unwrap());
    }

    /// Replaces the specified [`AudioTrack`] (or [`crate::VideoTrack`]) on
    /// the [`sys::Transceiver`]'s `sender`.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    ///
    /// [`AudioTrack`]: crate::AudioTrack
    /// [`VideoTrack`]: crate::VideoTrack
    pub fn sender_replace_track(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        track_id: u64,
    ) -> String {
        let peer = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        let lock = peer.0.lock().unwrap();
        let transceivers = &lock.transceivers;

        let transceiver = transceivers
            .get(usize::try_from(transceiver_id).unwrap())
            .unwrap();

        let sender = transceiver.sender();

        if track_id == 0 {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    sender.replace_video_track(None)
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    sender.replace_audio_track(None)
                }
                _ => unreachable!(),
            }
        } else {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => {
                    sender.replace_video_track(Some(
                        self.0
                            .video_tracks
                            .get(&VideoTrackId::from(track_id))
                            .unwrap()
                            .as_ref(),
                    ))
                }
                sys::MediaType::MEDIA_TYPE_AUDIO => {
                    sender.replace_audio_track(Some(
                        self.0
                            .audio_tracks
                            .get(&AudioTrackId::from(track_id))
                            .unwrap()
                            .as_ref(),
                    ))
                }
                _ => unreachable!(),
            }
        }
        .map_or_else(|e| e.to_string(), |_| String::new())
    }
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

struct InnerPeer {
    /// ID of this [`PeerConnection`].
    id: PeerConnectionId,

    /// Underlying [`sys::PeerConnectionInterface`].
    inner: sys::PeerConnectionInterface,

    /// [`sys::Transceiver`]s of this [`PeerConnection`].
    transceivers: Vec<sys::RtpTransceiverInterface>,
}

// todo
unsafe impl Send for InnerPeer { }

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
pub struct PeerConnection(Arc<Mutex<InnerPeer>>);

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
        cb: UniquePtr<PeerConnectionObserverInterface>,
        video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
        audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
    ) -> anyhow::Result<Self> {
        let inn = Arc::new(Mutex::new(None));
        let observer = sys::PeerConnectionObserver::new(Box::new(
            PeerConnectionObserver {
                cb: Arc::new(Mutex::new(cb)),
                pc: inn.clone(),
                video_tracks,
                audio_tracks,
            },
        ));
        let inner = factory.create_peer_connection_or_error(
            &sys::RTCConfiguration::default(),
            sys::PeerConnectionDependencies::new(observer),
        )?;

        let inner = Arc::new(Mutex::new(InnerPeer {
            id: PeerConnectionId::from(next_id()),
            inner,
            transceivers: vec![],
        }));
        inn.lock().unwrap().replace(inner.clone());
        let pc = Self(inner);

        Ok(pc)
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
    /// [`PeerConnectionObserverInterface`] that the events will be forwarded
    /// to.
    cb: Arc<Mutex<UniquePtr<PeerConnectionObserverInterface>>>,

    /// Vec of [`PeerConnection`] transceivers.
    pc: Arc<Mutex<Option<Arc<Mutex<InnerPeer>>>>>,

    /// Map of remote [`VideoTrack`]s shared with the [`crate::Webrtc`].
    video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,

    /// Map of remote [`AudioTrack`]s shared with the [`crate::Webrtc`].
    audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
}

impl sys::PeerConnectionEventsHandler for PeerConnectionObserver {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.lock().unwrap().pin_mut().on_signaling_change(&new_state);
    }

    fn on_standardized_ice_connection_change(
        &mut self,
        new_state: sys::IceConnectionState,
    ) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.lock().unwrap().pin_mut().on_ice_connection_state_change(&new_state);
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.lock().unwrap().pin_mut().on_connection_state_change(&new_state);
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        let_cxx_string!(new_state = new_state.to_string());
        self.cb.lock().unwrap().pin_mut().on_ice_gathering_change(&new_state);
    }

    fn on_negotiation_needed_event(&mut self, _: u32) {
        self.cb.lock().unwrap().pin_mut().on_negotiation_needed();
    }

    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.cb.lock().unwrap()
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
        self.cb.lock().unwrap().pin_mut().on_ice_candidate(&string.pin_mut());
    }

    fn on_track(&mut self, transceiver: sys::RtpTransceiverInterface) {
        let track = match transceiver.media_type() {
            sys::MediaType::MEDIA_TYPE_AUDIO => {
                let track = AudioTrack::wrap_remote(&transceiver);
                let result = api::MediaStreamTrack::from(&track);
                self.audio_tracks.insert(track.id(), track);

                result
            }
            sys::MediaType::MEDIA_TYPE_VIDEO => {
                let track = VideoTrack::wrap_remote(&transceiver);
                let result = api::MediaStreamTrack::from(&track);
                self.video_tracks.insert(track.id(), track);

                result
            }
            _ => unreachable!(),
        };

        let pc = self.pc.clone();
        let cb = self.cb.clone();
        thread::spawn(move || {
            let mut lock = pc.lock().unwrap();
            let mut lock = lock.as_mut().unwrap().lock().unwrap();
            lock.inner.add_transceiver(transceiver.media_type(), transceiver.direction());
            let transceivers = &mut lock.transceivers;
            transceivers.push(transceiver);
            let id = transceivers.len() - 1;
            let result = api::RtcTrackEvent {
                track,
                transceiver: api::RtcRtpTransceiver {
                    id: id as u64,
                    mid: "".to_string(),
                    direction: "".to_string(),
                    sender: api::RtcRtpSender { id: id as u64 },
                },
            };
            cb.lock().unwrap().pin_mut().on_track(result);
        });
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

    fn on_remove_track(&mut self, _: sys::RtpReceiverInterface) {
        // This is a non-spec-compliant event.
    }
}
