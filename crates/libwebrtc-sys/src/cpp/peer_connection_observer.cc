
#include "libwebrtc-sys\include\peer_connection_observer.h"
#include "libwebrtc-sys/src/bridge.rs.h"


/*
    EncodableMap params;
    params[EncodableValue("event")] = "signalingState";
    params[EncodableValue("state")] = signalingStateString(state);
    event_sink_->Success(EncodableValue(params));
*/

namespace observer
{

  PeerConnectionObserver::PeerConnectionObserver(
    rust::Fn<void (const std::string &)> e
  ) {
    event_handler = e;
  }

  // Triggered when the SignalingState changed.
  void PeerConnectionObserver::OnSignalingChange(
       webrtc::PeerConnectionInterface::SignalingState new_state) {
         printf("FALL HERE %s\n", webrtc::PeerConnectionInterface::AsString(new_state).data());
         (*event_handler)(webrtc::PeerConnectionInterface::AsString(new_state).data());
       }

  // Triggered when media is received on a new stream from remote peer.
  void PeerConnectionObserver::OnAddStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream) {
    printf("OnAddStream\n");
  }

  // Triggered when a remote peer closes a stream.
  void PeerConnectionObserver::OnRemoveStream(rtc::scoped_refptr<webrtc::MediaStreamInterface> stream) {
    printf("OnRemoveStream\n");
  }

  // Triggered when a remote peer opens a data channel.
  void PeerConnectionObserver::OnDataChannel(
      rtc::scoped_refptr<webrtc::DataChannelInterface> data_channel) {
        printf("OnDataChannel\n");
      }

  // Triggered when renegotiation is needed. For example, an ICE restart
  // has begun.
  // TODO(hbos): Delete in favor of OnNegotiationNeededEvent() when downstream
  // projects have migrated.
  void PeerConnectionObserver::OnRenegotiationNeeded() {
    printf("OnRenegotiationNeeded\n");
  }
  // Used to fire spec-compliant onnegotiationneeded events, which should only
  // fire when the Operations Chain is empty. The observer is responsible for
  // queuing a task (e.g. Chromium: jump to main thread) to maybe fire the
  // event. The event identified using `event_id` must only fire if
  // PeerConnection::ShouldFireNegotiationNeededEvent() returns true since it is
  // possible for the event to become invalidated by operations subsequently
  // chained.
  void PeerConnectionObserver::OnNegotiationNeededEvent(uint32_t event_id) {
    printf("OnNegotiationNeededEvent\n");
  }

  // Called any time the legacy IceConnectionState changes.
  //
  // Note that our ICE states lag behind the standard slightly. The most
  // notable differences include the fact that "failed" occurs after 15
  // seconds, not 30, and this actually represents a combination ICE + DTLS
  // state, so it may be "failed" if DTLS fails while ICE succeeds.
  //
  // TODO(jonasolsson): deprecate and remove this.
  void PeerConnectionObserver::OnIceConnectionChange(
      webrtc::PeerConnectionInterface::IceConnectionState new_state) {
        printf("deprecate OnIceConnectionChange %s\n", webrtc::PeerConnectionInterface::AsString(new_state).data());
      }

  // Called any time the standards-compliant IceConnectionState changes.
  void PeerConnectionObserver::OnStandardizedIceConnectionChange(
      webrtc::PeerConnectionInterface::IceConnectionState new_state) {
        printf("OnStandardizedIceConnectionChange %s\n", webrtc::PeerConnectionInterface::AsString(new_state).data());
      }

  // Called any time the PeerConnectionState changes.
  void PeerConnectionObserver::OnConnectionChange(
      webrtc::PeerConnectionInterface::PeerConnectionState new_state) {
        printf("OnConnectionChange %s\n", webrtc::PeerConnectionInterface::AsString(new_state).data());
      }

  // Called any time the IceGatheringState changes.
  void PeerConnectionObserver::OnIceGatheringChange(
      webrtc::PeerConnectionInterface::IceGatheringState new_state) {
        printf("OnIceGatheringChange %s\n", webrtc::PeerConnectionInterface::AsString(new_state).data());
      }

  // A new ICE candidate has been gathered.
  void PeerConnectionObserver::OnIceCandidate(const webrtc::IceCandidateInterface* candidate) {
    printf("|OnIceCandidate %s|\n", candidate->server_url());
  }

  // Gathering of an ICE candidate failed.
  // See https://w3c.github.io/webrtc-pc/#event-icecandidateerror
  // `host_candidate` is a stringified socket address.
  void PeerConnectionObserver::OnIceCandidateError(const std::string& host_candidate,
                                   const std::string& url,
                                   int error_code,
                                   const std::string& error_text) {
                                     printf("OnIceCandidateError\n");
                                   }

  // Ice candidates have been removed.
  // TODO(honghaiz): Make this a pure virtual method when all its subclasses
  // implement it.
  void PeerConnectionObserver::OnIceCandidatesRemoved(
      const std::vector<cricket::Candidate>& candidates) {
        printf("OnIceCandidatesRemoved\n");
      }

  // Called when the ICE connection receiving status changes.
  void PeerConnectionObserver::OnIceConnectionReceivingChange(bool receiving) {
    printf("OnIceConnectionReceivingChange\n");
  }

  // Called when the selected candidate pair for the ICE connection changes.
  void PeerConnectionObserver::OnIceSelectedCandidatePairChanged(
      const cricket::CandidatePairChangeEvent& event) {
        printf("OnIceSelectedCandidatePairChanged\n");
      }

  // This is called when a receiver and its track are created.
  // TODO(zhihuang): Make this pure virtual when all subclasses implement it.
  // Note: This is called with both Plan B and Unified Plan semantics. Unified
  // Plan users should prefer OnTrack, OnAddTrack is only called as backwards
  // compatibility (and is called in the exact same situations as OnTrack).
  void PeerConnectionObserver::OnAddTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver,
      const std::vector<rtc::scoped_refptr<webrtc::MediaStreamInterface>>& streams) {
        printf("OnAddTrack\n");
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
      rtc::scoped_refptr<webrtc::RtpTransceiverInterface> transceiver) {
        printf("OnTrack\n");
      }

  // Called when signaling indicates that media will no longer be received on a
  // track.
  // With Plan B semantics, the given receiver will have been removed from the
  // PeerConnection and the track muted.
  // With Unified Plan semantics, the receiver will remain but the transceiver
  // will have changed direction to either sendonly or inactive.
  // https://w3c.github.io/webrtc-pc/#process-remote-track-removal
  // TODO(hbos,deadbeef): Make pure virtual when all subclasses implement it.
  void PeerConnectionObserver::OnRemoveTrack(
      rtc::scoped_refptr<webrtc::RtpReceiverInterface> receiver) {
        printf("OnRemoveTrack\n");
      }

  // Called when an interesting usage is detected by WebRTC.
  // An appropriate action is to add information about the context of the
  // PeerConnection and write the event to some kind of "interesting events"
  // log function.
  // The heuristics for defining what constitutes "interesting" are
  // implementation-defined.
  void PeerConnectionObserver::OnInterestingUsage(int usage_pattern) {
    printf("OnInterestingUsage\n");
  } 




  // Construct `CreateOffer\Answer Observer`.
  CreateSessionDescriptionObserver::CreateSessionDescriptionObserver(
    rust::Fn<void (const std::string &, const std::string &)> s,
    rust::Fn<void (const std::string &)> f) {
      success = s;
      fail = f;
    };

  // Calls when a `CreateOffer\Answer` is success.
  void CreateSessionDescriptionObserver::OnSuccess(webrtc::SessionDescriptionInterface* desc) {
    std::string type = desc->type();
    std::string sdp;
    desc->ToString(&sdp);
    (*success)(sdp, type); 
    delete desc;
  };

  // Calls when a `CreateOffer\Answer` is fail.
  void CreateSessionDescriptionObserver::OnFailure(webrtc::RTCError error) {
    std::string err = std::string(error.message());
    (*fail)(err);
  };

  // Implementation rtc::RefCountInterface::AddRef.
  void CreateSessionDescriptionObserver::AddRef() const {
    ++ref_count;
  }; 

  // Implementation rtc::RefCountInterface::Release.
  rtc::RefCountReleaseStatus CreateSessionDescriptionObserver::Release() const {
    if (--ref_count == 0) { 
      delete this;
      return rtc::RefCountReleaseStatus::kDroppedLastRef;
    }
    return rtc::RefCountReleaseStatus::kOtherRefsRemained;
  };

  // Calls when a `SetLocalDescription` is complete or fail.
  void SetLocalDescriptionObserverInterface::OnSetLocalDescriptionComplete(webrtc::RTCError error) {
    if(error.ok()) {
      (*success)();
    } else {
      std::string error(error.message());
      (*fail)(error);
    }
  };

  // Construct SetRemoteDescriptionObserverInterface.
  SetLocalDescriptionObserverInterface::SetLocalDescriptionObserverInterface(
    rust::Fn<void ()> s, 
    rust::Fn<void (const std::string &)> f
  ) {
    success = s;
    fail = f;
  };

  // Implementation rtc::RefCountInterface::AddRef. 
  void SetLocalDescriptionObserverInterface::AddRef() const {
    ++ref_count;
  };
  // Implementation rtc::RefCountInterface::Release. 
  rtc::RefCountReleaseStatus SetLocalDescriptionObserverInterface::Release() const {
    if (--ref_count == 0) { 
      delete this;
      return rtc::RefCountReleaseStatus::kDroppedLastRef;
    }
    return rtc::RefCountReleaseStatus::kOtherRefsRemained;
  };

  // Calls when a `SetRemoteDescription` is complete or fail.
  void SetRemoteDescriptionObserverInterface::OnSetRemoteDescriptionComplete(webrtc::RTCError error) {
    if(error.ok()) {
      (*success)();
    } else {
      std::string error(error.message());
      (*fail)(error);
    }
  };

  // Construct SetRemoteDescriptionObserverInterface.
  SetRemoteDescriptionObserverInterface::SetRemoteDescriptionObserverInterface(
    rust::Fn<void ()> s, 
    rust::Fn<void (const std::string &)> f
  ) {
    success = s;
    fail = f;
  };

  // Implementation rtc::RefCountInterface::AddRef. 
  void SetRemoteDescriptionObserverInterface::AddRef() const {
    ++ref_count;
  };

  // Implementation rtc::RefCountInterface::Release. 
  rtc::RefCountReleaseStatus SetRemoteDescriptionObserverInterface::Release() const {
    if (--ref_count == 0) { 
      delete this;
      return rtc::RefCountReleaseStatus::kDroppedLastRef;
    }
    return rtc::RefCountReleaseStatus::kOtherRefsRemained;
  };

};