
#include "libwebrtc-sys\include\peer_connection_observer.h"

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
    size_t s,
    size_t f) {
      success = (callback_success) s;
      fail = (callback_fail) f;
    };

  // Calls when a `CreateOffer\Answer` is success.
  void CreateSessionDescriptionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    success(sdp, type);
  };

  // Calls when a `CreateOffer\Answer` is fail.
  void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };

  void CreateSessionDescriptionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus CreateSessionDescriptionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

  // Construct `SetLocal\RemoteDescription Observer` where
  // s - void (*callback_success_desc)(),
  // f - void (*callback_fail)(std::string).
  SetSessionDescriptionObserver::SetSessionDescriptionObserver(
    size_t s,
    size_t f) {
      success = (callback_success_desc) s;
      fail = (callback_fail) f;
    }

  // Calls when a `SetLocal\RemoteDescription` is success.
  void SetSessionDescriptionObserver::OnSuccess() {
    success();
  };
  
  // Calls when a `SetLocal\RemoteDescription` is fail.
  void SetSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };
  void SetSessionDescriptionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus SetSessionDescriptionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};
}
