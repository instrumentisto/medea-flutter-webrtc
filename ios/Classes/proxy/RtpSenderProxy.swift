import WebRTC

/// Wrapper around an `RTCRtpSender`.
class RtpSenderProxy {
  /// Actual underlying `RTCRtpReceiver`.
  private var sender: RTCRtpSender

  /// `MediaStreamTrackProxy` of this `RtpReceiverProxy`.
  private var track: MediaStreamTrackProxy? = nil

  /// Creates a new `RtpSenderProxy` for the provided `RTCRtpSender`.
  init(sender: RTCRtpSender) {
    self.sender = sender
    self.syncMediaStreamTrack()
  }

  /// Returns ID of this `RtpSenderProxy`.
  func id() -> String {
    self.sender.senderId
  }

  /**
    Replaces `MediaStreamTrackProxy` of the underlying `RtpSender` with the provided one.

    - Parameters:
      - t: `MediaStreamTrackProxy` which will be set to the underlying `RtpSender`.
  */
  func replaceTrack(t: MediaStreamTrackProxy?) {
    self.track = t
    self.sender.track = t?.obj()
  }

  /**
    Synchronizes the `MediaStreamTrackProxy` of this `RtpSenderProxy` with the underlying
    `RtpSender`.
  */
  func syncMediaStreamTrack() {
    let newTrack = self.sender.track
    if newTrack == nil {
      self.track = nil
    } else {
      if self.track == nil {
        self.track = MediaStreamTrackProxy(track: newTrack!, deviceId: nil, source: nil)
      }
    }
  }
}
