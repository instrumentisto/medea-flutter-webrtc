pub use cpp_api_bindings::*;

use cxx::{type_id, ExternType};

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
        type SignalingStateWrapper = crate::SignalingStateWrapper;
        /// Calls `OnFail` c++ `SetDescriptionCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnSignalingChange"]
        pub fn on_signaling_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &SignalingStateWrapper,
        );

        type IceConnectionStateWrapper = crate::IceConnectionStateWrapper;
        #[cxx_name = "OnStandardizedIceConnectionChange"]
        pub fn on_standardized_ice_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &IceConnectionStateWrapper,
        );

        type PeerConnectionStateWrapper = crate::PeerConnectionStateWrapper;
        #[cxx_name = "OnConnectionChange"]
        pub fn on_connection_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &PeerConnectionStateWrapper,
        );

        type IceGatheringStateWrapper = crate::IceGatheringStateWrapper;
        #[cxx_name = "OnIceGatheringChange"]
        pub fn on_ice_gathering_change(
            self: Pin<&mut PeerConnectionOnEventInterface>,
            new_state: &IceGatheringStateWrapper,
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

unsafe impl ExternType for crate::SignalingStateWrapper {
    type Id = type_id!("SignalingStateWrapper");
    type Kind = cxx::kind::Trivial;
}
unsafe impl ExternType for crate::IceConnectionStateWrapper {
    type Id = type_id!("IceConnectionStateWrapper");
    type Kind = cxx::kind::Trivial;
}
unsafe impl ExternType for crate::PeerConnectionStateWrapper {
    type Id = type_id!("PeerConnectionStateWrapper");
    type Kind = cxx::kind::Trivial;
}
unsafe impl ExternType for crate::IceGatheringStateWrapper {
    type Id = type_id!("IceGatheringStateWrapper");
    type Kind = cxx::kind::Trivial;
}
