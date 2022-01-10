
use libwebrtc_sys as sys;


use std::{sync::atomic::Ordering};

use std::{sync::atomic::AtomicU64};

use crate::Webrtc;

static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct PeerConnectionId(u64);

pub struct PeerConnection {
    id: PeerConnectionId,
    pub peer_connection_interface: sys::PeerConnectionInterface,
}

impl Webrtc {
    pub fn create_default_peer_connection(
        self: &mut Webrtc,
        error: &mut String,
    ) -> u64 {
        let peer_c = self
            .0
            .peer_connection_factory
            .create_peer_connection_or_error(
                error,
                &sys::RTCConfiguration::default(),
                sys::PeerConnectionDependencies::default(),
            );
        if error.is_empty() {
            let id = generate_id();
            let temp = PeerConnection {
                id: PeerConnectionId(id),
                peer_connection_interface: peer_c,
            };
            self.0.peer_connections.insert(id, temp);
            id
        } else {
            0
        }
    }

    pub fn create_offer(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let obs = sys::CreateSessionDescriptionObserver::new(s, f);
            let options = sys::RTCOfferAnswerOptions::new(
                offer_to_receive_video,
                offer_to_receive_audio,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );
            peer_connection
                .peer_connection_interface
                .create_offer(&options, obs);
        } else {
            std::mem::swap(error, &mut "Peer Connection not found".to_owned());
        }
    }

    pub fn create_answer(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let obs = sys::CreateSessionDescriptionObserver::new(s, f);
            let options = sys::RTCOfferAnswerOptions::new(
                offer_to_receive_video,
                offer_to_receive_audio,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );
            peer_connection
                .peer_connection_interface
                .create_answer(&options, obs);
        } else {
            std::mem::swap(error, &mut "Peer Connection not found".to_owned());
        }
    }

    pub fn set_local_description(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let type_: sys::SdpType = match type_.as_str() {
                "offer" => sys::SdpType::kOffer,
                "answer" => sys::SdpType::kAnswer,
                "pranswer" => sys::SdpType::kPrAnswer,
                _ => {
                    return std::mem::swap(
                        error,
                        &mut "Invalid type".to_owned(),
                    )
                }
            };
            let obs = sys::SetSessionDescriptionObserver::new(s, f);
            let desc = sys::SessionDescriptionInterface::new(type_, &sdp);

            peer_connection
                .peer_connection_interface
                .set_local_description(desc, obs);
        } else {
            std::mem::swap(error, &mut "Peer Connection not found".to_owned());
        }
    }

    pub fn set_remote_description(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let type_: sys::SdpType = match type_.as_str() {
                "offer" => sys::SdpType::kOffer,
                "answer" => sys::SdpType::kAnswer,
                "pranswer" => sys::SdpType::kPrAnswer,
                _ => {
                    return std::mem::swap(
                        error,
                        &mut "Invalid type".to_owned(),
                    )
                }
            };
            let obs = sys::SetSessionDescriptionObserver::new(s, f);
            let desc = sys::SessionDescriptionInterface::new(type_, &sdp);

            peer_connection
                .peer_connection_interface
                .set_remote_description(desc, obs);
        } else {
            std::mem::swap(error, &mut "Peer Connection not found".to_owned());
        }
    }
}
