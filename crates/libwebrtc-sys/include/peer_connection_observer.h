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

  // todo
  struct PeerConnectionEventsCallBack;
}

namespace observer {

// `PeerConnectionObserver` used for calling callback RTCPeerConnection events.
class PeerConnectionObserver: public webrtc::PeerConnectionObserver
{
  public:

  // todo
  PeerConnectionObserver(rust::Box<bridge::PeerConnectionEventsCallBack> cb);

  // Triggered when the SignalingState changed.
  void OnSignalingChange(
       webrtc::PeerConnectionInterface::SignalingState new_state);

  // Triggered when media is received on a new stream from remote peer.
  void OnAddStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream);

  // Triggered when a remote peer closes a stream.
  void OnRemoveStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream);

  // Triggered when a remote peer opens a data channel.
  void OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel);
      
  // Triggered when renegotiation is needed. For example, an ICE restart
  // has begun.
  // TODO(hbos): Delete in favor of OnNegotiationNeededEvent() when downstream
  // projects have migrated.
  void OnRenegotiationNeeded();
  // Used to fire spec-compliant onnegotiationneeded events, which should only
  // fire when the Operations Chain is empty. The observer is responsible for
  // queuing a task (e.g. Chromium: jump to main thread) to maybe fire the
  // event. The event identified using `event_id` must only fire if
  // PeerConnection::ShouldFireNegotiationNeededEvent() returns true since it is
  // possible for the event to become invalidated by operations subsequently
  // chained.
  void OnNegotiationNeededEvent(uint32_t event_id);

  // Called any time the legacy IceConnectionState changes.
  //
  // Note that our ICE states lag behind the standard slightly. The most
  // notable differences include the fact that "failed" occurs after 15
  // seconds, not 30, and this actually represents a combination ICE + DTLS
  // state, so it may be "failed" if DTLS fails while ICE succeeds.
  //
  // TODO(jonasolsson): deprecate and remove this.
  void OnIceConnectionChange(
      webrtc::PeerConnectionInterface::IceConnectionState new_state);

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
  private:
  std::optional<rust::Box<bridge::PeerConnectionEventsCallBack>> cb;
};

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
