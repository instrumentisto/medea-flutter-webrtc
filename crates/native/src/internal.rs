pub use cpp_api_bindings::*;

#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {

    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");
        include!("flutter-webrtc-native/src/lib.rs.h");

        type CreateSdpCallbackInterface;
        type SetDescriptionCallbackInterface;
        type CandidatePairChangeEventSerialized =
            crate::api::CandidatePairChangeEventSerialized;
        type PeerConnectionOnEventInterface;

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

        /// Calls `OnSignalingChange` c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnSignalingChange"]
        pub fn on_signaling_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        /// Calls `OnStandardizedIceConnectionChange`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnStandardizedIceConnectionChange"]
        pub fn on_standardized_ice_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        /// Calls `OnConnectionChange`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnConnectionChange"]
        pub fn on_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        /// Calls `OnIceGatheringChange`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceGatheringChange"]
        pub fn on_ice_gathering_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &CxxString,
        );

        /// Calls `OnNegotiationNeededEvent`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnNegotiationNeededEvent"]
        pub fn on_negotiation_needed_event(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            event_id: u32,
        );

        /// Calls `OnIceCandidateError`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceCandidateError"]
        pub fn on_ice_candidate_error(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            host_candidate: &CxxString,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );

        /// Calls `OnIceCandidateError`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceCandidateError"]
        pub fn on_ice_candidate_address_port_error(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            address: &CxxString,
            port: i32,
            url: &CxxString,
            error_code: i32,
            error_text: &CxxString,
        );

        /// Calls `OnIceConnectionReceivingChange`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceConnectionReceivingChange"]
        pub fn on_ice_connection_receiving_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            receiving: bool,
        );

        /// Calls `OnInterestingUsage`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnInterestingUsage"]
        pub fn on_interesting_usage(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            usage_pattern: i32,
        );

        /// Calls `OnIceCandidate`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceCandidate"]
        pub fn on_ice_candidate(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            candidate: &CxxString,
        );

        /// Calls `OnIceCandidatesRemoved`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceCandidatesRemoved"]
        pub unsafe fn on_ice_candidates_removed(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            candidates: Vec<String>,
        );

        /// Calls `OnIceSelectedCandidatePairChanged`
        /// c++ `PeerConnectionOnEventInterface`
        /// abstract class method.
        #[cxx_name = "OnIceSelectedCandidatePairChanged"]
        pub unsafe fn on_ice_selected_candidate_pair_changed(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            event: CandidatePairChangeEventSerialized,
        );

    }

    // This will trigger cxx to generate UniquePtrTarget trait for the
    // mentioned types.
    extern "Rust" {
        fn _touch_create_sdp_callback(i: UniquePtr<CreateSdpCallbackInterface>);
        fn _touch_set_description_callback(
            i: UniquePtr<SetDescriptionCallbackInterface>,
        );
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
