#pragma once
#include <string>
#include <memory>

struct VideoFrame;

// Completion callback for the `Webrtc::CreateOffer` and `Webrtc::CreateAnswer`
// functions.
class CreateSdpCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess(const std::string& sdp, const std::string& kind) = 0;

  // Called when an operation fails with the `error`.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~CreateSdpCallbackInterface() = default;
};

// Completion callback for the `Webrtc::SetLocalDescription` and
// `Webrtc::SetRemoteDescription` functions.
class SetDescriptionCallbackInterface {
 public:
  // Called when an operation succeeds.
  virtual void OnSuccess() = 0;

  // Called when an operation fails with the `error`.
  virtual void OnFail(const std::string& error) = 0;

  virtual ~SetDescriptionCallbackInterface() = default;
};

namespace rust {
  inline namespace cxxbridge1 {
    template <typename T>
    class Vec;
    class String;
  }
}
struct CandidatePairChangeEventSerialized;
struct RtpReceiverInterfaceSerialized;
struct OnTrackSerialized;

// Completion callback for the PeerConnection events.
class PeerConnectionOnEventInterface {
 public:
  virtual void OnSignalingChange(const std::string& new_state) = 0;
  virtual void OnStandardizedIceConnectionChange(const std::string& new_state) = 0;
  virtual void OnConnectionChange(const std::string& new_state) = 0;
  virtual void OnIceGatheringChange(const std::string& new_state) = 0;
  virtual void OnNegotiationNeededEvent(uint32_t event_id) = 0;
  virtual void OnIceCandidateError(const std::string& host_candidate,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text) = 0;

  virtual void OnIceCandidateError(const std::string& address,
                                   int port,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text) = 0;

  virtual void OnIceConnectionReceivingChange(bool receiving) = 0;
  virtual void OnInterestingUsage(int usage_pattern) = 0;

  virtual void OnIceCandidate(const std::string& candidate) = 0;
  virtual void OnIceCandidatesRemoved(rust::Vec<rust::String> candidates) = 0;
  virtual void OnIceSelectedCandidatePairChanged(CandidatePairChangeEventSerialized event) = 0;
 
  virtual void OnTrack(OnTrackSerialized event) = 0;

  virtual ~PeerConnectionOnEventInterface() = default;
};


// Callback for video frames handlers provided to the
// `Webrtc::create_video_sink()` function.
class OnFrameCallbackInterface {
 public:
  // Called when the underlying video engine produces a new video frame.
  //
  // The provided frame is a pointer to the `rust::Box<VideoFrame>`. Its
  // ownership can be transferred back to the Rust side using the
  // `rust::Box::from_raw()`.
  virtual void OnFrame(VideoFrame) = 0;

  virtual ~OnFrameCallbackInterface() = default;
};
