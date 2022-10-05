import WebRTC

class VideoMediaTrackSourceProxy: MediaTrackSource {
  private var peerConnectionFactory: RTCPeerConnectionFactory
  private var source: RTCVideoSource
  private var capturer: RTCCameraVideoCapturer
  private var deviceId: String
  private var tracksCount: Int = 0

  init(
    peerConnectionFactory: RTCPeerConnectionFactory, source: RTCVideoSource, deviceId: String,
    capturer: RTCCameraVideoCapturer
  ) {
    self.peerConnectionFactory = peerConnectionFactory
    self.source = source
    self.deviceId = deviceId
    self.capturer = capturer
  }

  func newTrack() -> MediaStreamTrackProxy {
    let track = peerConnectionFactory.videoTrack(
      with: source, trackId: LocalTrackIdGenerator.shared.nextId())
    let trackProxy = MediaStreamTrackProxy(track: track, deviceId: self.deviceId, source: self)
    self.tracksCount += 1
    trackProxy.onEnded(cb: {
      self.tracksCount -= 1
      if self.tracksCount == 0 {
        self.stop()
      }
    })
    return trackProxy
  }

  func stop() {
    self.capturer.stopCapture()
  }
}
