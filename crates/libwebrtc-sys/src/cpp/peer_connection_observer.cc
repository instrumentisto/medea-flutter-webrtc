
#include "libwebrtc-sys\include\peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace observer {
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

// Construct `CreateOffer\Answer Observer`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::cxxbridge1::Box<bridge::DynCreateOfferCallback> cb) {
    this->cb = std::move(cb);
};

// Calls when a `CreateOffer\Answer` is success.
void CreateSessionDescriptionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
  std::string type = desc->type();
  std::string sdp;
  desc->ToString(&sdp);
  delete desc;
  bridge::success(*cb.value(), sdp, type);

};

// Calls when a `CreateOffer\Answer` is fail.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  std::string err = std::string(error.message());
  bridge::fail(*cb.value(), err);
};

// Implementation rtc::RefCountInterface::AddRef.
void CreateSessionDescriptionObserver::AddRef() const {
  ++ref_count;
};

// Implementation rtc::RefCountInterface::Release.
rtc::RefCountReleaseStatus CreateSessionDescriptionObserver::Release() const {
  if (--ref_count == 0) {
    delete this;
    return rtc::RefCountReleaseStatus::kDroppedLastRef;
  }
  return rtc::RefCountReleaseStatus::kOtherRefsRemained;
};

// Calls when a `SetLocalDescription` is complete or fail.
void SetLocalDescriptionObserverInterface::OnSetLocalDescriptionComplete(webrtc::RTCError error) {
  if (error.ok()) {
    cb.value()->success_set_descr();
  } else {
    std::string error(error.message());
    cb.value()->fail_set_descr(error);
  }
};

// Construct SetRemoteDescriptionObserverInterface.
SetLocalDescriptionObserverInterface::SetLocalDescriptionObserverInterface(
    rust::cxxbridge1::Box<bridge::CallBackDescription> cb
) {
  this->cb = std::move(cb);
};

// Implementation rtc::RefCountInterface::AddRef.
void SetLocalDescriptionObserverInterface::AddRef() const {
  ++ref_count;
};
// Implementation rtc::RefCountInterface::Release.
rtc::RefCountReleaseStatus SetLocalDescriptionObserverInterface::Release() const {
  if (--ref_count == 0) {
    delete this;
    return rtc::RefCountReleaseStatus::kDroppedLastRef;
  }
  return rtc::RefCountReleaseStatus::kOtherRefsRemained;
};

// Calls when a `SetRemoteDescription` is complete or fail.
void SetRemoteDescriptionObserverInterface::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok()) {
    cb.value()->success_set_descr();
  } else {
    std::string error(error.message());
    cb.value()->fail_set_descr(error);
  }
};

// Construct SetRemoteDescriptionObserverInterface.
SetRemoteDescriptionObserverInterface::SetRemoteDescriptionObserverInterface(
    rust::cxxbridge1::Box<bridge::CallBackDescription> cb
) {
  this->cb = std::move(cb);
};

// Implementation rtc::RefCountInterface::AddRef.
void SetRemoteDescriptionObserverInterface::AddRef() const {
  ++ref_count;
};

// Implementation rtc::RefCountInterface::Release.
rtc::RefCountReleaseStatus SetRemoteDescriptionObserverInterface::Release() const {
  if (--ref_count == 0) {
    delete this;
    return rtc::RefCountReleaseStatus::kDroppedLastRef;
  }
  return rtc::RefCountReleaseStatus::kOtherRefsRemained;
};

};
