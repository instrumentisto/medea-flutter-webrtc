
#include "libwebrtc-sys\include\peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include <cstdio>

namespace observer
{
  // Called any time the IceGatheringState changes.
  void PeerConnectionObserver::OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state) {};

  // A new ICE candidate has been gathered.
  void PeerConnectionObserver::OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {};

  // Triggered when a remote peer opens a data channel.
  void PeerConnectionObserver::OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

  // Triggered when the SignalingState changed.
  void PeerConnectionObserver::OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state) {};

  // Construct `CreateOffer\Answer Observer` where
  // s - void (*callback_success)(std::string, std::string),
  // f - void (*callback_fail)(std::string).
  CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Fn<void (const std::string &, const std::string &)> s,
    rust::Fn<void (const std::string &)> f) {
      success = s;
      fail = f;
    };

  // Calls when a `CreateOffer\Answer` is success.
  void CreateSessionDescriptionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    (*success)(sdp, type); 
  };

  // Calls when a `CreateOffer\Answer` is fail.
  void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    (*fail)(err);
  };

  void CreateSessionDescriptionObserver::AddRef() const {}; 
  rtc::RefCountReleaseStatus CreateSessionDescriptionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

  // SetLocalDescriptionObserverInterface
  void SetLocalDescriptionObserverInterface::OnSetLocalDescriptionComplete(webrtc::RTCError error) {
    if(error.ok()) {
      (*success)();
    } else {
      printf("C++2\n");
      std::string error(error.message());
      (*fail)(error);
    }
  };

  SetLocalDescriptionObserverInterface::SetLocalDescriptionObserverInterface(
    rust::Fn<void ()> s, 
    rust::Fn<void (const std::string &)> f
  ) {
    success = s;
    fail = f;
  };

  void SetLocalDescriptionObserverInterface::AddRef() const {};

  rtc::RefCountReleaseStatus SetLocalDescriptionObserverInterface::Release() const {
    return rtc::RefCountReleaseStatus::kDroppedLastRef;
  };

  // SetRemoteDescriptionObserverInterface

  void SetRemoteDescriptionObserverInterface::OnSetRemoteDescriptionComplete(webrtc::RTCError error) {
    if(error.ok()) {
      (*success)();
    } else {
      std::string error(error.message());
      (*fail)(error);
    }
  };

  SetRemoteDescriptionObserverInterface::SetRemoteDescriptionObserverInterface(
    rust::Fn<void ()> s, 
    rust::Fn<void (const std::string &)> f
  ) {
    success = s;
    fail = f;
  };

  void SetRemoteDescriptionObserverInterface::AddRef() const {};

  rtc::RefCountReleaseStatus SetRemoteDescriptionObserverInterface::Release() const {
    return rtc::RefCountReleaseStatus::kDroppedLastRef;
  };

};