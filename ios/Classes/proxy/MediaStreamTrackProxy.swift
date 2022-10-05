import WebRTC

class MediaStreamTrackProxy: Equatable {
  private var isStopped = false
  private var deviceId = "remote"
  private var source: MediaTrackSource?
  private var track: RTCMediaStreamTrack
  private var onStopSubscribers: [() -> Void] = []

  init(track: RTCMediaStreamTrack, deviceId: String?, source: MediaTrackSource?) {
    self.source = source
    if deviceId != nil {
      self.deviceId = deviceId!
    }
    self.track = track
    MediaStreamTrackStore.tracks[track.trackId] = self
  }

  static func == (lhs: MediaStreamTrackProxy, rhs: MediaStreamTrackProxy) -> Bool {
    return lhs.track == rhs.track
  }

  func addRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.add(renderer)
  }

  func removeRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.remove(renderer)
  }

  func id() -> String {
    return track.trackId
  }

  func kind() -> MediaType {
    let kind = track.kind
    switch kind {
    case "audio":
      return MediaType.audio
    case "video":
      return MediaType.video
    default:
      abort()
    }
  }

  func getDeviceId() -> String {
    return self.deviceId
  }

  func fork() throws -> MediaStreamTrackProxy {
    if self.source == nil {
      throw MediaStreamTrackException.remoteTrackCantBeCloned
    } else {
      return self
      return source!.newTrack()
    }
  }

  func stop() {
    self.isStopped = true
    for cb in onStopSubscribers {
      cb()
    }
  }

  func state() -> MediaStreamTrackState {
    let state = track.readyState
    switch state {
    case .live:
      return MediaStreamTrackState.live
    case .ended:
      return MediaStreamTrackState.ended
    default:
      abort()
    }
  }

  func setEnabled(enabled: Bool) {
    self.track.isEnabled = enabled
  }

  func onEnded(cb: @escaping () -> Void) {
    self.onStopSubscribers.append(cb)
  }

  func obj() -> RTCMediaStreamTrack {
    return self.track
  }
}
