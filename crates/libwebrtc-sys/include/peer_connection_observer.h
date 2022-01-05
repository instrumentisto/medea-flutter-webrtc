#pragma once

#include "api\peer_connection_interface.h"
#include <functional>

namespace my_stuff
{
class MyObserver: public webrtc::PeerConnectionObserver
{
  // Called any time the IceGatheringState changes.
  void OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state) {};

  // A new ICE candidate has been gathered.
  void OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {};

  // Triggered when a remote peer opens a data channel.
  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

  // Triggered when the SignalingState changed.
  void OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state) {};
};

class MyCreateSessionObserver: public webrtc::CreateSessionDescriptionObserver
{
  
  void OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);

  };
  void OnFailure(webrtc::RTCError error) {};
  void AddRef() const {};
  rtc::RefCountReleaseStatus Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

};

class MySessionObserver: public webrtc::SetSessionDescriptionObserver
{
  void OnSuccess() {};
  void OnFailure(webrtc::RTCError error) {};
  void AddRef() const {};
  rtc::RefCountReleaseStatus Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

};
}
