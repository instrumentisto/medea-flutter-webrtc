use cxx::let_cxx_string;
use cxx::CxxString;
use libwebrtc_sys as sys;
use sys::PeerConnectionInterface;
use sys::SessionDescriptionInterface;

use std::cell::RefCell;
use std::error::Error;
use std::rc::Rc;
use std::sync::atomic::Ordering;

use std::ffi::c_void;
use std::sync::atomic::AtomicU64;

use crate::PeerConnection_;
use crate::RustRTCOfferAnswerOptions;
use crate::Webrtc;

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct PeerConnectionId(u64);

impl PeerConnection_ {
    pub fn create_offer(
        &mut self,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) {
        let obs = sys::MyCreateSessionObserver::new(s, f);
        let options = sys::RTCOfferAnswerOptions::new(
            offer_to_receive_video,
            offer_to_receive_audio,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .create_offer(&options, obs)
    }

    pub fn create_answer(
        &mut self,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        s: usize,
        f: usize,
    ) {
        let obs = sys::MyCreateSessionObserver::new(s, f);
        let options = sys::RTCOfferAnswerOptions::new(
            offer_to_receive_video,
            offer_to_receive_audio,
            voice_activity_detection,
            ice_restart,
            use_rtp_mux,
        );
        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .create_answer(&options, obs)
    }

    pub fn set_local_description(
        &mut self,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) {
        let type_ = match type_.as_str() {
            "offer" => sys::SdpType::kOffer,
            "answer" => sys::SdpType::kAnswer,
            "pranswer" => sys::SdpType::kPrAnswer,
            "rollback" => sys::SdpType::kRollback,
            _ => sys::SdpType::kOffer, // warning
        };
        let obs = sys::MySessionObserver::new(s, f);
        let desc = sys::SessionDescriptionInterface::new(type_, &sdp);
        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .set_local_description(desc, obs)
    }

    pub fn set_remote_description(
        &mut self,
        type_: String,
        sdp: String,
        s: usize,
        f: usize,
    ) {
        let type_ = match type_.as_str() {
            "offer" => sys::SdpType::kOffer,
            "answer" => sys::SdpType::kAnswer,
            "pranswer" => sys::SdpType::kPrAnswer,
            "rollback" => sys::SdpType::kRollback,
            _ => sys::SdpType::kOffer, // warning
        };

        let obs = sys::MySessionObserver::new(s, f);
        let desc = sys::SessionDescriptionInterface::new(type_, &sdp);

        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .set_remote_description(desc, obs)
    }
}

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
            .insert(id, Rc::new(RefCell::new(temp)));
        Ok(id)
    }

    pub fn get_peer_connection_from_id(
        self: &Webrtc,
        id: u64,
    ) -> anyhow::Result<Box<PeerConnection_>> {
        let rf = self.0.peer_connections.get(&id);
        Ok(Box::new(PeerConnection_(
            rf.ok_or(anyhow::Error::msg("Peer Connection not found"))?
                .clone(),
        )))
    }
}
