import AVFoundation
import WebRTC

/// Processor for `getUserMedia` requests.
class MediaDevices {
  /**
    Global state used for creation new `MediaStreamTrackProxy`s.
  */
  private var state: State

  /// Creates new `MediaDevices`.
  init(state: State) {
    self.state = state
  }

  /// - Returns: List of `MediaDeviceInfo`s for the currently available devices.
  func enumerateDevices() -> [MediaDeviceInfo] {
    var devices = AVCaptureDevice.devices(for: AVMediaType.audio).map { device -> MediaDeviceInfo in
      MediaDeviceInfo(
        deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.audioInput)
    }
    let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video).map {
      device -> MediaDeviceInfo in
      MediaDeviceInfo(
        deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.videoInput)
    }
    devices.append(contentsOf: videoDevices)
    return devices
  }

  /**
    Creates local audio and video `MediaStreamTrackProxy`s based on the provided `Constraints`.

    - Parameters:
      - constraints: Parameters based on which `MediaDevices` will select most suitable device.

    - Returns: List of `MediaStreamTrackProxy`s most suitable based on the provided `Constraints`.
  */
  func getUserMedia(constraints: Constraints) -> [MediaStreamTrackProxy] {
    var tracks: [MediaStreamTrackProxy] = []
    if constraints.audio != nil {
      tracks.append(getUserAudio())
    }
    if constraints.video != nil {
      tracks.append(getUserVideo(constraints: constraints.video!))
    }

    return tracks
  }

  /**
    Searches for `AVCaptureDevice` which fits into provided `VideoConstraints`.

    - Returns: Found `AVCaptureDevice` or `nil` if all devices doesn't fits into constraints.
  */
  private func findVideoDeviceForConstraints(constraints: VideoConstraints) -> AVCaptureDevice? {
    var maxScore = 0
    var bestFoundDevice: AVCaptureDevice?
    let discoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
      mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
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

  /**
    Creates an audio `MediaStreamTrackProxy`s.

    - Returns: All found `MediaStreamTrackProxy`s.
  */
  private func getUserAudio() -> MediaStreamTrackProxy {
    let track = self.state.getPeerFactory().audioTrack(
      withTrackId: LocalTrackIdGenerator.shared.nextId())
    let audioSource = AudioMediaTrackSourceProxy()
    let t = MediaStreamTrackProxy(track: track, deviceId: "audio", source: audioSource)
    audioSource.setTrack(track: t)

    return t
  }

  /**
    Creates a video `MediaStreamTrackProxy` for the provided `VideoConstraints`.

    - Parameters:
      - constraints: `VideoConstraints` to perform the lookup with.

    - Returns: Most suitable `MediaStreamTrackProxy` for the provided `VideoConstraints`.
  */
  private func getUserVideo(constraints: VideoConstraints) -> MediaStreamTrackProxy {
    let videoDevice = self.findVideoDeviceForConstraints(constraints: constraints)!
    let selectedFormat = selectFormatForDevice(device: videoDevice, constraints: constraints)
    let fps = self.selectFpsForFormat(format: selectedFormat, constraints: constraints)

    let source = self.state.getPeerFactory().videoSource()
    let capturer = RTCCameraVideoCapturer(delegate: source)
    capturer.startCapture(with: videoDevice, format: selectedFormat, fps: fps)
    let videoTrackSource = VideoMediaTrackSourceProxy(
      peerConnectionFactory: self.state.getPeerFactory(), source: source,
      deviceId: videoDevice.uniqueID,
      capturer: capturer)
    return videoTrackSource.newTrack()
  }

  /**
    Selects most suitable FPS for the provided `AVCaptureDevice.Format`.

    - Parameters:
      - format: `AVCaptureDevice.Format` for which FPS will be selected.
      - constraints: Video constraints based on which FPS will be selected.

    - Returns: Most suitable FPS for `AVCaptureDevice.Format`.
  */
  private func selectFpsForFormat(format: AVCaptureDevice.Format, constraints: VideoConstraints)
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

  /**
    Selects most suitable `AVCaptureDevice.Format` for the provided `AVCaptureDevice`
    based on the provided `VideoConstraints`.

    - Parameters:
      - device: `AVCaptureDevice` for which format will be selected.
      - constraints: Video constraints based on which format will be selected.

    - Returns: Most suitable `AVCaptureDevice.Format` for the provided `AVCaptureDevice`.
  */
  private func selectFormatForDevice(device: AVCaptureDevice, constraints: VideoConstraints)
    -> AVCaptureDevice.Format
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
      let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
      let diff = abs(targetWidth - Int(dimension.width)) + abs(targetHeight - Int(dimension.height))
      if diff < currentDiff {
        bestFoundFormat = format
        currentDiff = diff
      }
    }

    return bestFoundFormat!
  }
}
