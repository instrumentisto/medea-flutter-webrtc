use cxx::{let_cxx_string, CxxString};
use libwebrtc_sys as sys;
use sys::{PeerConnectionInterface, SessionDescriptionInterface};

use std::{cell::RefCell, error::Error, rc::Rc, sync::atomic::Ordering};

use std::{ffi::c_void, sync::atomic::AtomicU64};

use crate::{Webrtc};

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
    ) -> anyhow::Result<u64> {
        let peer_c = self
            .0
            .peer_connection_factory
            .create_peer_connection_or_error(
                sys::RTCConfiguration::default(),
                sys::PeerConnectionDependencies::default(),
            );

        let id = generate_id();
        let temp = PeerConnection {
            id: PeerConnectionId(id),
            peer_connection_interface: peer_c?,
        };
        self.0
            .peer_connections
            .insert(id, temp);
        Ok(id)
    }

    pub fn create_offer(
        &mut self,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) -> anyhow::Result<()> {

        let peer_connection = self.0
            .peer_connections
            .get_mut(&peer_connection_id)
            .ok_or(anyhow::Error::msg("Peer Connection not found"));

        let obs = sys::CreateSessionDescriptionObserver::new(s, f);
        let options = sys::RTCOfferAnswerOptions::new(
            offer_to_receive_video,
            offer_to_receive_audio,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        peer_connection?
            .peer_connection_interface
            .create_offer(&options, obs);
        Ok(())
    }

    pub fn create_answer(
        &mut self,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) -> anyhow::Result<()> {

        let peer_connection = self.0
            .peer_connections
            .get_mut(&peer_connection_id)
            .ok_or(anyhow::Error::msg("Peer Connection not found"));

        let obs = sys::CreateSessionDescriptionObserver::new(s, f);
        let options = sys::RTCOfferAnswerOptions::new(
            offer_to_receive_video,
            offer_to_receive_audio,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        peer_connection?
            .peer_connection_interface
            .create_answer(&options, obs);
        Ok(())
    }

    pub fn set_local_description(
        &mut self,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) -> anyhow::Result<()> {
        let peer_connection = self.0
            .peer_connections
            .get_mut(&peer_connection_id)
            .ok_or(anyhow::Error::msg("Peer Connection not found"));

        let fail_fn: fn(msg: &CxxString) = unsafe {std::mem::transmute(f)};
        let_cxx_string!(msg = "Invalid type");
        let type_: sys::SdpType = match type_.as_str() {
            "offer" => sys::SdpType::kOffer,
            "answer" => sys::SdpType::kAnswer,
            "pranswer" => sys::SdpType::kPrAnswer,
            _ => {fail_fn(&msg); return Ok(());},
        };
        let obs = sys::SetSessionDescriptionObserver::new(s, f);
        let desc = sys::SessionDescriptionInterface::new(type_, &sdp);

        peer_connection?
            .peer_connection_interface
            .set_local_description(desc, obs);
        Ok(())
    }

    pub fn set_remote_description(
        &mut self,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) -> anyhow::Result<()> {
        let peer_connection = self.0
            .peer_connections
            .get_mut(&peer_connection_id)
            .ok_or(anyhow::Error::msg("Peer Connection not found"));

        let fail_fn: fn(msg: &CxxString) = unsafe {std::mem::transmute(f)};
        let_cxx_string!(msg = "Invalid type");
        let type_: sys::SdpType = match type_.as_str() {
            "offer" => sys::SdpType::kOffer,
            "answer" => sys::SdpType::kAnswer,
            "pranswer" => sys::SdpType::kPrAnswer,
            _ => {fail_fn(&msg); return Ok(());},
        };
        let obs = sys::SetSessionDescriptionObserver::new(s, f);
        let desc = sys::SessionDescriptionInterface::new(type_, &sdp);

        peer_connection?
            .peer_connection_interface
            .set_remote_description(desc, obs);
        Ok(())
    }
}
