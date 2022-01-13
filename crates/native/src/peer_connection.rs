use cxx::UniquePtr;
use libwebrtc_sys as sys;

use std::sync::atomic::Ordering;

use std::sync::atomic::AtomicU64;

use crate::Webrtc;

/// This counter provides global resource for generating `unique id`.
static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

/// Returns an `unique id`.
fn generate_id() -> u64 {
    ID_COUNTER.fetch_add(1, Ordering::Relaxed)
}

/// Struct for `id` of [`PeerConnection`].
#[derive(Hash, Clone, Copy, PartialEq, Eq)]
pub struct PeerConnectionId(u64);

/// Is used to manage [`sys::PeerConnectionInterface`].
pub struct PeerConnection {
    id: PeerConnectionId,
    pub peer_connection_interface: sys::PeerConnectionInterface,
}

impl Webrtc {
    /// Creates a new [`PeerConnection`] and return id.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
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

    pub fn init_create_session_obs(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
        self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let success: fn(&cxx::CxxString, &cxx::CxxString) =
            unsafe { std::mem::transmute(s) };
            let fail: fn(&cxx::CxxString) = unsafe { std::mem::transmute(f) };
            let obs = sys::CreateSessionDescriptionObserver::new(success, fail);
    
            peer_connection.peer_connection_interface.create_session_observer = Some(obs);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    pub fn init_set_session_obs(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        s: usize,
        f: usize,
    ) {
        if let Some(peer_connection) =
        self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let success: fn() =
            unsafe { std::mem::transmute(s) };
            let fail: fn(&cxx::CxxString) = unsafe { std::mem::transmute(f) };
            let obs = sys::SetSessionDescriptionObserver::new(success, fail);
    
            peer_connection.peer_connection_interface.set_session_observer = Some(obs);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Creates a new [Offer].
    /// Where
    /// `s` - void (*callback_success)(std::string, std::string)
    /// for callback when 'CreateOffer' is OnSuccess,
    /// `f` - void (*callback_fail)(std::string)
    /// for callback when 'CreateOffer' is OnFailure.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn create_offer(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let options = sys::RTCOfferAnswerOptions::new(
                offer_to_receive_video,
                offer_to_receive_audio,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );
            peer_connection
                .peer_connection_interface
                .create_offer(&options);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Creates a new [Answer].
    ///  Where
    /// `s` - void (*callback_success)(std::string, std::string)
    /// for callback when 'CreateAnswer' is OnSuccess,
    /// `f` - void (*callback_fail)(std::string)
    /// for callback when 'CreateAnswer' is OnFailure.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn create_answer(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        offer_to_receive_video: i32,
        offer_to_receive_audio: i32,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            let options = sys::RTCOfferAnswerOptions::new(
                offer_to_receive_video,
                offer_to_receive_audio,
                voice_activity_detection,
                ice_restart,
                use_rtp_mux,
            );
            peer_connection
                .peer_connection_interface
                .create_answer(&options);
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Set Local Description.
    /// Where
    /// `s` - void (*callback_success_desc)()
    /// for callback when 'SetLocalDescription' is OnSuccess,
    /// `f` - void (*callback_fail)(std::string)
    /// for callback when 'SetLocalDescription' is OnFailure.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn set_local_description(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    peer_connection
                        .peer_connection_interface
                        .set_local_description(desc);
                }
                Err(e) => error.push_str(&e.to_string()),
            }
        } else {
            error.push_str("Peer Connection not found");
        }
    }

    /// Set Remote Description.
    /// Where
    /// `s` - void (*callback_success_desc)()
    /// for callback when 'SetRemoteDescription' is OnSuccess,
    /// `f` - void (*callback_fail)(std::string)
    /// for callback when 'SetRemoteDescription' is OnFailure.
    /// # Warning
    /// `error` for error handle without c++ exception.
    /// If `error` != "" after the call,
    /// then the result will be NULL or default.
    pub fn set_remote_description(
        &mut self,
        error: &mut String,
        peer_connection_id: u64,
        type_: String,
        sdp: String,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id)
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    peer_connection
                        .peer_connection_interface
                        .set_remote_description(desc);
                }
                Err(e) => error.push_str(&e.to_string()),
            }
        } else {
            error.push_str("Peer Connection not found");
        }
    }
}
