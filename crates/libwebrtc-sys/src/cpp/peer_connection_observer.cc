
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
    rust::Box<bridge::DynCreateSdpCallback> cb) {
  this->cb_ = std::move(cb);
};

// Calls when a `CreateOffer/Answer` is success.
void CreateSessionDescriptionObserver::OnSuccess(
    webrtc::SessionDescriptionInterface* desc) {
  if (cb_) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    bridge::success_sdp(*cb_.value(), sdp, type);
  }
  delete desc;
};

// Calls when a `CreateOffer\Answer` is fail.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  std::string err = std::string(error.message());
  // TODO: why not checking cb, we need some consistency here
  bridge::fail_sdp(*cb_.value(), err);
};

// Calls when a `SetLocalDescription` is complete or fail.
void SetLocalDescriptionObserver::OnSetLocalDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && cb_) {
    bridge::success_set_description(*cb_.value());
  } else {
    std::string error(error.message());
    bridge::fail_set_description(*cb_.value(), error);
  }
};

// Construct `SetLocalDescriptionObserverInterface`.
SetLocalDescriptionObserver::SetLocalDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
};

// Calls when a `SetRemoteDescription` is complete or fail.
void SetRemoteDescriptionObserver::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && cb_) {
    bridge::success_set_description(*cb_.value());
  } else {
    std::string error(error.message());
    // TODO: move box out of optional and fail_set_description should take box
    // by value bad if's, what if error.ok() == true but cb_.has_value() ==
    // false?
    bridge::fail_set_description(*cb_.value(), error);
  }
};

// Construct `SetRemoteDescriptionObserver`.
SetRemoteDescriptionObserver::SetRemoteDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
};

};  // namespace observer
