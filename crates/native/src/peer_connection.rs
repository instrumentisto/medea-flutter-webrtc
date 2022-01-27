extern crate derive_more;
use cxx::{CxxString, UniquePtr};
use derive_more::{From, Into};
use libwebrtc_sys as sys;
use sys::{CreateSdpCallback, SetDescriptionCallback, PeerConnectionOnEvent};

use std::{sync::atomic::Ordering};

use std::sync::atomic::AtomicU64;

use crate::api::PeerConnectionOnEventInterface;
use crate::{
    api::{CreateSdpCallbackInterface, SetDescriptionCallbackInterface},
    Webrtc,
};

/// This counter provides global resource for generating `unique id`.
static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// Struct for impl callback trait for [`UniquePtr`]<'extern c++ type'>.
struct Wrapper<T>(T);

/// Returns an `unique id`.
fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

/// Struct for `id` of [`PeerConnection`].
#[allow(clippy::module_name_repetitions)]
#[derive(Hash, Clone, Copy, PartialEq, Eq, From, Into)]
pub struct PeerConnectionId(u64);

/// Is used to manage [`sys::PeerConnectionInterface`].
#[allow(dead_code)]
pub struct PeerConnection {
    id: PeerConnectionId,
    pub peer_connection_interface: sys::PeerConnectionInterface,
}

impl CreateSdpCallback for Wrapper<UniquePtr<CreateSdpCallbackInterface>> {
    /// Calls `OnSuccess` method of callback c++ class.
    fn success(&mut self, sdp: &CxxString, type_: &CxxString) {
        self.0.pin_mut().on_success_create(sdp, type_);
    }

    /// Calls `OnFail` method of callback c++ class.
    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_fail_create(error);
    }
}

impl SetDescriptionCallback
    for Wrapper<UniquePtr<SetDescriptionCallbackInterface>>
{
    /// Calls `OnSuccess` method of callback c++ class.
    fn success(&mut self) {
        self.0.pin_mut().on_success_set_description();
    }

    /// Calls `OnFail` method of callback c++ class.
    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_fail_set_description(error);
    }
}

impl PeerConnectionOnEvent for Wrapper<UniquePtr<PeerConnectionOnEventInterface>>
{
    fn on_signaling_change(&mut self, event: &CxxString) {
        self.0.pin_mut().on_signaling_change(event);
    }
}

#[allow(clippy::too_many_arguments)]
impl Webrtc {
    /// Creates a new `PeerConnection` and return id.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn create_default_peer_connection(
        self: &mut Webrtc,
        error: &mut String,
        event_callback: UniquePtr<PeerConnectionOnEventInterface>,
    ) -> u64 {
        let obs = sys::PeerConnectionObserver::new(Box::new(Box::new(Wrapper(event_callback))));
        let peer_c = self
            .0
            .peer_connection_factory
            .create_peer_connection_or_error(
                error,
                &sys::RTCConfiguration::default(),
                sys::PeerConnectionDependencies::new(obs),
            );
        if error.is_empty() {
            let id = generate_id();
            let temp = PeerConnection {
                id: id.into(),
                peer_connection_interface: peer_c,
            };
            self.0.peer_connections.insert(id.into(), temp);
            id
        } else {
            0
        }
    }

    // todo not for release PR only test memory leak peer connection.
    pub fn delete_pc(
        &mut self,
        peer_connection_id: impl Into<PeerConnectionId>,
    ) {
        let pc = self
            .0
            .peer_connections
            .remove(&peer_connection_id.into())
            .unwrap();
        drop(pc);
        println!("RUST drop pc");
    }

    /// Creates a new `Offer`.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn create_offer(
        &mut self,
        error: &mut String,
        peer_connection_id: impl Into<PeerConnectionId>,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        sdp_callback: UniquePtr<CreateSdpCallbackInterface>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            let wrap = Wrapper(sdp_callback);
            let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
                Box::new(wrap),
            ));

            let options = sys::RTCOfferAnswerOptions::new(
                None,
                None,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );

            peer_connection
                .peer_connection_interface
                .create_offer(&options, obs);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Creates a new `Answer`.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn create_answer(
        &mut self,
        error: &mut String,
        peer_connection_id: impl Into<PeerConnectionId>,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        sdp_callback: UniquePtr<CreateSdpCallbackInterface>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
                Box::new(Wrapper(sdp_callback)),
            ));

            let options = sys::RTCOfferAnswerOptions::new(
                None,
                None,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );

            peer_connection
                .peer_connection_interface
                .create_answer(&options, obs);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Set Local Description.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_local_description(
        &mut self,
        error: &mut String,
        peer_connection_id: impl Into<PeerConnectionId>,
        type_: String,
        sdp: String,
        set_description_callback: UniquePtr<SetDescriptionCallbackInterface>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    let obs = sys::SetLocalDescriptionObserver::new(Box::new(
                        Box::new(Wrapper(set_description_callback)),
                    ));

                    peer_connection
                        .peer_connection_interface
                        .set_local_description(desc, obs);
                }
                Err(e) => error.push_str(&e.to_string()),
            }
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Set Remote Description.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_remote_description(
        &mut self,
        error: &mut String,
        peer_connection_id: impl Into<PeerConnectionId>,
        type_: String,
        sdp: String,
        set_description_callback: UniquePtr<SetDescriptionCallbackInterface>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    let obs = sys::SetRemoteDescriptionObserver::new(Box::new(
                        Box::new(Wrapper(set_description_callback)),
                    ));

                    peer_connection
                        .peer_connection_interface
                        .set_remote_description(desc, obs);
                }
                Err(e) => error.push_str(&e.to_string()),
            }
        } else {
            error.push_str("Peer Connection not found");
        }
    }
}
