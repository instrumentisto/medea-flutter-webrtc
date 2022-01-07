
#include "libwebrtc-sys\include\peer_connection_observer.h"

namespace my_stuff
{

  // Called any time the IceGatheringState changes.
  void MyObserver::OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state) {};

  // A new ICE candidate has been gathered.
  void MyObserver::OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {};

  // Triggered when a remote peer opens a data channel.
  void MyObserver::OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

  // Triggered when the SignalingState changed.
  void MyObserver::OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state) {};

  MyCreateSessionObserver::MyCreateSessionObserver(
    size_t s, 
    size_t f) {
      success = (callback_success) s;
      fail = (callback_fail) f;
    };

  void MyCreateSessionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    success(sdp, type);
  };

  void MyCreateSessionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };

  void MyCreateSessionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus MyCreateSessionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};

  MySessionObserver::MySessionObserver(
    size_t s, 
    size_t f) {
      success = (callback_success_desc) s;
      fail = (callback_fail) f;
    }

  void MySessionObserver::OnSuccess() {
    success();
  };
  void MySessionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    fail(err);
  };
  void MySessionObserver::AddRef() const {};
  rtc::RefCountReleaseStatus MySessionObserver::Release() const {return rtc::RefCountReleaseStatus::kDroppedLastRef;};
}