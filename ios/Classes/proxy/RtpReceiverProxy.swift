import WebRTC

class RtpReceiverProxy {
  private var receiver: RTCRtpReceiver
  private var track: MediaStreamTrackProxy

  init(receiver: RTCRtpReceiver) {
    self.receiver = receiver
    self.track = MediaStreamTrackProxy(track: self.receiver.track!, deviceId: nil, source: nil)
  }

  func id() -> String {
    return self.receiver.receiverId
  }

  func getTrack() -> MediaStreamTrackProxy {
    return self.track
  }

  func notifyRemoved() {
    // self.track.stop()
    // self.track.onEnded()
  }
}
