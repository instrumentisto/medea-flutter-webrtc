#pragma once

#include "api\peer_connection_interface.h"
#include <functional>
#include "rust/cxx.h"
#include <optional>
#include <cstdio>

namespace bridge {
  // implement Rust trait `SetDescriptionCallback`.
  struct SetLocalRemoteDescriptionCallBack;
  // implement Rust trait `CreateSdpCallback`.
  struct CreateOfferAnswerCallback;
}

namespace observer {

// `CreateSessionDescriptionObserver` used for calling callback `CreateOffer/Answer`.
class CreateSessionDescriptionObserver : public
    rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
  public:
  CreateSessionDescriptionObserver(
    rust::Box<bridge::CreateOfferAnswerCallback> cb);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

  private:
  // Has Rust fn for `OnSuccess` and `OnFailure`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::CreateOfferAnswerCallback>> cb;
};


// `SetLocalDescriptionObserverInterface` used for calling callback `SetLocalDescription`.
class SetLocalDescriptionObserverInterface : public
    rtc::RefCountedObject<webrtc::SetLocalDescriptionObserverInterface> {
  public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb);

  private:
  // Has Rust fn for `OnSetLocalDescriptionComplete`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb;
};

// `SetRemoteDescriptionObserverInterface` used for calling callback `SetRemoteDescription`.
class SetRemoteDescriptionObserverInterface : public
    rtc::RefCountedObject<webrtc::SetRemoteDescriptionObserverInterface> {
  public:

  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface(
    rust::Box<bridge::SetLocalRemoteDescriptionCallBack> cb
  );

  private:
  // Has Rust fn for `SetLocalRemoteDescriptionCallBack`.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> cb; 
};
}
