#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"

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

  // Callback for `CreateOffer/Answer` is success.
  rust::Fn<void(const std::string&, const std::string&, size_t)> success;
  // Callback for `CreateOffer/Answer` is fail.
  rust::Fn<void(const std::string&, size_t)> fail;
  rust::Fn<void(size_t)> drop;
  void* context;

  // RefCount for lifetime observer.
  mutable int ref_count;

  // Construct `CreateOffer/Answer Observer` where
  // s - void (*callback_success)(std::string, std::string),
  // f - void (*callback_fail)(std::string).
  CreateSessionDescriptionObserver(
      rust::Fn<void(const std::string&, const std::string&, size_t)> s,
      rust::Fn<void(const std::string&, size_t)> f,
      rust::Fn<void(size_t)> d,
      size_t context_);

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
  // Callback for `SetLocalDescription` is success.
  rust::Fn<void(size_t)> success;
  // Callback for `SetLocalDescription` is fail.
  rust::Fn<void(const std::string&, size_t)> fail;
  void* context;

  // RefCount for lifetime observer.
  mutable int ref_count;

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface(
    rust::Fn<void(size_t)> s,
    rust::Fn<void(const std::string&, size_t)> f,
    size_t context_);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;
};

class SetRemoteDescriptionObserverInterface
    : public webrtc::SetRemoteDescriptionObserverInterface {
 public:
  // Callback for `SetRemoteDescription` is success.
  rust::Fn<void(size_t)> success;
  // Callback for `SetRemoteDescription` is fail.
  rust::Fn<void(const std::string&, size_t)> fail;

  void* context;

  // RefCount for lifetime observer.
  mutable int ref_count;

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface(
    rust::Fn<void(size_t)> s,
    rust::Fn<void(const std::string&, size_t)> f,
    size_t context_);

  // Interface rtc::RefCountInterface.
  void AddRef() const;
  // Interface rtc::RefCountInterface.
  rtc::RefCountReleaseStatus Release() const;
};
}
