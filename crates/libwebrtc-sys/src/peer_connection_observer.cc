
#include "libwebrtc-sys\include\peer_connection_observer.h"
// TODO: docs
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

  CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    size_t s,
    size_t f) {
      success = (callback_success) s;
      fail = (callback_fail) f;
    };

  void CreateSessionDescriptionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    success(sdp, type);
  };

  void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };

  void CreateSessionDescriptionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus CreateSessionDescriptionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

  SetSessionDescriptionObserver::SetSessionDescriptionObserver(
    size_t s,
    size_t f) {
      success = (callback_success_desc) s;
      fail = (callback_fail) f;
    }

  void SetSessionDescriptionObserver::OnSuccess() {
    success();
  };
  void SetSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };
  void SetSessionDescriptionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus SetSessionDescriptionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};
}
