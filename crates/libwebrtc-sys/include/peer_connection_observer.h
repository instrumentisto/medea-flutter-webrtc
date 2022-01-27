#pragma once

#include <functional>
#include <optional>
#include "api/peer_connection_interface.h"
#include "rust/cxx.h"

namespace bridge {
// Struct implement Rust trait `SetDescriptionCallback`.
struct DynSetDescriptionCallback;
// Struct implement Rust trait `CreateSdpCallback`.
struct DynCreateSdpCallback;
}  // namespace bridge

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

// `CreateSessionDescriptionObserver` used for calling callback
// `CreateOffer/Answer`.
class CreateSessionDescriptionObserver
    : public rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
 public:
  CreateSessionDescriptionObserver(
      rust::Box<bridge::DynCreateSdpCallback> callbacks);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::DynCreateSdpCallback>> callbacks;
};

// `SetLocalDescriptionObserver` used for calling callback
// `SetLocalDescription`.
class SetLocalDescriptionObserver
    : public rtc::RefCountedObject<
          webrtc::SetLocalDescriptionObserverInterface> {
 public:
  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserver(
      rust::Box<bridge::DynSetDescriptionCallback> callbacks);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> callbacks;
};

// `SetRemoteDescriptionObserverInterface` used for calling callback
// `SetRemoteDescription`.
class SetRemoteDescriptionObserver
    : public rtc::RefCountedObject<
          webrtc::SetRemoteDescriptionObserverInterface> {
 public:
  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserver(
      rust::Box<bridge::DynSetDescriptionCallback> callbacks);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> callbacks;
};
}  // namespace observer
