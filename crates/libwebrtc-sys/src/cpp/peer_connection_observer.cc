
#include "libwebrtc-sys/include/peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace observer {

PeerConnectionObserver::PeerConnectionObserver(
    rust::Box<bridge::DynPeerConnectionOnEvent> cb)
    : cb_(std::move(cb)){};

// Triggered when the SignalingState changed.
// Propagates the received `SignalingState new_state` to the Rust side.
void PeerConnectionObserver::OnSignalingChange(
    webrtc::PeerConnectionInterface::SignalingState new_state) {
  if (cb_) {
    bridge::call_peer_connection_on_signaling_change(*cb_.value(), new_state);
  }
}

// no need
void PeerConnectionObserver::OnDataChannel(
    rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {};

// Used to fire spec-compliant onnegotiationneeded events, which should only
// fire when the Operations Chain is empty. The observer is responsible for
// queuing a task (e.g. Chromium: jump to main thread) to maybe fire the
// event. The event identified using `event_id` must only fire if
// PeerConnection::ShouldFireNegotiationNeededEvent() returns true since it is
// possible for the event to become invalidated by operations subsequently
// chained.
// Propagates the received `event_id` to the Rust side.
void PeerConnectionObserver::OnNegotiationNeededEvent(uint32_t event_id) {
  if (cb_) {
    bridge::call_peer_connection_on_negotiation_needed_event(*cb_.value(),
                                                             event_id);
  }
}

// Called any time the standards-compliant IceConnectionState changes.
// Propagates the received `IceConnectionState new_state` to the Rust side.
void PeerConnectionObserver::OnStandardizedIceConnectionChange(
    webrtc::PeerConnectionInterface::IceConnectionState new_state) {
  if (cb_) {
    bridge::call_peer_connection_on_standardized_ice_connection_change(
        *cb_.value(), new_state);
  }
}

// Called any time the PeerConnectionState changes.
// Propagates the received `PeerConnectionState new_state` to the Rust side.
void PeerConnectionObserver::OnConnectionChange(
    webrtc::PeerConnectionInterface::PeerConnectionState new_state) {
  if (cb_) {
    bridge::call_peer_connection_on_connection_change(*cb_.value(), new_state);
  }
}

// Called any time the IceGatheringState changes.
// Propagates the received `IceGatheringState new_state` to the Rust side.
void PeerConnectionObserver::OnIceGatheringChange(
    webrtc::PeerConnectionInterface::IceGatheringState new_state) {
  if (cb_) {
    bridge::call_peer_connection_on_ice_gathering_change(*cb_.value(),
                                                         new_state);
  }
}

// A new ICE candidate has been gathered.
// Propagates the received `IceCandidateInterface candidate` to the Rust side.
void PeerConnectionObserver::OnIceCandidate(
    const webrtc::IceCandidateInterface* candidate) {
  if (cb_) {
    bridge::call_peer_connection_on_ice_candidate(*cb_.value(), candidate);
  }
}

// Gathering of an ICE candidate failed.
// See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
// `host_candidate` is a stringified socket address.
// Propagates the received `host_candidate`,
// `url`, `error_code`, `error_text` to the Rust side.
void PeerConnectionObserver::OnIceCandidateError(
    const std::string& host_candidate,
    const std::string& url,
    int error_code,
    const std::string& error_text) {
  if (cb_) {
    bridge::call_peer_connection_on_ice_candidate_error(
        *cb_.value(), host_candidate, url, error_code, error_text);
  }
}

// Gathering of an ICE candidate failed.
// See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
// Propagates the received `address`, `port`, 
// `url`, `error_code`, `error_text` to the Rust side.
void PeerConnectionObserver::OnIceCandidateError(
    const std::string& address,
    int port,
    const std::string& url,
    int error_code,
    const std::string& error_text) {
  if (cb_) {
    bridge::call_peer_connection_on_ice_candidate_address_port_error(
        *cb_.value(), address, port, url, error_code, error_text);
  }
}

// Ice candidates have been removed.
// Propagates the received `std::vector<cricket::Candidate> candidates` to the Rust side.
void PeerConnectionObserver::OnIceCandidatesRemoved(
    const std::vector<cricket::Candidate>& candidates) {
  if (cb_) {
    rust::Vec<bridge::CandidateWrap> vec;
    for (int i = 0; i < candidates.size(); ++i) {
      vec.push_back(bridge::create_candidate_wrapp(
          std::make_unique<bridge::Candidate>(candidates[i])));
    }
    bridge::call_peer_connection_on_ice_candidates_removed(*cb_.value(),
                                                           std::move(vec));
  }
}

// Called when the ICE connection receiving status changes.
// Propagates the received `receiving` to the Rust side.
void PeerConnectionObserver::OnIceConnectionReceivingChange(bool receiving) {
  if (cb_) {
    bridge::call_peer_connection_on_ice_connection_receiving_change(
        *cb_.value(), receiving);
  }
}

// Called when the selected candidate pair for the ICE connection changes.
// Propagates the received `CandidatePairChangeEvent event` to the Rust side.
void PeerConnectionObserver::OnIceSelectedCandidatePairChanged(
    const cricket::CandidatePairChangeEvent& event) {
  if (cb_) {
    bridge::call_on_ice_selected_candidate_pair_changed(*cb_.value(), event);
  }
}

// This is called when a receiver and its track are created.
// TODO(zhihuang): Make this pure virtual when all subclasses implement it.
// Note: This is called with both Plan B and Unified Plan semantics. Unified
// Plan users should prefer OnTrack, OnAddTrack is only called as backwards
// compatibility (and is called in the exact same situations as OnTrack).
void PeerConnectionObserver::OnAddTrack(
    rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
    const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>&
        streams) {
          // rust::Vec<bridge::MediaStreamInterfaceWrap> vec;
          // for (int i = 0; i < streams.size(); ++i) {
          //   auto stream 
          //     = std::make_unique<bridge::rc<webrtc::MediaStreamInterface>>(
          //       bridge::rc<webrtc::MediaStreamInterface>(streams[i]));
          //   vec.push_back(bridge::create_media_stream_wrapp(std::move(stream)));
          // }
        }

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
    rtc::scoped_refptr<webrtc::RtpTransceiverInterface> transceiver){}

// Called when signaling indicates that media will no longer be received on a
// track.
// With Plan B semantics, the given receiver will have been removed from the
// PeerConnection and the track muted.
// With Unified Plan semantics, the receiver will remain but the transceiver
// will have changed direction to either sendonly or inactive.
// https://w3c.github.io/webrtc-pc/#process-remote-track-removal
void PeerConnectionObserver::OnRemoveTrack(
    rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver){}

// Called when an interesting usage is detected by WebRTC.
// An appropriate action is to add information about the context of the
// PeerConnection and write the event to some kind of "interesting events"
// log function.
// The heuristics for defining what constitutes "interesting" are
// implementation-defined.
// Propagates the received `usage_pattern` to the Rust side.
void PeerConnectionObserver::OnInterestingUsage(int usage_pattern) {
  if (cb_) {
    bridge::call_peer_connection_on_interesting_usage(*cb_.value(),
                                                      usage_pattern);
  }
}

// Creates a new `CreateSessionDescriptionObserver` backed by the provided
// `bridge::DynCreateSdpCallback`.
CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Box<bridge::DynCreateSdpCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the received SDP to the Rust side.
void CreateSessionDescriptionObserver::OnSuccess(
    webrtc::SessionDescriptionInterface* desc) {
  if (cb_) {
    auto cb = std::move(*cb_);

    std::string sdp;
    desc->ToString(&sdp);
    bridge::create_sdp_success(std::move(cb), sdp, desc->GetType());
  }
  delete desc;
}

// Propagates the received error to the Rust side.
void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    std::string err = std::string(error.message());
    bridge::create_sdp_fail(std::move(cb), err);
  }
}

// Creates a new `SetLocalDescriptionObserver` backed by the provided
// `DynSetDescriptionCallback`.
SetLocalDescriptionObserver::SetLocalDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the completion result to the Rust side.
void SetLocalDescriptionObserver::OnSetLocalDescriptionComplete(
    webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    if (error.ok()) {
      bridge::set_description_success(std::move(cb));
    } else {
      std::string err = std::string(error.message());
      bridge::set_description_fail(std::move(cb), err);
    }
  }
}

// Creates a new `SetRemoteDescriptionObserver` backed by the provided
// `DynSetDescriptionCallback`.
SetRemoteDescriptionObserver::SetRemoteDescriptionObserver(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  this->cb_ = std::move(cb);
}

// Propagates the completion result to the Rust side.
void SetRemoteDescriptionObserver::OnSetRemoteDescriptionComplete(
    webrtc::RTCError error) {
  if (cb_) {
    auto cb = std::move(*cb_);

    if (error.ok()) {
      bridge::set_description_success(std::move(cb));
    } else {
      std::string err = std::string(error.message());
      bridge::set_description_fail(std::move(cb), err);
    }
  }
}

}  // namespace observer
