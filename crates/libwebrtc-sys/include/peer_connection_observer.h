#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"
#include "third_party\abseil-cpp\absl\types\optional.h"

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
class CreateSessionDescriptionObserver
    : public webrtc::CreateSessionDescriptionObserver, 
    rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
 public:
  CreateSessionDescriptionObserver(
    rust::Box<bridge::CreateOfferAnswerCallback> cb);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;

 private:
  absl::optional<rust::Box<bridge::CreateOfferAnswerCallback>> cb;
};

class SetLocalDescriptionObserverInterface
    : public webrtc::SetLocalDescriptionObserverInterface, 
    rtc::RefCountedObject<webrtc::SetLocalDescriptionObserverInterface> {
 public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;

  private:
    absl::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb;
};

class SetRemoteDescriptionObserverInterface
    : public webrtc::SetRemoteDescriptionObserverInterface, 
    rtc::RefCountedObject<webrtc::SetRemoteDescriptionObserverInterface>  {
 public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb
  );

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;
  private:
    absl::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb; 
};
}
