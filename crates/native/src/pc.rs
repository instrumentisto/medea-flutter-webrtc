use std::sync::{mpsc::Sender, Arc, Mutex};

use anyhow::{anyhow, bail};
use once_cell::sync::OnceCell;
use sys::PeerConnectionInterface;
use threadpool::ThreadPool;

use crate::{
    api,
    api::{PeerConnectionEvent, SdpInfo},
    AudioTrack, AudioTrackId, VideoTrack, VideoTrackId, Webrtc,
};
use cxx::{CxxString, CxxVector};
use dashmap::DashMap;
use derive_more::{Display, From, Into};
use flutter_rust_bridge::StreamSink;
use libwebrtc_sys as sys;
use libwebrtc_sys::{MediaType, RtpTransceiverDirection};

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns its ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        obs: StreamSink<api::PeerConnectionEvent>,
        configuration: api::RtcConfiguration,
        id: u64,
    ) -> anyhow::Result<()> {
        let peer = PeerConnection::new(
            &mut self.peer_connection_factory,
            Arc::clone(&self.video_tracks),
            Arc::clone(&self.audio_tracks),
            obs,
            configuration,
            self.callback_pool.clone(),
            id,
        )?;
        self.peer_connections.insert(id.into(), peer);

        Ok(())
    }

    /// Initiates the creation of a SDP offer for the purpose of starting a new
    /// WebRTC connection to a remote peer.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn create_offer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: Sender<anyhow::Result<SdpInfo>>,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist");
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs =
            sys::CreateSessionDescriptionObserver::new(Box::new(CreateSdpCallback(cb)));
        peer.0.lock().unwrap().create_offer(&options, obs);

        Ok(())
    }

    /// Creates a SDP answer to an offer received from a remote peer during an
    /// offer/answer negotiation of a WebRTC connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    pub fn create_answer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: Sender<anyhow::Result<SdpInfo>>,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist");
        };

        let options = sys::RTCOfferAnswerOptions::new(
            None,
            None,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        let obs =
            sys::CreateSessionDescriptionObserver::new(Box::new(CreateSdpCallback(cb)));
        peer.0.lock().unwrap().create_answer(&options, obs);

        Ok(())
    }

    /// Changes the local description associated with the connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_local_description(
        &mut self,
        peer_id: u64,
        kind: sys::SdpType,
        sdp: String,
        cb: Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let desc = sys::SessionDescriptionInterface::new(kind, &sdp);
        let obs = sys::SetLocalDescriptionObserver::new(Box::new(SetSdpCallback(cb)));
        peer.0.lock().unwrap().set_local_description(desc, obs);

        Ok(())
    }

    /// Sets the specified session description as the remote peer's current
    /// offer or answer.
    ///
    /// Returns an empty [`String`] if operation succeeds or an error otherwise.
    ///
    /// # Panics
    ///
    /// If the mutex guarding the [`sys::PeerConnectionInterface`] is poisoned.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_remote_description(
        &mut self,
        peer_id: u64,
        kind: sys::SdpType,
        sdp: String,
        cb: Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let desc = sys::SessionDescriptionInterface::new(kind, &sdp);
        let obs = sys::SetRemoteDescriptionObserver::new(Box::new(SetSdpCallback(cb)));
        peer.0.lock().unwrap().set_remote_description(desc, obs);

        Ok(())
    }

    /// Creates a new [`api::RtcRtpTransceiver`] and adds it to the set of
    /// transceivers of the specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot parse the given `media_type` and `direction` to a valid
    ///   [`sys::MediaType`] and [`sys::RtpTransceiverDirection`].
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex that guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn add_transceiver(
        &mut self,
        peer_id: u64,
        media_type: MediaType,
        direction: RtpTransceiverDirection,
    ) -> anyhow::Result<api::RtcRtpTransceiver> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };
        let mut peer_ref = peer.0.lock().unwrap();

        let transceiver = peer_ref.add_transceiver(media_type, direction);

        let transceivers = peer_ref.get_transceivers();
        let id = transceivers
            .iter()
            .enumerate()
            .find(|(_, t)| transceiver.mid() == t.mid())
            .map(|(id, _)| id)
            .unwrap();

        Ok(api::RtcRtpTransceiver {
            peer_id,
            id: id as u64,
            mid: transceiver.mid(),
            direction: transceiver.direction().into(),
            sender: api::RtcRtpSender { id: id as u64 },
        })
    }

    /// Returns a sequence of [`api::RtcRtpTransceiver`] objects representing
    /// the RTP transceivers currently attached to specified [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn get_transceivers(
        &mut self,
        peer_id: u64,
    ) -> anyhow::Result<Vec<api::RtcRtpTransceiver>> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();
        let mut result = Vec::with_capacity(transceivers.len());

        for (index, transceiver) in transceivers.into_iter().enumerate() {
            let info = api::RtcRtpTransceiver {
                peer_id,
                id: index as u64,
                mid: transceiver.mid(),
                direction: transceiver.direction().into(),
                sender: api::RtcRtpSender { id: index as u64 },
            };
            result.push(info);
        }

        Ok(result)
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
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn set_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        direction: api::RtpTransceiverDirection,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(usize::try_from(transceiver_id).unwrap())
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_id}` does not exist",);
        };

        transceiver.set_direction(direction.into())
    }

    /// Returns the [Negotiated media ID (mid)][1] of the specified
    /// [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    ///
    /// [1]: https://w3.org/TR/webrtc#dfn-media-stream-identification-tag
    pub fn get_transceiver_mid(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> anyhow::Result<Option<String>> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(usize::try_from(transceiver_id).unwrap())
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_id}` does not exist",);
        };

        Ok(transceiver.mid())
    }

    /// Returns the preferred direction of the specified [`RtcRtpTransceiver`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn get_transceiver_direction(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> anyhow::Result<RtpTransceiverDirection> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(usize::try_from(transceiver_id).unwrap())
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_id}` does not exist",);
        };

        Ok(transceiver.direction())
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
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn stop_transceiver(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(usize::try_from(transceiver_id).unwrap())
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_id}` does not exist",);
        };

        transceiver.stop()
    }

    /// Replaces the specified [`AudioTrack`] (or [`crate::VideoTrack`]) on
    /// the [`sys::Transceiver`]'s `sender`.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot find any [`RtpTransceiverInterface`]s by the specified
    ///   `transceiver_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    ///
    /// [`AudioTrack`]: crate::AudioTrack
    /// [`VideoTrack`]: crate::VideoTrack
    pub fn sender_replace_track(
        &mut self,
        peer_id: u64,
        transceiver_id: u64,
        track_id: Option<u64>,
    ) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist",);
        };

        let transceivers = peer.0.lock().unwrap().get_transceivers();

        let transceiver = if let Some(transceiver) =
            transceivers.get(usize::try_from(transceiver_id).unwrap())
        {
            transceiver
        } else {
            bail!("`Transceiver` with ID `{transceiver_id}` does not exist",);
        };

        let sender = transceiver.sender();

        if let Some(track_id) = track_id {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => sender.replace_video_track(Some(
                    self.video_tracks
                        .get(&VideoTrackId::from(track_id))
                        .unwrap()
                        .as_ref(),
                )),
                sys::MediaType::MEDIA_TYPE_AUDIO => sender.replace_audio_track(Some(
                    self.audio_tracks
                        .get(&AudioTrackId::from(track_id))
                        .unwrap()
                        .as_ref(),
                )),
                _ => unreachable!(),
            }
        } else {
            match transceiver.media_type() {
                sys::MediaType::MEDIA_TYPE_VIDEO => sender.replace_video_track(None),
                sys::MediaType::MEDIA_TYPE_AUDIO => sender.replace_audio_track(None),
                _ => unreachable!(),
            }
        }
    }

    /// Adds a [`sys::IceCandidateInterface`] to the given [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If cannot add the given [`sys::IceCandidateInterface`].
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn add_ice_candidate(
        &mut self,
        peer_id: u64,
        candidate: &str,
        sdp_mid: &str,
        sdp_mline_index: i32,
        cb: Sender<anyhow::Result<()>>,
    ) -> anyhow::Result<()> {
        let candidate =
            sys::IceCandidateInterface::new(sdp_mid, sdp_mline_index, candidate).unwrap();

        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist");
        };

        peer.0
            .lock()
            .unwrap()
            .add_ice_candidate(candidate, Box::new(AddIceCandidateCallback(cb)));

        Ok(())
    }

    /// Tells the [`PeerConnection`] that ICE should be restarted.
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn restart_ice(&mut self, peer_id: u64) -> anyhow::Result<()> {
        let peer = if let Some(peer) = self
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            bail!("`PeerConnection` with ID `{peer_id}` does not exist");
        };

        peer.0.lock().unwrap().restart_ice();

        Ok(())
    }

    /// Closes the [`PeerConnection`].
    ///
    /// # Panics
    ///
    /// - If cannot find any [`PeerConnection`]s by the specified `peer_id`.
    /// - If the mutex guarding the [`sys::PeerConnectionInterface`] is
    ///   poisoned.
    pub fn dispose_peer_connection(&mut self, peer_id: u64) -> anyhow::Result<()> {
        let peer =
            if let Some(peer) = self.peer_connections.remove(&PeerConnectionId(peer_id)) {
                peer
            } else {
                bail!("`PeerConnection` with ID `{peer_id}` does not exist");
            };

        peer.0.lock().unwrap().close();

        Ok(())
    }
}

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Wrapper around a [`sys::PeerConnectionInterface`] with a unique ID.
//todo delete pub (crate)
pub struct PeerConnection(pub(crate) Arc<Mutex<sys::PeerConnectionInterface>>);

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
        video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,
        audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,
        observer: StreamSink<api::PeerConnectionEvent>,
        configuration: api::RtcConfiguration,
        pool: ThreadPool,
        id: u64,
    ) -> anyhow::Result<Self> {
        let obs_peer = Arc::new(OnceCell::new());
        let observer = sys::PeerConnectionObserver::new(Box::new(PeerConnectionObserver {
            observer: Arc::new(Mutex::new(observer)),
            peer: Arc::clone(&obs_peer),
            video_tracks,
            audio_tracks,
            pool,
        }));

        let mut sys_configuration = sys::RtcConfiguration::default();

        if !configuration.ice_transport_policy.is_empty() {
            sys_configuration.set_ice_transport_type(
                configuration.ice_transport_policy.as_str().try_into()?,
            );
        }

        if !configuration.bundle_policy.is_empty() {
            sys_configuration
                .set_bundle_policy(configuration.bundle_policy.as_str().try_into()?);
        }

        for server in configuration.ice_servers {
            let mut ice_server = sys::IceServer::default();
            let mut have_ice_servers = false;

            for url in server.urls {
                if !url.is_empty() {
                    ice_server.add_url(url);
                    have_ice_servers = true;
                }
            }

            if have_ice_servers {
                if !server.username.is_empty() || !server.credential.is_empty() {
                    ice_server.set_credentials(server.username, server.credential);
                }

                sys_configuration.add_server(ice_server);
            }
        }

        let inner = factory.create_peer_connection_or_error(
            &sys_configuration,
            sys::PeerConnectionDependencies::new(observer),
            id,
        )?;

        let inner_peer = Arc::new(Mutex::new(inner));
        obs_peer.set(Arc::clone(&inner_peer)).unwrap_or_default();

        Ok(Self(inner_peer))
    }
}

/// [`CreateSdpCallbackInterface`] wrapper.
struct CreateSdpCallback(Sender<anyhow::Result<SdpInfo>>);

impl sys::CreateSdpCallback for CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: sys::SdpType) {
        self.0
            .send(Ok(SdpInfo::new(sdp.to_string(), kind)))
            .unwrap();
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.send(Err(anyhow!("{}", error.to_string()))).unwrap();
    }
}

/// [`SetDescriptionCallbackInterface`] wrapper.
struct SetSdpCallback(Sender<anyhow::Result<()>>);

impl sys::SetDescriptionCallback for SetSdpCallback {
    fn success(&mut self) {
        // self.0.pin_mut().on_set_description_sucess();
        self.0.send(Ok(())).unwrap();
    }

    fn fail(&mut self, error: &CxxString) {
        // self.0.pin_mut().on_set_description_fail(error);
        self.0.send(Err(anyhow!("{}", error.to_string()))).unwrap();
    }
}

/// [`PeerConnectionObserverInterface`] wrapper.
struct PeerConnectionObserver {
    /// [`PeerConnectionObserverInterface`] to forward the events to.
    observer: Arc<Mutex<StreamSink<api::PeerConnectionEvent>>>,

    /// [`InnerPeer`] of the [`PeerConnection`] internally used in
    /// [`sys::PeerConnectionObserver::on_track()`][1]
    ///
    /// Tasks with [`InnerPeer`] must be offloaded to a separate [`ThreadPool`],
    /// so the signalling thread wouldn't be blocked.
    peer: Arc<OnceCell<Arc<Mutex<PeerConnectionInterface>>>>,

    /// Map of the remote [`VideoTrack`]s shared with the [`crate::Webrtc`].
    video_tracks: Arc<DashMap<VideoTrackId, VideoTrack>>,

    /// Map of the remote [`AudioTrack`]s shared with the [`crate::Webrtc`].
    audio_tracks: Arc<DashMap<AudioTrackId, AudioTrack>>,

    /// [`ThreadPool`] executing blocking tasks from the
    /// [`PeerConnectionObserver`] callbacks.
    pool: ThreadPool,
}

impl sys::PeerConnectionEventsHandler for PeerConnectionObserver {
    fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
        self.observer
            .lock()
            .unwrap()
            .add(api::PeerConnectionEvent::OnSignallingChange(
                new_state.into(),
            ));
    }

    fn on_standardized_ice_connection_change(&mut self, new_state: sys::IceConnectionState) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::OnIceConnectionStateChange(new_state.into()),
        );
    }

    fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::OnConnectionStateChange(new_state.into()),
        );
    }

    fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
        self.observer.lock().unwrap().add(
            api::PeerConnectionEvent::OnIceGatheringStateChange(new_state.into()),
        );
    }

    fn on_negotiation_needed_event(&mut self, _: u32) {
        self.observer
            .lock()
            .unwrap()
            .add(api::PeerConnectionEvent::OnNegotiationNeeded);
    }

    fn on_ice_candidate_error(
        &mut self,
        address: &CxxString,
        port: i32,
        url: &CxxString,
        error_code: i32,
        error_text: &CxxString,
    ) {
        self.observer
            .lock()
            .unwrap()
            .add(api::PeerConnectionEvent::OnIceCandidateError {
                address: address.to_string(),
                port: port as i64,
                url: url.to_string(),
                error_code: error_code as i64,
                error_text: error_text.to_string(),
            });
    }

    fn on_ice_connection_receiving_change(&mut self, _: bool) {
        // This is a non-spec-compliant event.
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

        self.pool.execute({
            // PANIC: Unwrapping is OK, since the transceiver is guaranteed
            //        to be negotiated at this point.
            let mid = transceiver.mid();
            let direction = transceiver.direction();
            let peer = Arc::clone(&self.peer);
            let observer = Arc::clone(&self.observer);

            move || {
                let peer = peer.get().unwrap().lock().unwrap();
                let index = peer
                    .get_transceivers()
                    .iter()
                    .enumerate()
                    .find(|(_, t)| {
                        t.mid().as_ref() == Some(&mid.as_ref().unwrap().to_string())
                    })
                    .map(|(id, _)| id)
                    .unwrap();

                let result = api::RtcTrackEvent {
                    track,
                    transceiver: api::RtcRtpTransceiver {
                        id: index as u64,
                        mid,
                        direction: direction.try_into().unwrap(),
                        sender: api::RtcRtpSender { id: index as u64 },
                        peer_id: peer.id(),
                    },
                };

                observer
                    .lock()
                    .unwrap()
                    .add(api::PeerConnectionEvent::OnTrack(result));
            }
        });
    }

    fn on_ice_candidate(&mut self, candidate: sys::IceCandidateInterface) {
        self.observer
            .lock()
            .unwrap()
            .add(PeerConnectionEvent::OnIceCandidate {
                sdp_mid: candidate.mid(),
                sdp_mline_index: candidate.mline_index() as i64,
                candidate: candidate.candidate(),
            });
    }

    fn on_ice_candidates_removed(&mut self, _: &CxxVector<sys::Candidate>) {
        // This is a non-spec-compliant event.
    }

    fn on_ice_selected_candidate_pair_changed(&mut self, _: &sys::CandidatePairChangeEvent) {
        // This is a non-spec-compliant event.
    }

    fn on_remove_track(&mut self, _: sys::RtpReceiverInterface) {
        // This is a non-spec-compliant event.
    }
}

/// [`sys::AddIceCandidateCallback`] wrapper.
pub struct AddIceCandidateCallback(Sender<anyhow::Result<()>>);

impl sys::AddIceCandidateCallback for AddIceCandidateCallback {
    fn on_success(&mut self) {
        // self.0.pin_mut().on_add_ice_candidate_success();
        self.0.send(Ok(())).unwrap();
    }

    fn on_fail(&mut self, error: &CxxString) {
        // self.0.pin_mut().on_add_ice_candidate_fail(error);
        self.0.send(Err(anyhow!("{}", error.to_string()))).unwrap();
    }
}
