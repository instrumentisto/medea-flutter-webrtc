package com.cloudwebrtc.webrtc.utils;

import androidx.annotation.Nullable;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.RtpTransceiver;

public class EnumStringifier {
  @Nullable
  public static String iceConnectionStateString(
      PeerConnection.IceConnectionState iceConnectionState) {
    switch (iceConnectionState) {
      case NEW:
        return "new";
      case CHECKING:
        return "checking";
      case CONNECTED:
        return "connected";
      case COMPLETED:
        return "completed";
      case FAILED:
        return "failed";
      case DISCONNECTED:
        return "disconnected";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  public static String iceGatheringStateString(PeerConnection.IceGatheringState iceGatheringState) {
    switch (iceGatheringState) {
      case NEW:
        return "new";
      case GATHERING:
        return "gathering";
      case COMPLETE:
        return "complete";
    }
    return null;
  }

  @Nullable
  public static String signalingStateString(PeerConnection.SignalingState signalingState) {
    switch (signalingState) {
      case STABLE:
        return "stable";
      case HAVE_LOCAL_OFFER:
        return "have-local-offer";
      case HAVE_LOCAL_PRANSWER:
        return "have-local-pranswer";
      case HAVE_REMOTE_OFFER:
        return "have-remote-offer";
      case HAVE_REMOTE_PRANSWER:
        return "have-remote-pranswer";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  public static String connectionStateString(PeerConnection.PeerConnectionState connectionState) {
    switch (connectionState) {
      case NEW:
        return "new";
      case CONNECTING:
        return "connecting";
      case CONNECTED:
        return "connected";
      case DISCONNECTED:
        return "disconnected";
      case FAILED:
        return "failed";
      case CLOSED:
        return "closed";
    }
    return null;
  }

  @Nullable
  public static String transceiverDirectionString(
      RtpTransceiver.RtpTransceiverDirection direction) {
    switch (direction) {
      case SEND_RECV:
        return "sendrecv";
      case SEND_ONLY:
        return "sendonly";
      case RECV_ONLY:
        return "recvonly";
      case INACTIVE:
        return "inactive";
    }
    return null;
  }

  @Nullable
  public static String trackReadyStateString(MediaStreamTrack.State state) {
    switch (state) {
      case ENDED:
        return "ended";
      case LIVE:
        return "live";
    }
    return null;
  }

  public static RtpTransceiver.RtpTransceiverDirection stringToTransceiverDirection(
      String direction) {
    switch (direction) {
      case "sendrecv":
        return RtpTransceiver.RtpTransceiverDirection.SEND_RECV;
      case "sendonly":
        return RtpTransceiver.RtpTransceiverDirection.SEND_ONLY;
      case "recvonly":
        return RtpTransceiver.RtpTransceiverDirection.RECV_ONLY;
      case "inactive":
        return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
    }
    return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
  }
}
