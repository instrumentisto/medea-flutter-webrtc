#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"
#include <optional>

namespace bridge {
  struct SetLocalRemoteDescriptionCallBack;
  struct CreateOfferAnswerCallback;
}

namespace observer {

// `PeerConnectionObserver` used for calling callback RTCPeerConnection events.
class PeerConnectionObserver : public webrtc::PeerConnectionObserver {
  // Called any time the IceGatheringState changes.
  void OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state);

  // A new ICE candidate has been gathered.
  void OnIceCandidate(const webrtc::IceCandidateInterface* candidate);

  // Triggered when a remote peer opens a data channel.
  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel);

  // Triggered when the SignalingState changed.
  void OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state);
};

// Create Session Description Observer used
// for calling callback when create [Offer] or [Answer]
// success or fail.
class CreateSessionDescriptionObserver : public
    rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
  public:
  CreateSessionDescriptionObserver(
    rust::Box<bridge::CreateOfferAnswerCallback> cb);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  private:
  // Has Rust fn for `OnSuccess` and `OnFailure`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::CreateOfferAnswerCallback>> cb;
};

class SetLocalDescriptionObserverInterface : public
    rtc::RefCountedObject<webrtc::SetLocalDescriptionObserverInterface> {
  public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb);

  private:
  // Has Rust fn for `OnSetLocalDescriptionComplete`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb;
};

class SetRemoteDescriptionObserverInterface : public
    rtc::RefCountedObject<webrtc::SetRemoteDescriptionObserverInterface> {
  public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb
  );

  private:
  // Has Rust fn for `SetLocalRemoteDescriptionCallBack`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb; 
};
}
