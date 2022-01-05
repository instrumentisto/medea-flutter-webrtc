#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"


namespace my_stuff
{
typedef void (*callback_success)(std::string, std::string);
typedef void (*callback_fail)(std::string);

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
  public:
  rust::cxxbridge1::Fn<void (const std::string &, const std::string &)> success;
  rust::cxxbridge1::Fn<void (const std::string &)> fail;

  MyCreateSessionObserver(
    rust::cxxbridge1::Fn<void (const std::string &, const std::string &)> s, 
    rust::cxxbridge1::Fn<void (const std::string &)> f) : success(s), fail(f) {};

  void OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    printf("TEST CO\n");
    success(type, sdp);
  };

  void OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };

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
