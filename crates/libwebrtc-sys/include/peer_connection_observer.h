#pragma once

#include <functional>
#include <optional>
#include "api\peer_connection_interface.h"
#include "rust/cxx.h"
#include <optional>
#include <cstdio>

namespace bridge {
// Struct implement Rust trait `SetDescriptionCallback`.
struct SetLocalRemoteDescriptionCallBack;
// Struct implement Rust trait `CreateSdpCallback`.
struct CreateOfferAnswerCallback;
}  // namespace bridge

namespace observer {

// `PeerConnectionObserver` used for calling callback RTCPeerConnection events.
class PeerConnectionObserver : public webrtc::PeerConnectionObserver {
  // Called any time the IceGatheringState changes.
  void OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state);

  // A new ICE candidate has been gathered.
  void OnIceCandidate(const webrtc::IceCandidateInterface* candidate);

  // Gathering of an ICE candidate failed.
  // See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
  // `host_candidate` is a stringified socket address.
  void OnIceCandidateError(const std::string& host_candidate,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text);

  // Ice candidates have been removed.
  // TODO(honghaiz): Make this a pure virtual method when all its subclasses
  // implement it.
  void OnIceCandidatesRemoved(
      const std::vector<cricket::Candidate>& candidates);

  // Called when the ICE connection receiving status changes.
  void OnIceConnectionReceivingChange(bool receiving);

  // Called when the selected candidate pair for the ICE connection changes.
  void OnIceSelectedCandidatePairChanged(
      const cricket::CandidatePairChangeEvent& event);

  // This is called when a receiver and its track are created.
  // TODO(zhihuang): Make this pure virtual when all subclasses implement it.
  // Note: This is called with both Plan B and Unified Plan semantics. Unified
  // Plan users should prefer OnTrack, OnAddTrack is only called as backwards
  // compatibility (and is called in the exact same situations as OnTrack).
  void OnAddTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
      const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>& streams);

  // This is called when signaling indicates a transceiver will be receiving
  // media from the remote endpoint. This is fired during a call to
  // SetRemoteDescription. The receiving track can be accessed by:
  // `transceiver->receiver()->track()` and its associated streams by
  // `transceiver->receiver()->streams()`.
  // Note: This will only be called if Unified Plan semantics are specified.
  // This behavior is specified in section 2.2.8.2.5 of the "Set the
  // RTCSessionDescription" algorithm:
  // https://w3c.github.io/webrtc-pc/#set-description
  void OnTrack(
      rtc::scoped_refptr<webrtc::RtpTransceiverInterface> transceiver);

  // Called when signaling indicates that media will no longer be received on a
  // track.
  // With Plan B semantics, the given receiver will have been removed from the
  // PeerConnection and the track muted.
  // With Unified Plan semantics, the receiver will remain but the transceiver
  // will have changed direction to either sendonly or inactive.
  // https://w3c.github.io/webrtc-pc/#process-remote-track-removal
  // TODO(hbos,deadbeef): Make pure virtual when all subclasses implement it.
  void OnRemoveTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver);

  // Called when an interesting usage is detected by WebRTC.
  // An appropriate action is to add information about the context of the
  // PeerConnection and write the event to some kind of "interesting events"
  // log function.
  // The heuristics for defining what constitutes "interesting" are
  // implementation-defined.
  void OnInterestingUsage(int usage_pattern);

  //~PeerConnectionObserver() {};

  private:
  //std::optional<rust::Box<bridge::PeerConnectionEventsCallBack>> cb;
};

// `CreateSessionDescriptionObserver` used for calling callback
// `CreateOffer/Answer`.
class CreateSessionDescriptionObserver
    : public rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
 public:
  CreateSessionDescriptionObserver(
      rust::Box<bridge::CreateOfferAnswerCallback> callbacks);

  // Calls when a `CreateOffer/Answer` is success.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Calls when a `CreateOffer/Answer` is fail.
  void OnFailure(webrtc::RTCError error);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::CreateOfferAnswerCallback>> callbacks;
};

// `SetLocalDescriptionObserver` used for calling callback
// `SetLocalDescription`.
class SetLocalDescriptionObserver
    : public rtc::RefCountedObject<
          webrtc::SetLocalDescriptionObserverInterface> {
 public:
  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

  // Construct SetLocalDescriptionObserverInterface.
  SetLocalDescriptionObserver(
      rust::Box<bridge::SetLocalRemoteDescriptionCallBack> callbacks);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> callbacks;
};

// `SetRemoteDescriptionObserverInterface` used for calling callback
// `SetRemoteDescription`.
class SetRemoteDescriptionObserver
    : public rtc::RefCountedObject<
          webrtc::SetRemoteDescriptionObserverInterface> {
 public:
  // Calls when a `SetRemoteDescription` is complete or fail.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserver(
      rust::Box<bridge::SetLocalRemoteDescriptionCallBack> callbacks);

 private:
  // Rust struct for callbacks.
  // Optional for no init `rust::Box`.
  std::optional<rust::Box<bridge::SetLocalRemoteDescriptionCallBack>> callbacks;
};
}  // namespace observer
