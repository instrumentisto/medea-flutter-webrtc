#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"
#include "third_party\libwebrtc\include\base\atomicops.h"

namespace bridge {
  struct RcRefCellObs;
}

namespace observer
{
// `PeerConnectionObserver` used for calling callback RTCPeerConnection events.
class PeerConnectionObserver: public webrtc::PeerConnectionObserver
{
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
class CreateSessionDescriptionObserver: public webrtc::CreateSessionDescriptionObserver
{
  public:
  rust::Fn<void (const std::string &, const std::string &)> success;
  rust::Fn<void (const std::string &)> fail;
  mutable volatile int ref_count = 0;


  // Construct `CreateOffer\Answer Observer` where
  // s - void (*callback_success)(std::string, std::string),
  // f - void (*callback_fail)(std::string).
  CreateSessionDescriptionObserver(
    rust::Fn<void (const std::string &, const std::string &)> s,
    rust::Fn<void (const std::string &)> f);

  // Calls when a `CreateOffer\Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer\Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  void AddRef() const;
  rtc::RefCountReleaseStatus Release() const;

};

class SetLocalDescriptionObserverInterface : public webrtc::SetLocalDescriptionObserverInterface {
  public:
  rust::Fn<void ()> success;
  rust::Fn<void (const std::string &)> fail;
  mutable volatile int ref_count = 0;
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);
  SetLocalDescriptionObserverInterface(rust::Fn<void ()> s, rust::Fn<void (const std::string &)> f);
  void AddRef() const;
  rtc::RefCountReleaseStatus Release() const;
};

class SetRemoteDescriptionObserverInterface : public webrtc::SetRemoteDescriptionObserverInterface {
  public:
  rust::Fn<void ()> success;
  rust::Fn<void (const std::string &)> fail;
  mutable volatile int ref_count = 0;
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);
  SetRemoteDescriptionObserverInterface(rust::Fn<void ()> s, rust::Fn<void (const std::string &)> f);
  void AddRef() const;
  rtc::RefCountReleaseStatus Release() const;
};
}
