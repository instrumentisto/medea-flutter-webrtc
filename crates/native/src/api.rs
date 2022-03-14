// use std::{
//     cell::RefCell,
//     rc::Rc,
//     sync::{Arc, Mutex},
// };

// // use crate::{api, init, next_id, PeerConnection, Webrtc};
// use libwebrtc_sys as sys;
// use sys::PeerConnectionEventsHandler;

// use flutter_rust_bridge::StreamSink;

// static mut WEBRTC: Option<Rc<RefCell<Box<Webrtc>>>> = None;

// pub fn webrtc_init() {
// unsafe { WEBRTC = Some(Rc::new(RefCell::new(init()))) };
// }

// // todo one enum for all callbacks
// #[derive(Default)]
// pub struct callbacks {
//     on_signaling_change: Option<StreamSink<String>>,
//     on_standardized_ice_connection_change: Option<StreamSink<String>>,
//     on_connection_change: Option<StreamSink<String>>,
//     on_ice_gathering_change: Option<StreamSink<String>>,
//     on_negotiation_needed_event: Option<StreamSink<u32>>,
//     // ? on_ice_candidate_error: Option<StreamSink<String>>,
//     on_ice_connection_receiving_change: Option<StreamSink<bool>>,
//     // ? on_ice_candidate: Option<StreamSink<String>>,
//     // ? on_ice_candidates_removed: Option<StreamSink<String>>,
//     // ? on_ice_selected_candidate_pair_changed: Option<StreamSink<String>>,
//     // ? on_track: Option<StreamSink<String>>,
//     // ? on_remove_track: Option<StreamSink<String>>,
// }

// impl PeerConnectionEventsHandler for callbacks {
//     fn on_signaling_change(&mut self, new_state: sys::SignalingState) {
//         if let Some(cb) = &mut self.on_signaling_change {
//             cb.add(new_state.to_string());
//         }
//     }

//     fn on_standardized_ice_connection_change(
//         &mut self,
//         new_state: sys::IceConnectionState,
//     ) {
//         if let Some(cb) = &mut self.on_standardized_ice_connection_change {
//             cb.add(new_state.to_string());
//         }
//     }

//     fn on_connection_change(&mut self, new_state: sys::PeerConnectionState) {
//         if let Some(cb) = &mut self.on_connection_change {
//             cb.add(new_state.to_string());
//         }
//     }

//     fn on_ice_gathering_change(&mut self, new_state: sys::IceGatheringState) {
//         if let Some(cb) = &mut self.on_ice_gathering_change {
//             cb.add(new_state.to_string());
//         }
//     }

//     fn on_negotiation_needed_event(&mut self, event_id: u32) {
//         if let Some(cb) = &mut self.on_negotiation_needed_event {
//             cb.add(event_id);
//         }
//     }

//     fn on_ice_candidate_error(
//         &mut self,
//         address: &cxx::CxxString,
//         port: i32,
//         url: &cxx::CxxString,
//         error_code: i32,
//         error_text: &cxx::CxxString,
//     ) {
//         todo!()
//     }

//     fn on_ice_connection_receiving_change(&mut self, receiving: bool) {
//         if let Some(cb) = &mut self.on_ice_connection_receiving_change {
//             cb.add(receiving);
//         }
//     }

//     fn on_ice_candidate(&mut self, candidate: sys::IceCandidateInterface) {
//         todo!()
//     }

//     fn on_ice_candidates_removed(
//         &mut self,
//         candidates: &cxx::CxxVector<sys::Candidate>,
//     ) {
//         todo!()
//     }

//     fn on_ice_selected_candidate_pair_changed(
//         &mut self,
//         event: &sys::CandidatePairChangeEvent,
//     ) {
//         todo!()
//     }

//     fn on_track(&mut self, transceiver: sys::RtpTransceiverInterface) {
//         todo!()
//     }

//     fn on_remove_track(&mut self, receiver: sys::RtpReceiverInterface) {
//         todo!()
//     }
// }

// pub fn create_pc(configuration: api::RtcConfiguration) -> anyhow::Result<u64> {
//     unsafe {
//         let observer = callbacks::default();

//         let mut sys_configuration = sys::RtcConfiguration::default();

//         if !configuration.ice_transport_policy.is_empty() {
//             sys_configuration.set_ice_transport_type(
//                 configuration.ice_transport_policy.as_str().try_into()?,
//             );
//         }

//         if !configuration.bundle_policy.is_empty() {
//             sys_configuration.set_bundle_policy(
//                 configuration.bundle_policy.as_str().try_into()?,
//             );
//         }

//         for server in configuration.ice_servers {
//             let mut ice_server = sys::IceServer::default();
//             let mut have_ice_servers = false;

//             for url in server.urls {
//                 if !url.is_empty() {
//                     ice_server.add_url(url);
//                     have_ice_servers = true;
//                 }
//             }

//             if have_ice_servers {
//                 if !server.username.is_empty() || !server.credential.is_empty()
//                 {
//                     ice_server
//                         .set_credentials(server.username, server.credential);
//                 }

//                 sys_configuration.add_server(ice_server);
//             }
//         }

//         let inner = WEBRTC
//             .clone()
//             .unwrap()
//             .borrow_mut()
//             .0
//             .peer_connection_factory
//             .create_peer_connection_or_error(
//                 &sys_configuration,
//                 sys::PeerConnectionDependencies::new(
//                     sys::PeerConnectionObserver::new(Box::new(observer)),
//                 ),
//             )?;

//         let id = next_id();
//         let peer = PeerConnection(Arc::new(Mutex::new(inner)));
//         WEBRTC
//             .clone()
//             .unwrap()
//             .borrow_mut()
//             .0
//             .peer_connections
//             .insert(id.into(), peer);

//         Ok(id)
//     }
// }
