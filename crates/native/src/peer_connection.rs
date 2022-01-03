use libwebrtc_sys as sys;

use std::borrow::BorrowMut;
use std::rc::Rc;
use std::sync::atomic::Ordering;

use std::sync::atomic::AtomicU64;

use crate::Webrtc;

static ID_COUNTER: AtomicU64 = AtomicU64::new(1);

fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct PeerConnectionId(u64);

pub struct PeerConnection_(Rc<PeerConnection>);

impl PeerConnection_ {
    fn create_answer(&mut self) {
        self.0.borrow_mut();
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
        if peer_c.ok() {
            let id = generate_id();
            let temp = PeerConnection {
                id: PeerConnectionId(id),
                peer_connection_interface: peer_c.value(),
            };
            self.0.peer_connections.insert(id, Rc::new(temp));
            id
        } else {
            0
        }
    }

    pub fn get_peer_connection_from_id(
        self: &Webrtc,
        id: u64,
    ) -> Box<PeerConnection_> {
        let rf = self.0.peer_connections.get(&id).unwrap().clone();
        Box::new(PeerConnection_(
            rf,
        ))
    }
}
