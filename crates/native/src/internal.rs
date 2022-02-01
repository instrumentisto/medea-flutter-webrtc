pub use cpp_api_bindings::*;
use cxx::{CxxVector, ExternType, type_id};
use crate::Candidate;




#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {


    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        pub type CreateSdpCallbackInterface;
        pub type SetDescriptionCallbackInterface;

        /// Calls CXX side `CreateSdpCallbackInterface->OnSuccess`.
        #[cxx_name = "OnSuccess"]
        pub fn on_create_sdp_success(
            self: Pin<&mut CreateSdpCallbackInterface>,
            sdp: &CxxString,
            kind: &CxxString,
        );

        /// Calls CXX side `CreateSdpCallbackInterface->OnFail`.
        #[cxx_name = "OnFail"]
        pub fn on_create_sdp_fail(
            self: Pin<&mut CreateSdpCallbackInterface>,
            error: &CxxString,
        );

        /// Calls CXX side `SetDescriptionCallbackInterface->OnSuccess`.
        #[cxx_name = "OnSuccess"]
        pub fn on_set_description_sucess(
            self: Pin<&mut SetDescriptionCallbackInterface>,
        );

        /// Calls CXX side `SetDescriptionCallbackInterface->OnFail`.
        #[cxx_name = "OnFail"]
        pub fn on_set_description_fail(
            self: Pin<&mut SetDescriptionCallbackInterface>,
            error: &CxxString,
        );

        type PeerConnectionOnEventInterface;
        /// Calls `OnFail` c++ `SetDescriptionCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnSignalingChange"]
        pub fn on_signaling_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        #[cxx_name = "OnStandardizedIceConnectionChange"]
        pub fn on_standardized_ice_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        #[cxx_name = "OnConnectionChange"]
        pub fn on_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        #[cxx_name = "OnIceGatheringChange"]
        pub fn on_ice_gathering_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        #[cxx_name = "OnNegotiationNeededEvent"]
        pub fn on_negotiation_needed_event(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            event_id: u32,
        );

        #[cxx_name = "OnIceCandidateError"]
        pub fn on_ice_candidate_error(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            host_candidate: &CxxString,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );

        #[cxx_name = "OnIceCandidateError"]
        pub fn on_ice_candidate_address_port_error(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            address: &CxxString,
            port: i32,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );

        #[cxx_name = "OnIceConnectionReceivingChange"]
        pub fn on_ice_connection_receiving_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            receiving: bool,
        );

        #[cxx_name = "OnInterestingUsage"]
        pub fn on_interesting_usage(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            usage_pattern: i32,
        );

        #[cxx_name = "OnIceCandidate"]
        pub fn on_ice_candidate(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            candidate: &CxxString
        );
        
        type CandidateWrapp = crate::CandidateWrapp;
        #[cxx_name = "OnIceCandidatesRemoved"]
        pub unsafe fn on_ice_candidates_removed(            
            self: Pin<&mut PeerConnectionOnEventInterface>,
            candidates: *mut CandidateWrapp
        );

        #[cxx_name = "OnIceCandidatesRemoved_v2"]
        pub unsafe fn on_ice_candidates_removed_v2(            
            self: Pin<&mut PeerConnectionOnEventInterface>,
            candidates: Vec<String>
        );
    }

    // This will trigger cxx to generate UniquePtrTarget trait for the
    // mentioned types.
    extern "Rust" {

        fn _touch_create_sdp_callback(i: UniquePtr<CreateSdpCallbackInterface>);
        fn _touch_set_description_callback(
            i: UniquePtr<SetDescriptionCallbackInterface>,
        );

        /// This will trigger cxx to generate UniquePtrTarget
        /// for SetDescriptionCallbackInterface.
        fn _touch_unique_ptr_peer_connection_on_event_interface(
            i: UniquePtr<PeerConnectionOnEventInterface>,
        );
    }
}

fn _touch_create_sdp_callback(_: cxx::UniquePtr<CreateSdpCallbackInterface>) {}

fn _touch_set_description_callback(
    _: cxx::UniquePtr<SetDescriptionCallbackInterface>,
) {
}
fn _touch_unique_ptr_peer_connection_on_event_interface(
    _: cxx::UniquePtr<PeerConnectionOnEventInterface>,
) {
}

unsafe impl ExternType for crate::CandidateWrapp {
    type Id = type_id!("CandidateWrapp");
    type Kind = cxx::kind::Opaque;
}