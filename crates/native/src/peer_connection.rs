extern crate derive_more;
use cxx::CxxString;
use derive_more::{From, Into};
use libwebrtc_sys as sys;
use sys::{CreateSdpCallback, SetDescriptionCallback};

use std::{ffi::c_void, sync::atomic::Ordering};

use std::sync::atomic::AtomicU64;

use crate::Webrtc;

/// This counter provides global resource for generating `unique id`.
static ID_COUNTER: AtomicU64 = AtomicU64::new(0);

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

/// Struct for forwarding flutter context and functions in webrtc.
/// Used in [`CreateSessionDescriptionObserver`].
pub struct CreateOfferAnswerCallback {
    fn_success: extern "C" fn(&CxxString, &CxxString, *mut c_void),
    fn_fail: extern "C" fn(&CxxString, *mut c_void),
    context: *mut c_void,
}

/// Creates `Box` [`CreateOfferAnswerCallback`].
#[must_use]
pub fn create_sdp_callback(
    success: usize,
    fail: usize,
    context: usize,
) -> Box<CreateOfferAnswerCallback> {
    Box::new(CreateOfferAnswerCallback::new(success, fail, context))
}

impl CreateOfferAnswerCallback {
    /// Creates [`CreateOfferAnswerCallback`].
    /// Where
    /// success - `extern "C" fn(&CxxString, &CxxString, *mut c_void)`,
    /// fail - `extern "C" fn(&CxxString, *mut c_void)`,
    /// context - `c++ flutter::MethodResult<flutter::EncodableValue>*`.
    #[must_use]
    pub fn new(success: usize, fail: usize, context: usize) -> Self {
        Self {
            fn_success: unsafe { std::mem::transmute(success) },
            fn_fail: unsafe { std::mem::transmute(fail) },
            context: context as *mut c_void,
        }
    }
}

impl CreateSdpCallback for CreateOfferAnswerCallback {
    /// Calls flutter function `OnSuccessCreate`.
    fn success(&self, sdp: &CxxString, type_: &CxxString) {
        let fn_s = self.fn_success;
        fn_s(sdp, type_, self.context);
    }

    /// Calls flutter function `OnFail`.
    fn fail(&self, error: &CxxString) {
        let fn_f = self.fn_fail;
        fn_f(error, self.context);
    }
}

/// Struct for forwarding flutter context and functions in webrtc.
/// Used in [`SetLocalDescriptionObserverInterface`] and
/// [`SetRemoteDescriptionObserverInterface`].
pub struct SetLocalRemoteDescriptionCallBack {
    fn_success: extern "C" fn(*mut c_void),
    fn_fail: extern "C" fn(&CxxString, *mut c_void),
    context: *mut c_void,
}

/// Creates `Box` [`SetLocalRemoteDescriptionCallBack`].
#[must_use]
pub fn create_set_description_callback(
    success: usize,
    fail: usize,
    context: usize,
) -> Box<SetLocalRemoteDescriptionCallBack> {
    Box::new(SetLocalRemoteDescriptionCallBack::new(
        success, fail, context,
    ))
}

impl SetLocalRemoteDescriptionCallBack {
    /// Creates [`SetLocalRemoteDescriptionCallBack`].
    /// Where
    /// success - `extern "C" fn(*mut c_void)`,
    /// fail - `extern "C" fn(&CxxString, *mut c_void)`,
    /// context - `c++ flutter::MethodResult<flutter::EncodableValue>*`.
    #[must_use]
    pub fn new(success: usize, fail: usize, context: usize) -> Self {
        Self {
            fn_success: unsafe { std::mem::transmute(success) },
            fn_fail: unsafe { std::mem::transmute(fail) },
            context: context as *mut c_void,
        }
    }
}

impl SetDescriptionCallback for SetLocalRemoteDescriptionCallBack {
    /// Calls flutter function `OnSuccessDescription`.
    fn success(&self) {
        let fn_s = self.fn_success;
        fn_s(self.context);
    }
    /// Calls flutter function `OnFail`.
    fn fail(&self, error: &CxxString) {
        let fn_f = self.fn_fail;
        fn_f(error, self.context);
    }
}

#[allow(clippy::too_many_arguments)]
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
                id: id.into(),
                peer_connection_interface: peer_c,
            };
            self.0.peer_connections.insert(id.into(), temp);
            id
        } else {
            0
        }
    }

    /// Creates a new [Offer].
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
        sdp_callback: Box<CreateOfferAnswerCallback>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
                sdp_callback,
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

    /// Creates a new [Answer].
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
        sdp_callback: Box<CreateOfferAnswerCallback>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            let obs = sys::CreateSessionDescriptionObserver::new(Box::new(
                sdp_callback,
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
        set_description_callback: Box<SetLocalRemoteDescriptionCallBack>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    let obs = sys::SetLocalDescriptionObserverInterface::new(
                        Box::new(set_description_callback),
                    );

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
        set_description_callback: Box<SetLocalRemoteDescriptionCallBack>,
    ) {
        if let Some(peer_connection) =
            self.0.peer_connections.get_mut(&peer_connection_id.into())
        {
            match sys::SdpType::try_from(type_.as_str()) {
                Ok(type_) => {
                    let desc =
                        sys::SessionDescriptionInterface::new(type_, &sdp);

                    let obs = sys::SetRemoteDescriptionObserverInterface::new(
                        Box::new(set_description_callback),
                    );

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
