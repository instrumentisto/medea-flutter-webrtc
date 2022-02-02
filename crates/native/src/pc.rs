use cxx::{CxxString, UniquePtr};
use derive_more::{Display, From, Into};
use libwebrtc_sys as sys;

use crate::{
    api::{
        CreateSdpCallbackInterface, MediaType, RtpTransceiverDirection,
        SetDescriptionCallbackInterface,
    },
    next_id, Webrtc,
};

impl Webrtc {
    /// Creates a new [`PeerConnection`] and returns it's ID.
    ///
    /// Writes an error to the provided `err` if any.
    pub fn create_peer_connection(
        self: &mut Webrtc,
        error: &mut String,
    ) -> u64 {
        let peer = PeerConnection::new(&mut self.0.peer_connection_factory);
        match peer {
            Ok(peer) => self
                .0
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

    /// Initiates the creation of an SDP offer for the purpose of starting
    /// a new WebRTC connection to a remote peer.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error
    /// otherwise.
    pub fn create_offer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "PeerConnection with ID `{}` does not exist",
                peer_id
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

    /// Creates an SDP answer to an offer received from a remote peer during
    /// the offer/answer negotiation of a WebRTC connection.
    ///
    /// Returns an empty [`String`] in operation succeeds or an error
    /// otherwise.
    pub fn create_answer(
        &mut self,
        peer_id: u64,
        voice_activity_detection: bool,
        ice_restart: bool,
        use_rtp_mux: bool,
        cb: UniquePtr<CreateSdpCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "PeerConnection with ID `{}` does not exist",
                peer_id
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
    /// Returns an empty [`String`] in operation succeeds or an error
    /// otherwise.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_local_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "PeerConnection with ID `{}` does not exist",
                peer_id
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
    /// Returns an empty [`String`] in operation succeeds or an error
    /// otherwise.
    #[allow(clippy::needless_pass_by_value)]
    pub fn set_remote_description(
        &mut self,
        peer_id: u64,
        kind: String,
        sdp: String,
        cb: UniquePtr<SetDescriptionCallbackInterface>,
    ) -> String {
        let peer = if let Some(peer) = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId::from(peer_id))
        {
            peer
        } else {
            return format!(
                "PeerConnection with ID `{}` does not exist",
                peer_id
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

    pub fn add_transceiver(
        &mut self,
        peer_id: u64,
        media_type: MediaType,
        direction: RtpTransceiverDirection,
    ) {
        let media_type: sys::MediaType = match media_type {
            MediaType::MEDIA_TYPE_AUDIO => sys::MediaType::MEDIA_TYPE_AUDIO,
            MediaType::MEDIA_TYPE_VIDEO => sys::MediaType::MEDIA_TYPE_VIDEO,
            MediaType::MEDIA_TYPE_DATA => sys::MediaType::MEDIA_TYPE_DATA,
            _ => sys::MediaType::MEDIA_TYPE_UNSUPPORTED,
        };

        let direction: sys::RtpTransceiverDirection = match direction {
            RtpTransceiverDirection::kRecvOnly => {
                sys::RtpTransceiverDirection::kRecvOnly
            }
            RtpTransceiverDirection::kSendOnly => {
                sys::RtpTransceiverDirection::kSendOnly
            }
            RtpTransceiverDirection::kSendRecv => {
                sys::RtpTransceiverDirection::kSendRecv
            }
            RtpTransceiverDirection::kStopped => {
                sys::RtpTransceiverDirection::kStopped
            }
            _ => sys::RtpTransceiverDirection::kInactive,
        };

        self.0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap()
            .inner
            .add_transceiver(media_type, direction);
    }

    pub fn get_transceivers(&mut self, peer_id: u64) {
        let transceivers = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap()
            .inner
            .get_transceivers();

        for transceiver in transceivers.iter() {
            let mid = transceiver.mid();
            println!("{}", mid);
            let direction = transceiver.direction();
            println!("{:?}", direction);
        }
    }

    pub fn pupa(&mut self, peer_id: u64) {
        let a = self
            .0
            .peer_connections
            .get_mut(&PeerConnectionId(peer_id))
            .unwrap();

        libwebrtc_sys::testsk(&mut a.inner);
    }
}

// pub struct Transceiver {
//     direction: String,
//     mid: String,
// }

/// ID of a [`PeerConnection`].
#[derive(Clone, Copy, Debug, Display, Eq, From, Hash, Into, PartialEq)]
pub struct PeerConnectionId(u64);

/// Is used to manage [`sys::PeerConnectionInterface`].
pub struct PeerConnection {
    /// ID of this [`PeerConnection`].
    id: PeerConnectionId,

    /// Underlying [`sys::PeerConnectionInterface`].
    pub inner: sys::PeerConnectionInterface,
}

impl PeerConnection {
    /// Creates a new [`PeerConnection`].
    fn new(
        factory: &mut sys::PeerConnectionFactoryInterface,
    ) -> anyhow::Result<Self> {
        let inner = factory.create_peer_connection_or_error(
            &sys::RTCConfiguration::default(),
            sys::PeerConnectionDependencies::default(),
        )?;

        Ok(Self {
            id: PeerConnectionId::from(next_id()),
            inner,
        })
    }
}

/// Wrapper for [`CreateSdpCallbackInterface`].
struct CreateSdpCallback(UniquePtr<CreateSdpCallbackInterface>);

impl sys::CreateSdpCallback for CreateSdpCallback {
    fn success(&mut self, sdp: &CxxString, kind: &CxxString) {
        self.0.pin_mut().on_success_create(sdp, kind);
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_fail_create(error);
    }
}

/// Wrapper for [`SetDescriptionCallbackInterface`].
struct SetSdpCallback(UniquePtr<SetDescriptionCallbackInterface>);

impl sys::SetDescriptionCallback for SetSdpCallback {
    fn success(&mut self) {
        self.0.pin_mut().on_success_set_description();
    }

    fn fail(&mut self, error: &CxxString) {
        self.0.pin_mut().on_fail_set_description(error);
    }
}

// #[cfg(test)]
// mod asd {
//     use libwebrtc_sys::{
//         AudioLayer, CreateSdpCallback, CreateSessionDescriptionObserver,
//         PeerConnectionFactoryInterface, TaskQueueFactory, Thread,
//     };

//     use crate::{AudioDeviceModule, PeerConnection};

//     #[test]
//     fn name() {
//         let mut task_queue_factory =
//             TaskQueueFactory::create_default_task_queue_factory();

//         let mut network_thread = Thread::create().unwrap();
//         network_thread.start().unwrap();

//         let mut worker_thread = Thread::create().unwrap();
//         worker_thread.start().unwrap();

//         let mut signaling_thread = Thread::create().unwrap();
//         signaling_thread.start().unwrap();

//         let audio_device_module = AudioDeviceModule::new(
//             AudioLayer::kPlatformDefaultAudio,
//             &mut task_queue_factory,
//         )
//         .unwrap();

//         let mut peer_connection_factory =
//             PeerConnectionFactoryInterface::create(
//                 Some(&network_thread),
//                 Some(&worker_thread),
//                 Some(&signaling_thread),
//                 Some(&audio_device_module.inner),
//             );

//         let mut peer1 =
//             PeerConnection::new(&mut peer_connection_factory).unwrap();

//         let mut peer2 =
//             PeerConnection::new(&mut peer_connection_factory).unwrap();

//         let opts = libwebrtc_sys::RTCOfferAnswerOptions::new(
//             None, None, true, false, true,
//         );

//         static mut SDP1: String = String::new();
//         static mut SDP2: String = String::new();

//         struct SessDesc1(String);

//         impl CreateSdpCallback for SessDesc1 {
//             fn success(&mut self, sdp: &cxx::CxxString, kind: &cxx::CxxString) {
//                 unsafe {
//                     SDP1 = sdp.to_string();
//                 }
//                 println!("success create sdp");
//             }

//             fn fail(&mut self, error: &cxx::CxxString) {
//                 println!("fail {}", error);
//             }
//         }

//         let offer_cb = Box::new(SessDesc1(String::new()));

//         let offer_obs = CreateSessionDescriptionObserver::new(offer_cb);

//         peer1.inner.add_transceiver(
//             libwebrtc_sys::MediaType::MEDIA_TYPE_VIDEO,
//             libwebrtc_sys::RtpTransceiverDirection::kSendRecv,
//         );

//         peer1.inner.add_transceiver(
//             libwebrtc_sys::MediaType::MEDIA_TYPE_AUDIO,
//             libwebrtc_sys::RtpTransceiverDirection::kSendRecv,
//         );

//         peer1.inner.create_offer(&opts, offer_obs);

//         std::thread::sleep(std::time::Duration::from_secs(1));

//         struct OfferDesc(u64);

//         impl libwebrtc_sys::SetDescriptionCallback for OfferDesc {
//             fn success(&mut self) {
//                 println!("success set local");
//             }

//             fn fail(&mut self, error: &cxx::CxxString) {
//                 println!("fail set local {}", error);
//             }
//         }

//         let loc_desc_cb = Box::new(OfferDesc(1));

//         let loc_desc_obs =
//             libwebrtc_sys::SetLocalDescriptionObserver::new(loc_desc_cb);

//         let loc_desc = unsafe {
//             libwebrtc_sys::SessionDescriptionInterface::new(
//                 libwebrtc_sys::SdpType::kOffer,
//                 SDP1.as_str(),
//             )
//         };

//         peer1.inner.set_local_description(loc_desc, loc_desc_obs);

//         let rem_desc_cb = Box::new(OfferDesc(1));

//         let rem_desc_obs =
//             libwebrtc_sys::SetRemoteDescriptionObserver::new(rem_desc_cb);

//         let rem_desc = unsafe {
//             libwebrtc_sys::SessionDescriptionInterface::new(
//                 libwebrtc_sys::SdpType::kOffer,
//                 SDP1.as_str(),
//             )
//         };

//         peer2.inner.set_remote_description(rem_desc, rem_desc_obs);

//         struct SessDesc2(String);

//         impl CreateSdpCallback for SessDesc2 {
//             fn success(&mut self, sdp: &cxx::CxxString, kind: &cxx::CxxString) {
//                 unsafe {
//                     SDP2 = sdp.to_string();
//                 }
//                 println!("success create sdp");
//             }

//             fn fail(&mut self, error: &cxx::CxxString) {
//                 println!("fail {}", error);
//             }
//         }

//         let answer_cb = Box::new(SessDesc2(String::new()));

//         let answer_obs = CreateSessionDescriptionObserver::new(answer_cb);

//         peer2.inner.create_answer(&opts, answer_obs);

//         std::thread::sleep(std::time::Duration::from_secs(1));

//         unsafe {
//             println!("{}", SDP2);
//         }

//         let loc_desc_cb1 = Box::new(OfferDesc(1));

//         let loc_desc_obs1 =
//             libwebrtc_sys::SetLocalDescriptionObserver::new(loc_desc_cb1);

//         let loc_desc1 = unsafe {
//             libwebrtc_sys::SessionDescriptionInterface::new(
//                 libwebrtc_sys::SdpType::kAnswer,
//                 SDP2.as_str(),
//             )
//         };

//         peer2.inner.set_local_description(loc_desc1, loc_desc_obs1);

//         let rem_desc_cb2 = Box::new(OfferDesc(1));

//         let rem_desc_obs2 =
//             libwebrtc_sys::SetRemoteDescriptionObserver::new(rem_desc_cb2);

//         let rem_desc2 = unsafe {
//             libwebrtc_sys::SessionDescriptionInterface::new(
//                 libwebrtc_sys::SdpType::kAnswer,
//                 SDP2.as_str(),
//             )
//         };

//         peer1.inner.set_remote_description(rem_desc2, rem_desc_obs2);

//         std::thread::sleep(std::time::Duration::from_secs(1));

//         // let _trans = peer1.inner.get_transceivers();

//         println!("all");

//         // std::thread::sleep(std::time::Duration::from_secs(3));

//         // a.get_transceivers(id1);

//         // Box::leak(a);

//         assert!(true);
//     }
// }
