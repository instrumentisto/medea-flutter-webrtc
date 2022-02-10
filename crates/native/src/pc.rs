use std::sync::{Arc, Mutex};

use cxx::{let_cxx_string, CxxString, UniquePtr};
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;
use sys::{
    get_candidate_pair, get_estimated_disconnected_time_ms,
    get_last_data_received_ms, get_local_candidate, get_remote_candidate,
    PeerConnectionObserver, _AudioTrackInterface, _RtpReceiverInterface,
    _VideoTrackInterface, audio_track_get_sourse,
    dtmf_sender_interface_get_duration,
    dtmf_sender_interface_get_inter_tone_gap, get_reason,
    media_stream_interface_get_audio_tracks,
    media_stream_interface_get_video_tracks,
    media_stream_track_interface_downcast_audio_track,
    media_stream_track_interface_downcast_video_track,
    rtcp_parameters_get_cname, rtcp_parameters_get_reduced_size,
    rtp_codec_parameters_get_clock_rate, rtp_codec_parameters_get_kind,
    rtp_codec_parameters_get_name, rtp_codec_parameters_get_num_channels,
    rtp_codec_parameters_get_parameters, rtp_codec_parameters_get_payload_type,
    rtp_encoding_parameters_get_active, rtp_encoding_parameters_get_maxBitrate,
    rtp_encoding_parameters_get_maxFramerate,
    rtp_encoding_parameters_get_minBitrate,
    rtp_encoding_parameters_get_scale_resolution_down_by,
    rtp_encoding_parameters_get_ssrc, rtp_extension_get_encrypt,
    rtp_extension_get_id, rtp_extension_get_uri, rtp_parameters_get_codecs,
    rtp_parameters_get_encodings, rtp_parameters_get_header_extensions,
    rtp_parameters_get_mid, rtp_parameters_get_rtcp,
    rtp_parameters_get_transaction_id, rtp_receiver_interface_get_id,
    rtp_receiver_interface_get_parameters, rtp_receiver_interface_get_track,
    rtp_sender_interface_get_dtmf, rtp_sender_interface_get_id,
    rtp_sender_interface_get_parameters, rtp_sender_interface_get_track,
    rtp_transceiver_interface_get_direction, rtp_transceiver_interface_get_mid,
    rtp_transceiver_interface_get_sender, video_track_get_sourse,
    AudioSourceInterface, AudioTrackInterface, DtmfSenderInterface,
    MediaStreamTrackInterface, RtpCodecParameters, RtpEncodingParameters,
    RtpExtension, RtpParameters, RtpSenderInterface, RtpTransceiverInterface,
    VideoTrackInterface, VideoTrackSourceInterface,
};

use sys::{
    audio_track_truncation, media_stream_interface_get_id,
    media_stream_track_interface_get_enabled,
    media_stream_track_interface_get_id, media_stream_track_interface_get_kind,
    media_stream_track_interface_get_state, rtp_receiver_interface_get_streams,
    rtp_transceiver_interface_get_receiver, video_track_truncation,
};

use crate::{
    api::{
        DtmfSenderInterfaceSerialized, MediaStreamInterfaceSerialized,
        OnTrackSerialized, PeerConnectionOnEventInterface,
        RtcpParametersSerialized, RtpCodecParametersSerialized,
        RtpEncodingParametersSerialized, RtpExtensionSerialized,
        RtpParametersSerialized, RtpReceiverInterfaceSerialized,
        RtpSenderInterfaceSerialized, RtpTransceiverInterfaceSerialized,
        StringPair, TrackInterfaceSerialized,
    },
    AudioTrack, Context, VideoTrack, VideoTrackId,
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
                Box::new(HandlerPeerConnectionOnEvent {
                    cb,
                    ctx: self.0.as_ref().clone(),
                }),
            ));

        let mut ctx = self.0.lock().unwrap();
        let peer =
            PeerConnection::new(&mut ctx.peer_connection_factory, dependencies);
        match peer {
            Ok(peer) => ctx
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
        let mut ctx = self.0.lock().unwrap();
        let peer = if let Some(peer) = ctx
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
        let mut ctx = self.0.lock().unwrap();
        let peer = if let Some(peer) = ctx
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
        let mut ctx = self.0.lock().unwrap();
        let peer = if let Some(peer) = ctx
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
        let mut ctx = self.0.lock().unwrap();
        let peer = if let Some(peer) = ctx
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
    ctx: Arc<Mutex<Context>>,
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
        let receiver = rtp_transceiver_interface_get_receiver(event);
        let mut streams = rtp_receiver_interface_get_streams(&receiver);

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
                streamId: media_stream_interface_get_id(&i).to_string(),
                audio_tracks,
                video_tracks,
                // ownerTag: todo!(),
            };
            vec_streams.push(media);
        }

        let mut track = rtp_receiver_interface_get_track(&receiver);

        if media_stream_track_interface_get_kind(&track.pin_mut()).to_string()
            == "video"
        {
            let id = media_stream_track_interface_get_id(&track.pin_mut())
                .to_string()
                .parse::<u64>()
                .unwrap();

            let inner = VideoTrackInterface::new(
                media_stream_track_interface_downcast_video_track(
                    track.pin_mut(),
                ),
            );
            let source = video_track_get_sourse(inner.inner());
            let v = VideoTrack::my_new(
                inner,
                VideoTrackSourceInterface::my_new(source),
            );
            self.ctx.lock().unwrap().video_tracks.insert(id.into(), v);
        } else {
            let id = media_stream_track_interface_get_id(&track.pin_mut())
                .to_string()
                .parse::<u64>()
                .unwrap();

            let inner = AudioTrackInterface::new(
                media_stream_track_interface_downcast_audio_track(
                    track.pin_mut(),
                ),
            );
            let source = audio_track_get_sourse(inner.inner());
            let a =
                AudioTrack::my_new(inner, AudioSourceInterface::new(source));
            self.ctx.lock().unwrap().audio_tracks.insert(id.into(), a);
        }

        let result = OnTrackSerialized {
            streams: vec_streams,
            track: TrackInterfaceSerialized::from(
                &track as &MediaStreamTrackInterface,
            ),
            receiver: rec_to_ser(&receiver),
            transceiver: tran_ser(event),
        };
        self.cb.pin_mut().on_track(result);
    }

    fn on_remove_track(&mut self, event: &_RtpReceiverInterface) {
        self.cb.pin_mut().on_remove_track(rec_to_ser(event));
    }
}

fn tran_ser(
    transceiver: &RtpTransceiverInterface,
) -> RtpTransceiverInterfaceSerialized {
    let rec = rtp_transceiver_interface_get_receiver(transceiver);
    let sender = rtp_transceiver_interface_get_sender(transceiver);
    RtpTransceiverInterfaceSerialized {
        transceiverId: rtp_transceiver_interface_get_mid(transceiver).to_string(),
        mid: rtp_transceiver_interface_get_mid(transceiver).to_string(),
        direction: rtp_transceiver_interface_get_direction(transceiver)
            .to_string(),
        sender: send_rec(&sender),
        receiver: rec_to_ser(&rec),
    }
}

fn send_rec(sender: &RtpSenderInterface) -> RtpSenderInterfaceSerialized {
    let params = rtp_sender_interface_get_parameters(sender);
    let track = rtp_sender_interface_get_track(sender);
    let dtfm = rtp_sender_interface_get_dtmf(sender);
    let id = rtp_sender_interface_get_id(sender).to_string();
    let dtmf_ser = if dtfm.is_null() {DtmfSenderInterfaceSerialized::default()} else {dtmf_ser(&dtfm, &id)};
    RtpSenderInterfaceSerialized {
        senderId: id.clone(),
        ownsTrack: true,
        dtmfSender: dtmf_ser,
        rtpParameters: params_ser(&params),
        track: TrackInterfaceSerialized::from(
            &track as &MediaStreamTrackInterface,
        ),
        
    }
}

fn dtmf_ser(
    dtmf: &DtmfSenderInterface,
    id: &str,
) -> DtmfSenderInterfaceSerialized {
    DtmfSenderInterfaceSerialized {
        dtmfSenderId: id.to_string(),
        interToneGap: dtmf_sender_interface_get_inter_tone_gap(dtmf),
        duration: dtmf_sender_interface_get_duration(dtmf),
        is_null: false,
    }
}

fn rec_to_ser(
    receiver: &_RtpReceiverInterface,
) -> RtpReceiverInterfaceSerialized {
    let par = rtp_receiver_interface_get_parameters(receiver);

    let track = rtp_receiver_interface_get_track(receiver);

    RtpReceiverInterfaceSerialized {
        receiverId: rtp_receiver_interface_get_id(receiver).to_string(),
        parameters: params_ser(&par),
        track: TrackInterfaceSerialized::from(
            &track as &MediaStreamTrackInterface,
        ),
    }
}

fn params_ser(parameters: &RtpParameters) -> RtpParametersSerialized {
    let rtcp = rtp_parameters_get_rtcp(&parameters);

    let rtcp = RtcpParametersSerialized {
        cname: rtcp_parameters_get_cname(&rtcp).to_string(),
        reduced_size: rtcp_parameters_get_reduced_size(&rtcp),
    };

    let codecs = rtp_parameters_get_codecs(&parameters);
    let mut res_codecs = vec![];
    for i in codecs.into_iter() {
        res_codecs.push(codec_ser(i));
    }

    let header_extension = rtp_parameters_get_header_extensions(&parameters);
    let mut res_header_extension = vec![];
    for i in header_extension.into_iter() {
        res_header_extension.push(ext_ser(i));
    }

    let encodings = rtp_parameters_get_encodings(&parameters);
    let mut res_encodings = vec![];

    for i in encodings.into_iter() {
        res_encodings.push(encoding_ser(i));
    }

    RtpParametersSerialized {
        transactionId: rtp_parameters_get_transaction_id(&parameters).to_string(),
        rtcp,
        codecs: res_codecs,
        header_extensions: res_header_extension,
        encodings: res_encodings,
    }
}

fn codec_ser(codec: &RtpCodecParameters) -> RtpCodecParametersSerialized {
    let pars_ = rtp_codec_parameters_get_parameters(codec);
    let mut parameters = vec![];
    for i in pars_.into_iter() {
        parameters.push(StringPair {
            first: i.first.clone(),
            second: i.second.clone(),
        });
    }
    RtpCodecParametersSerialized {
        name: rtp_codec_parameters_get_name(codec).to_string(),
        payloadType: rtp_codec_parameters_get_payload_type(codec),
        clockRate: rtp_codec_parameters_get_clock_rate(codec),
        numChannels: rtp_codec_parameters_get_num_channels(codec),
        parameters,
        kind: rtp_codec_parameters_get_kind(codec).to_string(),
    }
}

fn ext_ser(ext: &RtpExtension) -> RtpExtensionSerialized {
    RtpExtensionSerialized {
        uri: rtp_extension_get_uri(ext).to_string(),
        id: rtp_extension_get_id(ext),
        encrypted: rtp_extension_get_encrypt(ext),
    }
}

fn encoding_ser(
    ext: &RtpEncodingParameters,
) -> RtpEncodingParametersSerialized {
    RtpEncodingParametersSerialized {
        active: rtp_encoding_parameters_get_active(ext),
        maxBitrate: rtp_encoding_parameters_get_maxBitrate(ext),
        minBitrate: rtp_encoding_parameters_get_minBitrate(ext),
        maxFramerate: rtp_encoding_parameters_get_maxFramerate(ext),
        scaleResolutionDownBy:
            rtp_encoding_parameters_get_scale_resolution_down_by(ext),
        ssrc: rtp_encoding_parameters_get_ssrc(ext),
    }
}
