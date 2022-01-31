pub use cpp_api_bindings::*;

#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");

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
            event: &CxxString,
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
