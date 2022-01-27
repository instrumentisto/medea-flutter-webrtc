
#include "libwebrtc-sys\include\peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace observer {

// Called any time the IceGatheringState changes.
void PeerConnectionObserver::OnIceGatheringChange(
    webrtc::PeerConnectionInterface::IceGatheringState new_state){};

// A new ICE candidate has been gathered.
void PeerConnectionObserver::OnIceCandidate(
    const webrtc::IceCandidateInterface* candidate){};

// Triggered when a remote peer opens a data channel.
void PeerConnectionObserver::OnDataChannel(
    rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel){};

// Triggered when the SignalingState changed.
void PeerConnectionObserver::OnSignalingChange(
    webrtc::PeerConnectionInterface::SignalingState new_state){};

// Construct `CreateOffer/Answer Observer`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Box<bridge::DynCreateSdpCallback> callbacks) {
  this->callbacks = std::move(callbacks);
};

// Calls when a `CreateOffer/Answer` is success.
void CreateSessionDescriptionObserver::OnSuccess(
    webrtc::SessionDescriptionInterface* desc) {
  if (callbacks) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    bridge::success_sdp(*callbacks.value(), sdp, type);
  }
  delete desc;
};

// Calls when a `CreateOffer\Answer` is fail.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  std::string err = std::string(error.message());
  bridge::fail_sdp(*callbacks.value(), err);
};

// Calls when a `SetLocalDescription` is complete or fail.
void SetLocalDescriptionObserver::OnSetLocalDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && callbacks) {
    bridge::success_set_description(*callbacks.value());
  } else {
    std::string error(error.message());
    bridge::fail_set_description(*callbacks.value(), error);
  }
};

// Construct `SetRemoteDescriptionObserverInterface`.
SetLocalDescriptionObserver::SetLocalDescriptionObserver(
    rust::cxxbridge1::Box<bridge::DynSetDescriptionCallback>
        callbacks) {
  this->callbacks = std::move(callbacks);
};

// Calls when a `SetRemoteDescription` is complete or fail.
void SetRemoteDescriptionObserver::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && callbacks.has_value()) {
    bridge::success_set_description(*callbacks.value());
  } else {
    std::string error(error.message());
    bridge::fail_set_description(*callbacks.value(), error);
  }
};

// Construct `SetRemoteDescriptionObserver`.
SetRemoteDescriptionObserver::SetRemoteDescriptionObserver(
    rust::cxxbridge1::Box<bridge::DynSetDescriptionCallback>
        callbacks) {
  this->callbacks = std::move(callbacks);
};

};  // namespace observer
