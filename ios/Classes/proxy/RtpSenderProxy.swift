import WebRTC

public class RtpSenderProxy {
  private var sender: RTCRtpSender
  private var track: MediaStreamTrackProxy? = nil

  init(sender: RTCRtpSender) {
    self.sender = sender
    self.syncMediaStreamTrack()
  }

  func replaceTrack(t: MediaStreamTrackProxy?) {
    self.track = t
    self.sender.track = t?.obj()
  }

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
