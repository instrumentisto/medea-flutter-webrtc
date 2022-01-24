#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"
#include "third_party\abseil-cpp\absl\types\optional.h"

namespace bridge {
  struct CallBackCreateOfferAnswer;
  struct CallBackDescription;
  struct DynCreateOfferCallback;
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
    : public webrtc::CreateSessionDescriptionObserver {
 public:

  absl::optional<rust::cxxbridge1::Box<bridge::DynCreateOfferCallback>> cb;
  // RefCount for lifetime observer.
  mutable int ref_count;

  // Construct `CreateOffer/Answer Observer` where
  // s - void (*callback_success)(std::string, std::string),
  // f - void (*callback_fail)(std::string).
  CreateSessionDescriptionObserver(
    rust::cxxbridge1::Box<bridge::DynCreateOfferCallback> cb);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;

};

class SetLocalDescriptionObserverInterface
    : public webrtc::SetLocalDescriptionObserverInterface {
 public:
  absl::optional<rust::cxxbridge1::Box<bridge::CallBackDescription>> cb;

  // RefCount for lifetime observer.
  mutable int ref_count;

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface(
    rust::cxxbridge1::Box<bridge::CallBackDescription> cb);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;
};

class SetRemoteDescriptionObserverInterface
    : public webrtc::SetRemoteDescriptionObserverInterface {
 public:
  absl::optional<rust::cxxbridge1::Box<bridge::CallBackDescription>> cb;

  // RefCount for lifetime observer.
  mutable int ref_count;

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface(
    rust::cxxbridge1::Box<bridge::CallBackDescription> cb
  );

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;
};
}
