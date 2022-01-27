#pragma once
#include <string>

class CreateSdpCallbackInterface {
 public:
  virtual void OnSuccess(const std::string& sdp, const std::string& type_) = 0;
  virtual void OnFail(const std::string& error) = 0;
  virtual ~CreateSdpCallbackInterface() = default;
};

class SetDescriptionCallbackInterface {
 public:
  virtual void OnSuccess() = 0;
  virtual void OnFail(const std::string& error) = 0;
  virtual ~SetDescriptionCallbackInterface() = default;
};

class PeerConnectionOnEventInterface {
 public:
  virtual void OnSignalingChange(const std::string& event) = 0;
  virtual ~PeerConnectionOnEventInterface() = default;
};
