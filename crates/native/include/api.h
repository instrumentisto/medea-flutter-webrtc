#pragma once
#include <string>

// Completion callback for the `Webrtc::CreateOffer` and `Webrtc::CreateAnswer`
// functions.
class CreateSdpCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess(const std::string& sdp, const std::string& kind) = 0;

  // Called when an operation fails.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~CreateSdpCallbackInterface() = default;
};

// Completion callback for the `Webrtc::SetLocalDescription` and
// `Webrtc::SetRemoteDescription` functions.
class SetDescriptionCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess() = 0;

  // Called when an operation fails.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~SetDescriptionCallbackInterface() = default;
};

struct SignalingStateWrapper;
struct IceConnectionStateWrapper;
struct PeerConnectionStateWrapper;
struct IceGatheringStateWrapper;

class PeerConnectionOnEventInterface {
 public:
  virtual void OnSignalingChange(const SignalingStateWrapper& new_state) = 0;
  virtual void OnStandardizedIceConnectionChange(const IceConnectionStateWrapper& new_state) = 0;
  virtual void OnConnectionChange(const PeerConnectionStateWrapper& new_state) = 0;
  virtual void OnIceGatheringChange(const IceGatheringStateWrapper& new_state) = 0;
  virtual ~PeerConnectionOnEventInterface() = default;
};
