pub use internal::*;

#[cxx::bridge]
mod internal {
    unsafe extern "C++" {
        include!("flutter-webrtc-native/include/api.h");

        pub type OnFrameHandler;

        #[cxx_name = "OnFrame"]
        fn on_frame(self: Pin<&mut OnFrameHandler>);
    }
}
