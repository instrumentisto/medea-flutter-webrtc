pub use cpp_api_bindings::*;

#[allow(clippy::items_after_statements)]
#[cxx::bridge]
mod cpp_api_bindings {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");

        pub type CreateSdpCallbackInterface;
        pub type SetDescriptionCallbackInterface;

        /// Calls `OnSuccess` c++ `CreateSdpCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnSuccess"]
        pub fn on_success_create(
            self: Pin<&mut CreateSdpCallbackInterface>,
            sdp: &CxxString,
            kind: &CxxString,
        );
        /// Calls `OnFail` c++ `CreateSdpCallbackInterface`
        ///  abstract class method.
        #[cxx_name = "OnFail"]
        pub fn on_fail_create(
            self: Pin<&mut CreateSdpCallbackInterface>,
            error: &CxxString,
        );

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

    }

    extern "Rust" {
        // This will trigger cxx to generate UniquePtrTarget
        // for CreateSdpCallbackInterface.
        fn _touch_unique_ptr_create_sdp_callback(
            i: UniquePtr<CreateSdpCallbackInterface>,
        );

        // This will trigger cxx to generate UniquePtrTarget
        // for SetDescriptionCallbackInterface.
        fn _touch_unique_ptr_set_description_callback(
            i: UniquePtr<SetDescriptionCallbackInterface>,
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
