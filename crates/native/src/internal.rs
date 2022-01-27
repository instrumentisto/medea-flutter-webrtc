pub use internal::*;

#[allow(clippy::items_after_statements, clippy::module_inception)]
#[cxx::bridge]
mod internal {
    unsafe extern "C++" {
        include!("flutter_webrtc_native/include/api.h");

        pub type CreateSdpCallbackInterface;
        /// Calls `OnSuccess` c++ `CreateSdpCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnSuccess"]
        pub fn on_success_create(
            self: Pin<&mut CreateSdpCallbackInterface>,
            sdp: &CxxString,
            type_: &CxxString,
        );
        /// Calls `OnFail` c++ `CreateSdpCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnFail"]
        pub fn on_fail_create(
            self: Pin<&mut CreateSdpCallbackInterface>,
            error: &CxxString,
        );

        pub type SetDescriptionCallbackInterface;
        /// Calls `OnSuccess` c++ `SetDescriptionCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnSuccess"]
        pub fn on_success_set_description(
            self: Pin<&mut SetDescriptionCallbackInterface>,
        );
        /// Calls `OnFail` c++ `SetDescriptionCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnFail"]
        pub fn on_fail_set_description(
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

    extern "Rust" {
        /// This will trigger cxx to generate UniquePtrTarget
        /// for CreateSdpCallbackInterface.
        fn _touch_unique_ptr_create_sdp_callback(
            i: UniquePtr<CreateSdpCallbackInterface>,
        );

        /// This will trigger cxx to generate UniquePtrTarget
        /// for SetDescriptionCallbackInterface.
        fn _touch_unique_ptr_set_description_callback(
            i: UniquePtr<SetDescriptionCallbackInterface>,
        );

        /// This will trigger cxx to generate UniquePtrTarget
        /// for SetDescriptionCallbackInterface.
        fn _touch_unique_ptr_peer_connection_on_event_interface(
            i: UniquePtr<PeerConnectionOnEventInterface>,
        );
    }
}

fn _touch_unique_ptr_create_sdp_callback(
    _: cxx::UniquePtr<CreateSdpCallbackInterface>,
) {
}
fn _touch_unique_ptr_set_description_callback(
    _: cxx::UniquePtr<SetDescriptionCallbackInterface>,
) {
}
fn _touch_unique_ptr_peer_connection_on_event_interface(
    _: cxx::UniquePtr<PeerConnectionOnEventInterface>,
) {
}
