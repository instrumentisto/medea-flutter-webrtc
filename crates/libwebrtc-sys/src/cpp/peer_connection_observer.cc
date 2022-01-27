


#include "libwebrtc-sys/include/peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace observer {

  PeerConnectionObserver::PeerConnectionObserver(
      rust::Box<bridge::PeerConnectionOnEventCallback> callbacks) : callbacks(std::move(callbacks)) {};

  // Triggered when the SignalingState changed.
  void PeerConnectionObserver::OnSignalingChange(
      webrtc::PeerConnectionInterface::SignalingState new_state) {
        bridge::call_peer_connection_on_signaling_change(*callbacks.value(), "SignalingState");
      };

  // Called any time the IceGatheringState changes.
  void PeerConnectionObserver::OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state) {};

  // A new ICE candidate has been gathered.
  void PeerConnectionObserver::OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {};

  // Triggered when a remote peer opens a data channel.
  void PeerConnectionObserver::OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

  // Gathering of an ICE candidate failed.
  // See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
  // `host_candidate` is a stringified socket address.
  void PeerConnectionObserver::OnIceCandidateError(const std::string& host_candidate,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text) {};

  // Ice candidates have been removed.
  // TODO(honghaiz): Make this a pure virtual method when all its subclasses
  // implement it.
  void PeerConnectionObserver::OnIceCandidatesRemoved(
      const std::vector<cricket::Candidate>& candidates) {};

  // Called when the ICE connection receiving status changes.
  void PeerConnectionObserver::OnIceConnectionReceivingChange(bool receiving) {};

  // Called when the selected candidate pair for the ICE connection changes.
  void PeerConnectionObserver::OnIceSelectedCandidatePairChanged(
      const cricket::CandidatePairChangeEvent& event) {};

  // This is called when a receiver and its track are created.
  // TODO(zhihuang): Make this pure virtual when all subclasses implement it.
  // Note: This is called with both Plan B and Unified Plan semantics. Unified
  // Plan users should prefer OnTrack, OnAddTrack is only called as backwards
  // compatibility (and is called in the exact same situations as OnTrack).
  void PeerConnectionObserver::OnAddTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
      const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>& streams) {};

  // This is called when signaling indicates a transceiver will be receiving
  // media from the remote endpoint. This is fired during a call to
  // SetRemoteDescription. The receiving track can be accessed by:
  // `transceiver->receiver()->track()` and its associated streams by
  // `transceiver->receiver()->streams()`.
  // Note: This will only be called if Unified Plan semantics are specified.
  // This behavior is specified in section 2.2.8.2.5 of the "Set the
  // RTCSessionDescription" algorithm:
  // https://w3c.github.io/webrtc-pc/#set-description
  void PeerConnectionObserver::OnTrack(
      rtc::scoped_refptr<webrtc::RtpTransceiverInterface> transceiver) {};

  // Called when signaling indicates that media will no longer be received on a
  // track.
  // With Plan B semantics, the given receiver will have been removed from the
  // PeerConnection and the track muted.
  // With Unified Plan semantics, the receiver will remain but the transceiver
  // will have changed direction to either sendonly or inactive.
  // https://w3c.github.io/webrtc-pc/#process-remote-track-removal
  // TODO(hbos,deadbeef): Make pure virtual when all subclasses implement it.
  void PeerConnectionObserver::OnRemoveTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver) {};

  // Called when an interesting usage is detected by WebRTC.
  // An appropriate action is to add information about the context of the
  // PeerConnection and write the event to some kind of "interesting events"
  // log function.
  // The heuristics for defining what constitutes "interesting" are
  // implementation-defined.
  void PeerConnectionObserver::OnInterestingUsage(int usage_pattern) {};

// Construct `CreateOffer/Answer Observer`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Box<bridge::CreateOfferAnswerCallback> cb) {
  this->callbacks = std::move(cb);
};

// Calls when a `CreateOffer/Answer` is success.
void CreateSessionDescriptionObserver::OnSuccess(
    webrtc::SessionDescriptionInterface* desc) {
  if (callbacks) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    bridge::success_sdp(*callbacks.value(), sdp, type);
  }
  delete desc;
};

// Calls when a `CreateOffer\Answer` is fail.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  std::string err = std::string(error.message());
  bridge::fail_sdp(*callbacks.value(), err);
};

// Calls when a `SetLocalDescription` is complete or fail.
void SetLocalDescriptionObserver::OnSetLocalDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && callbacks) {
    bridge::success_set_description(*callbacks.value());
  } else {
    std::string error(error.message());
    bridge::fail_set_description(*callbacks.value(), error);
  }
};

// Construct `SetRemoteDescriptionObserverInterface`.
SetLocalDescriptionObserver::SetLocalDescriptionObserver(
    rust::cxxbridge1::Box<bridge::SetLocalRemoteDescriptionCallBack>
        callbacks) {
  this->callbacks = std::move(callbacks);
};

// Calls when a `SetRemoteDescription` is complete or fail.
void SetRemoteDescriptionObserver::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (error.ok() && callbacks.has_value()) {
    bridge::success_set_description(*callbacks.value());
  } else {
    std::string error(error.message());
    bridge::fail_set_description(*callbacks.value(), error);
  }
};

// Construct `SetRemoteDescriptionObserver`.
SetRemoteDescriptionObserver::SetRemoteDescriptionObserver(
    rust::cxxbridge1::Box<bridge::SetLocalRemoteDescriptionCallBack>
        callbacks) {
  this->callbacks = std::move(callbacks);
};

};  // namespace observer
