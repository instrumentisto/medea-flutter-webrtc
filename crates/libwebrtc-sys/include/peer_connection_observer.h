#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"


namespace observer
{
typedef void (*callback_success)(std::string, std::string);
typedef void (*callback_fail)(std::string);

typedef void (*callback_success_desc)();

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
  callback_success success;
  callback_fail fail;

  // Construct `CreateOffer\Answer Observer` where
  // s - void (*callback_success)(std::string, std::string),
  // f - void (*callback_fail)(std::string).
  CreateSessionDescriptionObserver(
    size_t s,
    size_t f);

  // Calls when a `CreateOffer\Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer\Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  void AddRef() const;
  rtc::RefCountReleaseStatus Release() const;

};

// Session Description Observer used for calling callback when set description
// success or fail.
class SetSessionDescriptionObserver: public webrtc::SetSessionDescriptionObserver
{
  public:
  callback_success_desc success;
  callback_fail fail;

  // Construct `SetLocal\RemoteDescription Observer` where
  // s - void (*callback_success_desc)(),
  // f - void (*callback_fail)(std::string).
  SetSessionDescriptionObserver(
    size_t s,
    size_t f);

  // Calls when a `SetLocal\RemoteDescription` is success.
  void OnSuccess();

  // Calls when a `SetLocal\RemoteDescription` is fail.
  void OnFailure(webrtc::RTCError error);

  void AddRef() const;
  rtc::RefCountReleaseStatus Release() const;

};
}
