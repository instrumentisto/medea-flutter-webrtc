#include "flutter_webrtc.h"
#include "wrapper.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

  // Calls Rust `create_default_peer_connection()` and write `PeerConnectionId` in result.
  void CreateRTCPeerConnection(
        flutter::BinaryMessenger* messenger,
        rust::cxxbridge1::Box<Webrtc>& webrtc,
        const flutter::MethodCall<EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Calls Rust `create_offer()`. 
  // success or fail will be write in result in `CreateSessionDescriptionObserver` callbacks.
  void CreateOffer(
        rust::cxxbridge1::Box<Webrtc>& webrtc,
        const flutter::MethodCall<EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Calls Rust `create_answer()`. 
  // success or fail will be write in result in `CreateSessionDescriptionObserver` callbacks.
  void CreateAnswer(
        rust::cxxbridge1::Box<Webrtc>& webrtc,
        const flutter::MethodCall<EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Calls Rust `set_local_description()`. 
  // success or fail will be write in result in `SetLocalDescriptionObserverInterface` callbacks.
  void SetLocalDescription(
        rust::cxxbridge1::Box<Webrtc>& webrtc,
        const flutter::MethodCall<EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  // Calls Rust `set_remote_description()`. 
  // success or fail will be write in result in `SetRemoteDescriptionObserverInterface` callbacks.
  void SetRemoteDescription(
        rust::cxxbridge1::Box<Webrtc>& webrtc,
        const flutter::MethodCall<EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

}
