import AVFoundation
import OSLog
import WebRTC
import os

class MediaDevices {
  private var state: State
  private var videoCapturers: [RTCCameraVideoCapturer] = []

  init(state: State) {
    self.state = state
  }

  func enumerateDevices() -> [MediaDeviceInfo] {
    var devices = AVCaptureDevice.devices(for: AVMediaType.video).map { device -> MediaDeviceInfo in
      return MediaDeviceInfo(
        deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.audioInput)
    }
    let videoDevices = AVCaptureDevice.devices(for: AVMediaType.audio).map {
      device -> MediaDeviceInfo in
      return MediaDeviceInfo(
        deviceId: device.uniqueID, label: device.localizedName, kind: MediaDeviceKind.videoInput)
    }
    devices.append(contentsOf: videoDevices)
    return devices
  }

  func getUserMedia(constraints: Constraints) -> [MediaStreamTrackProxy] {
    var tracks = getUserAudio()
    if constraints.video != nil {
      tracks.append(getUserVideo(constraints: constraints.video!))
    }
    return tracks
  }

  private func findVideoDeviceForConstraints(constraints: VideoConstraints) -> AVCaptureDevice? {
    var maxScore = 0
    var bestFoundDevice: AVCaptureDevice?
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

  private func getUserAudio() -> [MediaStreamTrackProxy] {
    let track = self.state.getPeerFactory().audioTrack(
      withTrackId: LocalTrackIdGenerator.shared.nextId())
    let audioSource = AudioMediaTrackSourceProxy()
    let t = MediaStreamTrackProxy(track: track, deviceId: "audio", source: audioSource)
    audioSource.setTrack(track: t)
    return [t]
  }

  private func getUserVideo(constraints: VideoConstraints) -> MediaStreamTrackProxy {
    let videoDevice = self.findVideoDeviceForConstraints(constraints: constraints)!
    let selectedFormat = selectFormatForDevice(device: videoDevice, constraints: constraints)
    let fps = self.selectFpsForFormat(format: selectedFormat, constraints: constraints)

    let source = self.state.getPeerFactory().videoSource()
    let capturer = RTCCameraVideoCapturer(delegate: source)
    capturer.startCapture(with: videoDevice, format: selectedFormat, fps: fps)
    self.videoCapturers.append(capturer)
    let videoTrackSource = VideoMediaTrackSourceProxy(
      peerConnectionFactory: self.state.getPeerFactory(), source: source, deviceId: "camera")
    return videoTrackSource.newTrack()
  }

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
