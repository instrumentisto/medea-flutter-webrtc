use cxx::CxxString;
use cxx::let_cxx_string;
use libwebrtc_sys as sys;
use sys::SessionDescriptionInterface;

use std::cell::RefCell;
use std::rc::Rc;
use std::sync::atomic::Ordering;

use std::sync::atomic::AtomicU64;
use std::ffi::c_void;

use crate::PeerConnection_;
use crate::Webrtc;
use crate::RustRTCOfferAnswerOptions;

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct PeerConnectionId(u64);

impl PeerConnection_ {

    pub fn create_offer(&mut self, s: usize, f: usize) {
        let obs = sys::MyCreateSessionObserver::new(s, f);
        //
        /*self.0.as_ref()
        .borrow_mut()
        .peer_connection_interface
        .create_offer(&sys::RTCOfferAnswerOptions::default(), obs)*/
    }

    /*pub fn create_answer(&mut self) {
        /*self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .create_answer(sys::RTCOfferAnswerOptions::default())*/
    }*/

    pub fn set_local_description(&mut self) {
        let type_ = sys::SdpType::kAnswer;
        let desc = sys::SessionDescriptionInterface::new(type_, "test");

        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .set_local_description(desc)
    }

    pub fn set_remote_description(&mut self) {
        let type_ = sys::SdpType::kAnswer;
        let desc = sys::SessionDescriptionInterface::new(type_, "test");

        self.0
            .as_ref()
            .borrow_mut()
            .peer_connection_interface
            .set_remote_description(desc)
    }
}

pub struct PeerConnection {
    id: PeerConnectionId,
    peer_connection_interface: sys::PeerConnectionInterface,
    
}

impl Webrtc {
    pub fn create_default_peer_connection(self: &mut Webrtc) -> u64 {
        let mut peer_c = self
            .0
            .peer_connection_factory
            .create_peer_connection_or_error(
                sys::RTCConfiguration::default(),
                sys::PeerConnectionDependencies::default(),
            );
        let id = generate_id();
        let temp = PeerConnection {
            id: PeerConnectionId(id),
            peer_connection_interface: peer_c,
        };
        self.0
            .peer_connections
            .insert(id, Rc::new(RefCell::new(temp)));
        id
    }

    pub fn get_peer_connection_from_id(
        self: &Webrtc,
        id: u64,
    ) -> Box<PeerConnection_> {
        let rf = self.0.peer_connections.get(&id).unwrap().clone();
        Box::new(PeerConnection_(rf))
    }
}
