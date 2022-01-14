
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

  // Construct `SetLocal\RemoteDescription Observer` where
  // s - void (*callback_success_desc)(),
  // f - void (*callback_fail)(std::string).
  SetSessionDescriptionObserver::SetSessionDescriptionObserver(
    rust::Fn<void ()> s,
    rust::Fn<void (const std::string &)> f,
    rust::Box<bridge::RcRefCellObs> lt) : lt(std::move(lt)) {
      success = s;
      fail = f;
    }

  // Calls when a `SetLocal\RemoteDescription` is success.
  void SetSessionDescriptionObserver::OnSuccess() {
    (*success)();
  };

  // Calls when a `SetLocal\RemoteDescription` is fail.
  void SetSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    (*fail)(err);
    printf("TEST1 C\n");
  };
  void SetSessionDescriptionObserver::AddRef() const {
    printf("TEST1 A\n");
  };
  rtc::RefCountReleaseStatus SetSessionDescriptionObserver::Release() const {
    printf("TEST1 R\n");
    return rtc::RefCountReleaseStatus::kDroppedLastRef;};

  void SetSessionDescriptionObserver::set_lifetime(rust::Box<bridge::RcRefCellObs> n_lt) {
    lt = std::move(n_lt);
  }

}