#pragma once

#include <cstdio>
#include <functional>
#include <optional>
#include "api/peer_connection_interface.h"
#include "rust/cxx.h"

namespace bridge {
struct DynPeerConnectionOnEvent;
struct DynSetDescriptionCallback;
struct DynCreateSdpCallback;
}  // namespace bridge

namespace observer {

// `PeerConnectionObserver` that handles RTCPeerConnection events.
class PeerConnectionObserver : public webrtc::PeerConnectionObserver {
public:
  PeerConnectionObserver(
      rust::Box<bridge::DynPeerConnectionOnEvent> cb);

    // Triggered when the SignalingState changed.
  void OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state);

  // Triggered when a remote peer opens a data channel.
  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel);

  // Used to fire spec-compliant onnegotiationneeded events, which should only
  // fire when the Operations Chain is empty. The observer is responsible for
  // queuing a task (e.g. Chromium: jump to main thread) to maybe fire the
  // event. The event identified using `event_id` must only fire if
  // PeerConnection::ShouldFireNegotiationNeededEvent() returns true since it is
  // possible for the event to become invalidated by operations subsequently
  // chained.
  void OnNegotiationNeededEvent(uint32_t event_id);

  // Called any time the standards-compliant IceConnectionState changes.
  void OnStandardizedIceConnectionChange(
      webrtc::PeerConnectionInterface::IceConnectionState new_state);

  // Called any time the PeerConnectionState changes.
  void OnConnectionChange(
      webrtc::PeerConnectionInterface::PeerConnectionState new_state);

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

  // Gathering of an ICE candidate failed.
  // See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
  void OnIceCandidateError(const std::string& address,
                                   int port,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text);

  // Ice candidates have been removed.
  void OnIceCandidatesRemoved(
      const std::vector<cricket::Candidate>& candidates);

  // Called when the ICE connection receiving status changes.
  void OnIceConnectionReceivingChange(bool receiving);

  // Called when the selected candidate pair for the ICE connection changes.
  void OnIceSelectedCandidatePairChanged(
      const cricket::CandidatePairChangeEvent& event);

  // This is called when a receiver and its track are created.
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
  void OnRemoveTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver);

  // Called when an interesting usage is detected by WebRTC.
  // An appropriate action is to add information about the context of the
  // PeerConnection and write the event to some kind of "interesting events"
  // log function.
  // The heuristics for defining what constitutes "interesting" are
  // implementation-defined.
  void OnInterestingUsage(int usage_pattern);

 private:
  std::optional<rust::Box<bridge::DynPeerConnectionOnEvent>> cb_;
};

// `CreateSessionDescriptionObserver` that propagates completion result to the
// Rust side.
class CreateSessionDescriptionObserver
    : public rtc::RefCountedObject<webrtc::CreateSessionDescriptionObserver> {
 public:
  // Creates a new `CreateSessionDescriptionObserver`.
  CreateSessionDescriptionObserver(rust::Box<bridge::DynCreateSdpCallback> cb);

  // Called when a `CreateOffer` or a `CreateAnswer` operation succeeds.
  void OnSuccess(webrtc::SessionDescriptionInterface* desc);

  // Called when a `CreateOffer` or a `CreateAnswer` operation fails.
  void OnFailure(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynCreateSdpCallback>> cb_;
};

// `SetLocalDescriptionObserverInterface` that propagates completion result to
// the Rust side.
class SetLocalDescriptionObserver
    : public rtc::RefCountedObject<
        webrtc::SetLocalDescriptionObserverInterface> {
 public:
  // Creates a new `SetLocalDescriptionObserver`.
  SetLocalDescriptionObserver(rust::Box<bridge::DynSetDescriptionCallback> cb);

  // Called when a `SetLocalDescription` completes.
  void OnSetLocalDescriptionComplete(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> cb_;
};

// `SetRemoteDescriptionObserver` that propagates completion result to the Rust
// side.
class SetRemoteDescriptionObserver
    : public rtc::RefCountedObject<
        webrtc::SetRemoteDescriptionObserverInterface> {
 public:
  // Creates a new `SetRemoteDescriptionObserver`.
  SetRemoteDescriptionObserver(rust::Box<bridge::DynSetDescriptionCallback> cb);

  // Called when a `SetRemoteDescription` completes.
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error);

 private:
  // Rust side callback.
  std::optional<rust::Box<bridge::DynSetDescriptionCallback>> cb_;
};
}  // namespace observer
