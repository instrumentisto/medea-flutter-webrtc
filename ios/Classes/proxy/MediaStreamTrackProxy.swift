import WebRTC

/// Wrapper around a `MediaStreamTrack`.
class MediaStreamTrackProxy: Equatable {
  /// Indicates that this `stop` was called on this `MediaStreamTrackProxy`.
  private var isStopped = false

  /// Device ID of this `MediaStreamTrackProxy`.
  private var deviceId = "remote"

  /// Source of this `MediaStreamTrackProxy`.
  private var source: MediaTrackSource?

  /// Underlying `RTCMediaStreamTrack`.
  private var track: RTCMediaStreamTrack

  /// Subscribers for `onStop` callback of this `MediaStreamTrackProxy`.
  private var onStopSubscribers: [() -> Void] = []

  /// Subscribers for `onEnded` callback of this `MediaStreamTrackProxy`.
  private var onEndedSubscribers: [() -> Void] = []

  /// Creates a new `MediaStreamTrackProxy` based on the provided data.
  init(track: RTCMediaStreamTrack, deviceId: String?, source: MediaTrackSource?) {
    self.source = source
    if deviceId != nil {
      self.deviceId = deviceId!
    }
    self.track = track
    MediaStreamTrackStore.tracks[track.trackId] = self
  }

  /// Compares two `MediaStreamTrackProxy`s based on underlying `RTCMediaStreamTrack`s.
  static func == (lhs: MediaStreamTrackProxy, rhs: MediaStreamTrackProxy) -> Bool {
    lhs.track == rhs.track
  }

  /// Adds `RTCVideoRenderer` for the underlying `RTCMediaStreamTrack`.
  func addRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.add(renderer)
  }

  /// Removes `RTCVideoRenderer` for the underlying `RTCMediaStreamTrack`.
  func removeRenderer(renderer: RTCVideoRenderer) {
    let videoTrack = self.track as! RTCVideoTrack
    videoTrack.remove(renderer)
  }

  /// Returns ID of this track.
  func id() -> String {
    track.trackId
  }

  /// Returns kind of this track.
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

  /// Returns device ID of this track.
  func getDeviceId() -> String {
    self.deviceId
  }

  /// Returns forked `MediaStreamTrackProxy` based on the same source as this track.
  func fork() throws -> MediaStreamTrackProxy {
    if self.source == nil {
      throw MediaStreamTrackException.remoteTrackCantBeCloned
    } else {
      return source!.newTrack()
    }
  }

  /// Stops this track.
  ///
  /// Source will be stopped and disposed when all it's tracks are stopped.
  func stop() {
    self.isStopped = true
    for cb in onStopSubscribers {
      cb()
    }
  }

  /// Returns current `readyState` of this track.
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

  /// Sets `enabled` state of this track.
  func setEnabled(enabled: Bool) {
    self.track.isEnabled = enabled
  }

  /// Subscribes on `onStopped` callback of this track.
  func onStopped(cb: @escaping () -> Void) {
    self.onStopSubscribers.append(cb)
  }

  /// Notifies `RtpReceiverProxy` about its `MediaStreamTrackProxy` being removed from the receiver.
  func notifyEnded() {
    if self.track.readyState == .ended {
      for cb in self.onEndedSubscribers {
        cb()
      }
    }
  }

  /// Subscribes on `onEnded` callback of this track.
  func onEnded(cb: @escaping () -> Void) {
    self.onEndedSubscribers.append(cb)
  }

  /// Returns underlying `RTCMediaStreamTrack` of this proxy.
  func obj() -> RTCMediaStreamTrack {
    self.track
  }
}
