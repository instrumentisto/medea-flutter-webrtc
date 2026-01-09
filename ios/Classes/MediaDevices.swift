import AVFoundation
import WebRTC

/// Processor for `getUserMedia()` requests.
class MediaDevices {
  /// Global state used for creation of new `MediaStreamTrackProxy`s.
  private var state: State

  /// Wrapper around `AVAudioSession` calls that can disable auto-management.
  private var audioSession: AudioSession = .init()

  /// Subscribers for `onDeviceChange` callback of these `MediaDevices`.
  private var onDeviceChange: [() -> Void] = []

  /// Set of all existing `RTCPeerConnection`s.
  private var activePeers: Set<Int> = []

  /// Set of all existing local audio tracks.
  private var activeAudioTracks: Set<String> = []

  /// Indicator of whether `AVAudioSession` is currently "captured".
  private var isAudioSessionActive: Bool = false

  /// Enables/disables automatic `AVAudioSession` management.
  ///
  /// When disabled, this plugin will not call into `AVAudioSession` for
  /// category
  /// configuration / activation / deactivation. Device enumeration and explicit
  /// switching still works.
  func setupAudioSessionManagement(auto: Bool) {
    self.audioSession.autoManagementEnabled = auto
    self.updateAudioSession()
  }

  /// Initializes new `MediaDevices` with the provided `State`.
  ///
  /// Subscribes on `AVAudioSession.routeChangeNotification` notifications for
  /// `onDeviceChange` callback firing.
  init(state: State) {
    self.state = state
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification, object: nil,
      queue: OperationQueue.main,
      using: { (_: Notification) in
        for cb in self.onDeviceChange {
          cb()
        }
      }
    )
  }

  /// Called when a new `RTCPeerConnection` is created.
  ///
  /// Captures the `AVAudioSession` (if its not captured already).
  func peerAdded(_ id: Int) {
    assert(Thread.isMainThread)

    self.activePeers.insert(id)
    self.updateAudioSession()
  }

  /// Called when a `RTCPeerConnection` is disposed.
  ///
  /// Releases the `AVAudioSession` if it's the last `RTCPeerConnection` and
  /// there are no active local audio tracks.
  func peerRemoved(_ id: Int) {
    assert(Thread.isMainThread)

    if self.activePeers.remove(id) != nil {
      self.updateAudioSession()
    }
  }

  /// Called when a new local audio track is created.
  ///
  /// Captures the `AVAudioSession` (if its not captured already).
  func audioTrackAdded(_ id: String) {
    assert(Thread.isMainThread)

    self.activeAudioTracks.insert(id)
    self.updateAudioSession()
  }

  /// Called when a local audio track is disposed.
  ////
  /// Releases the `AVAudioSession` if it's the last local audio track and there
  /// are no `RTCPeerConnection`s.
  func audioTrackRemoved(_ id: String) {
    assert(Thread.isMainThread)

    if self.activeAudioTracks.remove(id) != nil {
      self.updateAudioSession()
    }
  }

  /// Captures the `AVAudioSession` if there is at least one local audio track
  /// or `RTCPeerConnection`, or releases otherwise.
  ///
  /// No-op if the `AVAudioSession` is in the desired state already.
  private func updateAudioSession() {
    assert(Thread.isMainThread)

    if !self.audioSession.autoManagementEnabled {
      return
    }

    let shouldBeActive = !self.activePeers.isEmpty || !self.activeAudioTracks
      .isEmpty
    if shouldBeActive, !self.isAudioSessionActive {
      try? self.audioSession.setCategory(
        .playAndRecord,
        options: .allowBluetooth
      )
      try? self.audioSession.setActive(true)
      self.isAudioSessionActive = true
    } else {
      if self.isAudioSessionActive {
        try? self.audioSession.setActive(
          false,
          notifyOthersOnDeactivation: true
        )
        self.isAudioSessionActive = false
      }
    }
  }

  /// Switches current input device to the iPhone's microphone.
  func setBuiltInMicAsInput() throws {
    if let routes = self.audioSession.availableInputs {
      for route in routes {
        if route.portType == .builtInMic {
          try self.audioSession.setPreferredInput(route)
          break
        }
      }
    }
  }

  /// Switches current audio output device to a device with the provided ID.
  func setOutputAudioId(id: String) throws {
    try self.audioSession.setCategory(
      .playAndRecord,
      options: .allowBluetooth
    )
    if id == "speaker" {
      try self.setBuiltInMicAsInput()
      try self.audioSession.overrideOutputAudioPort(.speaker)
    } else if id == "ear-piece" {
      try self.setBuiltInMicAsInput()
      try self.audioSession.overrideOutputAudioPort(.none)
    } else {
      let selectedInput = self.audioSession.availableInputs?
        .first(where: { $0.portName == id })
      if selectedInput != nil {
        try self.audioSession.setPreferredInput(selectedInput!)
      }
    }
  }

  /// Subscribes to `onDeviceChange` callback of these `MediaDevices`.
  func onDeviceChange(cb: @escaping () -> Void) {
    self.onDeviceChange.append(cb)
  }

  /// Returns a list of `MediaDeviceInfo`s for the currently available devices.
  func enumerateDevices() -> [MediaDeviceInfo] {
    var devices: [MediaDeviceInfo] = []
    devices.append(MediaDeviceInfo(
      deviceId: "speaker",
      label: "Speaker",
      kind: MediaDeviceKind.audioOutput,
      audioKind: AudioDeviceKind.speakerphone
    ))
    devices.append(MediaDeviceInfo(
      deviceId: "ear-piece",
      label: "Ear-Piece",
      kind: MediaDeviceKind.audioOutput,
      audioKind: AudioDeviceKind.earSpeaker
    ))

    let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video).map {
      device -> MediaDeviceInfo in
      MediaDeviceInfo(
        deviceId: device.uniqueID, label: device.localizedName,
        kind: MediaDeviceKind.videoInput
      )
    }
    devices.append(contentsOf: videoDevices)

    guard let availableInputs = self.audioSession.availableInputs else {
      return devices
    }

    let bluetoothOutput = availableInputs
      .filter { $0.portType == AVAudioSession.Port.bluetoothHFP }.last
    if bluetoothOutput != nil {
      devices.append(MediaDeviceInfo(
        deviceId: bluetoothOutput!.portName,
        label: bluetoothOutput!.portName,
        kind: MediaDeviceKind.audioOutput,
        audioKind: AudioDeviceKind.bluetoothHeadset
      ))
    }

    return devices
  }

  /// Creates local audio and video `MediaStreamTrackProxy`s based on the
  /// provided `Constraints`.
  func getUserMedia(constraints: Constraints) throws
    -> [MediaStreamTrackProxy]
  {
    var tracks: [MediaStreamTrackProxy] = []
    if constraints.audio != nil {
      tracks.append(self.getUserAudio())
    }
    if constraints.video != nil {
      try tracks.append(self.getUserVideo(constraints: constraints.video!))
    }

    return tracks
  }

  /// Searches for an `AVCaptureDevice` which fits into the provided
  /// `VideoConstraints`.
  private func findVideoDeviceForConstraints(constraints: VideoConstraints)
    -> AVCaptureDevice?
  {
    var maxScore = 0
    var bestFoundDevice: AVCaptureDevice?
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
      mediaType: AVMediaType.video,
      position: AVCaptureDevice.Position.unspecified
    )
    for device in AVCaptureDevice.devices(for: AVMediaType.video) {
      let deviceScore = constraints.calculateScoreForDevice(device: device)
      if deviceScore != nil {
        if deviceScore! >= maxScore {
          maxScore = deviceScore!
          bestFoundDevice = device
        }
      }
    }
    return bestFoundDevice
  }

  /// Creates an audio `MediaStreamTrackProxy`.
  private func getUserAudio() -> MediaStreamTrackProxy {
    let track = self.state.getPeerFactory().audioTrack(
      withTrackId: LocalTrackIdGenerator.shared.nextId()
    )
    let audioSource = AudioMediaTrackSourceProxy(track: track)
    let trackProxy = audioSource.newTrack()
    self.audioTrackAdded(trackProxy.id())
    trackProxy.onStopped(cb: { [weak self] in
      self?.audioTrackRemoved(trackProxy.id())
    })
    return trackProxy
  }

  /// Creates a video `MediaStreamTrackProxy` for the provided
  /// `VideoConstraints`.
  private func getUserVideo(constraints: VideoConstraints) throws
    -> MediaStreamTrackProxy
  {
    let source = self.state.getPeerFactory().videoSource()
    let capturer = RTCCameraVideoCapturer(delegate: source)

    #if targetEnvironment(simulator)
      let deviceId = "fake-camera"
      let position = AVCaptureDevice.Position.front
    #else

      guard
        let videoDevice = self.findVideoDeviceForConstraints(
          constraints: constraints
        )
      else {
        throw NSError(
          domain: "MediaDevices",
          code: 1,
          userInfo: [
            NSLocalizedDescriptionKey: "No suitable video device found.",
          ]
        )
      }
      let position = videoDevice.position
      let selectedFormat = try self.selectFormatForDevice(
        device: videoDevice,
        constraints: constraints
      )
      let fps = self.selectFpsForFormat(
        format: selectedFormat,
        constraints: constraints
      )
      capturer.startCapture(with: videoDevice, format: selectedFormat, fps: fps)
      let deviceId = videoDevice.uniqueID
    #endif
    let videoTrackSource = VideoMediaTrackSourceProxy(
      peerConnectionFactory: self.state.getPeerFactory(),
      source: source,
      position: position,
      deviceId: deviceId,
      capturer: capturer
    )
    return videoTrackSource.newTrack()
  }

  /// Selects the most suitable FPS for the provided `AVCaptureDevice.Format`.
  private func selectFpsForFormat(
    format: AVCaptureDevice.Format,
    constraints: VideoConstraints
  )
    -> Int
  {
    var maxSupportedFramerate = 0.0
    for fpsRange in format.videoSupportedFrameRateRanges {
      maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate)
    }
    var targetFps = 30
    if constraints.fps != nil {
      targetFps = constraints.fps!
    }
    return min(Int(maxSupportedFramerate), targetFps)
  }

  /// Selects the most suitable `AVCaptureDevice.Format` for the provided
  /// `AVCaptureDevice` based on the provided `VideoConstraints`.
  private func selectFormatForDevice(
    device: AVCaptureDevice,
    constraints: VideoConstraints
  )
    throws -> AVCaptureDevice.Format
  {
    var bestFoundFormat: AVCaptureDevice.Format?
    var currentDiff = Int.max
    var targetWidth = 640
    if constraints.width != nil {
      targetWidth = constraints.width!
    }
    var targetHeight = 480
    if constraints.height != nil {
      targetHeight = constraints.height!
    }
    for format in RTCCameraVideoCapturer.supportedFormats(for: device) {
      let dimension = CMVideoFormatDescriptionGetDimensions(format
        .formatDescription)
      let diff = abs(targetWidth - Int(dimension.width)) +
        abs(targetHeight - Int(dimension.height))
      if diff < currentDiff {
        bestFoundFormat = format
        currentDiff = diff
      }
    }
    guard let bestFoundFormat else {
      throw NSError(
        domain: "MediaDevices",
        code: 2,
        userInfo: [
          NSLocalizedDescriptionKey: "No suitable capture format found.",
        ]
      )
    }
    return bestFoundFormat
  }
}
