#pragma once

#include <string>

// Completion callback for the `Webrtc::CreateOffer` and `Webrtc::CreateAnswer`
// functions.
class CreateSdpCallbackInterface {
 public:
  // Called if an operation succeeds.
  virtual void OnSuccess(const std::string& sdp, const std::string& kind) = 0;

  // Called if an operation fails.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~CreateSdpCallbackInterface() = default;
};

// Completion callback for the `Webrtc::SetLocalDescription` and
// `Webrtc::SetRemoteDescription` functions.
class SetDescriptionCallbackInterface {
 public:
  // Called if an operation succeeds.
  virtual void OnSuccess() = 0;

  // Called if an operation fails.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~SetDescriptionCallbackInterface() = default;
};
